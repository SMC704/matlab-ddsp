% ADDITIVE SYNTH
%
% INPUTS:
%
% n_samples: int
% sample_rate: int
% amplitudes: Frame-wise oscillator peak amplitude. Shape: [n_frames, 1]
% harmonic distribution: Frame-wise harmonic amplitude variations. Shape. [n_frames, n_harmonics]
% f0: Frame-wise fundamental frequency in Hz. Shape: [n_frames, 1]
%
% RETURNS:
%
% Sample-wise audio signal

function [audio,last_phases] = additive(n_samples, sample_rate, amplitudes, harmonic_distribution, f0, prev_phases)
       
    % Scale the amplitudes
    amplitudes = scale_fn(amplitudes);
    harmonic_distribution = scale_fn(harmonic_distribution);
    
    % Bandlimit the harmonic distribution
    n_harmonics = size(harmonic_distribution, 2);
    harmonic_frequencies = get_harmonic_frequencies(f0, n_harmonics);
    harmonic_distribution = remove_above_nyquist(harmonic_frequencies, harmonic_distribution,sample_rate);
    
    % Normalize the harmonic distribution
    harmonic_distribution = harmonic_distribution ./ sum(harmonic_distribution, 2);
    
    % Plot synthesizer controls
    %plot_controls(amplitudes, harmonic_distribution, f0);
    
    % Create harmonic amplitudes
    harmonic_amplitudes = amplitudes .* harmonic_distribution;
    
    % Create sample-wise envelopes
    frequency_envelopes = resample(harmonic_frequencies, n_samples, 'linear');
    amplitude_envelopes = resample(harmonic_amplitudes, n_samples, 'window');
    
    % Convert frequency, Hz -> angular frequency, radians/sample
    harmonic_angular_frequencies = frequency_envelopes * 2 * pi; %radiant/second
    harmonic_angular_frequencies = harmonic_angular_frequencies / sample_rate; %radiant/sample
    
    % Accumulate phase and synthesize
    phases = cumsum(harmonic_angular_frequencies);
    
    % If synthesized examples are longer than ~100k audio
    % samples, consider use angular_cumsum to avoid accumulating noticible phase
    % errors due to the limited precision of cumsum
    %
    % phases = angular_cumsum(harmonic_angular_frequencies, n_samples);
    
    % Save last phases of all harmonics for next buffer
    prev_phases = prev_phases(1, 1:n_harmonics);
    phases = phases+prev_phases;
    phases = mod(phases, 2*pi);
    last_phases = phases(end,:);
    
    % Convert to waveforms
    wavs = sin(phases);
    audio = amplitude_envelopes .* wavs;
    audio = sum(audio, 2);
end

% Scale Function
% Exponentiated Sigmoid pointwise nonlinearity
function y = scale_fn(x)
    
    exponent = 10.0;
    max_value = 2.0;
    threshold = 1e-7;
    
    y = max_value * (1./(1+exp(-x))).^log(exponent) + threshold;
end

% Calculate sample-wise oscillator frequencies of harmonics
function harmonic_frequencies = get_harmonic_frequencies(f0, n_harmonics)

    f_ratios = linspace(1, n_harmonics, n_harmonics);
    harmonic_frequencies = f0 * f_ratios;
end

% Set amplitudes for oscillators above nyquist to 0
function harmonic_distribution_nyquist = remove_above_nyquist(harmonic_frequencies, harmonic_distribution, sample_rate)

    harmonic_distribution(harmonic_frequencies >= sample_rate/2) = 0;
    harmonic_distribution_nyquist = harmonic_distribution;
end

