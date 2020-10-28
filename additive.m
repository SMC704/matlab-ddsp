% ADDITIVE SYNTH
%
% INPUTS:
%
% n_samples: int
% sample_rate: int
% amplitudes: Sample-wise oscillator peak amplitude. Shape: [n_samples, 1]
% harmonic distribution: Sample-wise harmonic amplitude variations. Shape. [n_samples, n_harmonics]
% f0: Sample-wise fundamental frequency in Hz. Shape: [n_samples, 1]
%
% RETURNS:
%
% Audio Signal
%
% TODO: using 50% overlapping hann windows

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
    % plot_controls(amplitudes, harmonic_distribution, f0);
    
    % Create harmonic amplitudes
    harmonic_amplitudes = amplitudes .* harmonic_distribution;
    
    % Convert frequency, Hz -> angular frequency, radians/sample
    harmonic_angular_frequencies = harmonic_frequencies * 2 * pi; %radiant/second
    harmonic_angular_frequencies = harmonic_angular_frequencies / sample_rate; %radiant/sample
    
    % Accumulate phase and synthesize
    phases = cumsum(harmonic_angular_frequencies);
    
    % If synthesized examples are longer than ~100k audio
    % samples, consider use angular_cumsum to avoid accumulating noticible phase
    % errors due to the limited precision of cumsum
    %
    % phases = angular_cumsum(harmonic_angular_frequencies, n_samples);
    
    % Convert to waveforms
    prev_phases = prev_phases(1, 1:n_harmonics);
    phases = phases+prev_phases;
    phases = mod(phases, 2*pi);
    wavs = sin(phases);
    last_phases = phases(end,:);
    audio = harmonic_amplitudes .* wavs;
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

function plot_controls(amplitudes, harmonic_distribution, f0)
    
%     figure('Name', 'Synth Controls');
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