% Get phase by cumulative sumation of angular frequency
% Returns: The accumulated phase in range [0, 2*pi]
function phase = angular_cumsum(angular_frequency, n_samples)
    
    chunk_size = 1000;
    n_frequencies = size(angular_frequency, 2);
    
    % Pad if needed
    remainder = mod(n_samples, chunk_size);
    if remainder > 0
        pad = chunk_size - remainder;
        angular_frequency = [angular_frequency; zeros(pad,n_frequencies)];
    end
    
    % Split input into chunks
    length = size(angular_frequency,1);
    n_chunks = length / chunk_size;
    chunks = permute(reshape(angular_frequency',[n_frequencies,chunk_size,n_chunks]), [2,1,3]); % workaround because Matlab reshape only works column-wise
    phase = cumsum(chunks, 1);
    
    % Add offsets
    % Offset of the next row is the last entry of the previous row
    offsets = mod(phase(end, :, :), 2*pi);
    offsets = cat(3, zeros(1, n_frequencies, 1), offsets); % zero padding since offset is 0 for first chunk
    offsets(:,:,end) = [];
    
    % Offset is cumulative among the rows.
    offsets = cumsum(offsets, 1);
    offsets = mod(offsets, 2*pi);
    phase = phase + offsets;
    
    % Put back in original shape
    phase = mod(phase, 2.0 * pi);
    phase = reshape(permute(phase,[2,1,3]), [n_frequencies, length])';
    
    % Remove padding if added it
    if remainder > 0
        phase(n_samples+1:end, :) = [];
    end
    
end

% Interpolates a signal from n_frames to n_samples
%
% Important: For upsampling, the target number of samples must be divisible by the number of input frames
function outputs = resample(inputs, n_samples, method)

    % Add endpoint for interpolation of last frame
    inputs = [inputs; inputs(end, :)];
    n_frames = size(inputs, 1);
    n_intervals = n_frames-1;
    
    % Linear interpolation
    if strcmp(method, 'linear')
        
        outputs = interp1(inputs, 1:(n_intervals / n_samples):n_frames, method);
        % Remove endpoint
        outputs = outputs(1:end-1, :);
        
    % 50% overlapping hann windows
    elseif strcmp(method, 'window')
        
        % Constant overlap-add, half overlapping windows
        hop_size = floor(n_samples / n_intervals);
        window_length = 2 * hop_size;
        window = hann(window_length, 'periodic')';
        
        % Add dimension for windowing and broadcast multiply
        x = reshape(inputs, [size(inputs, 1), 1, size(inputs, 2)]);
        x_windowed = x .* window;
        
        % Perform overlap and add
        x = overlap_and_add(x_windowed, hop_size);
        
        % Trim the rise and fall of the first and last window
        outputs = x(hop_size+1:end-hop_size,:);
        
    end
    
end

function signal = overlap_and_add(signal, frame_step)
    
    % Window length
    frame_length = size(signal, 2);
    
    % Number of input frames + endpoint
    frames = size(signal, 1);
    
    % Number of harmonics
    channels = size(signal, 3);
    
    % Compute output length
    output_length = frame_length + frame_step * (frames - 1);
    
    % Compute number of segments per frame (always 2 for 50% overlap and add)
    segments = ceil(frame_length / frame_step);

    % Add zero padding according to number of segments
    signal = cat(1, signal, zeros(segments, size(signal, 2), size(signal, 3)));
    
    % Reshape signal to split windows in segments
    signal = permute(reshape(permute(signal, [2, 1, 3]), [frame_step, segments , size(signal, 1), channels]), [2, 1, 3, 4]);
    signal = permute(signal, [3, 2, 1, 4]);
    
    % Reshape signal to concatenate segments to windows and truncate padding
    signal = reshape(permute(signal, [1, 3, 2, 4]), [size(signal, 1) * segments, frame_step, channels]);
    signal = signal(1:end-2, :, :);
    
    % 50%-OVERLAP: Reshape signal to shift the second segment by 1 frame
    signal = permute(reshape(permute(signal, [2, 1, 3]), [frame_step, frames + segments - 1, segments, channels]), [2, 1, 3, 4]);
    
    % ADD: Sum first segment with shifted second segment
    signal = sum(signal, 3);
    signal = reshape(signal, [size(signal, 1), size(signal, 2), size(signal, 4)]);
    
    % Flatten the array to the shape [n_samples, n_harmonics]
    signal = reshape(permute(signal, [2, 1, 3]), [(frames + segments - 1) * frame_step, channels]);
    
    % Truncate to final length (no effect for 50% overlap and add)
    signal = signal(1:output_length, :);
    
end

function plot_controls(amplitudes, harmonic_distribution, f0)
    
    % figure('Name', 'Synth Controls');
    t = tiledlayout(3,1);
    nexttile;
    plot(amplitudes);
    title('Amplitudes');
    ylabel('amplitude');
    nexttile;
    plot(harmonic_distribution);
    title('Harmonic Distribution');
    ylabel('amplitude');
    nexttile;
    plot(f0);
    title('Fundamental Frequency');
    ylabel('frequency');
    xlabel(t,'samples');
    t.TileSpacing = 'none';
    
end