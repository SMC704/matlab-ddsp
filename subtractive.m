function [out] = subtractive(n_samples, window_size, magnitudes)
    % magnitudes: row = frames, column = freq responses
    
    % normalize magnitudes
    initial_bias = -5;
    magnitudes = scale_fn(magnitudes + initial_bias);
    
    % generate white noise
    signal = rand(1, n_samples) * 2 - 1;
    
    n_freqs = size(magnitudes, 2);
    ir_size = 2 * (n_freqs - 1);
    n_ir_frames = size(magnitudes, 1);
    
    % get IR from provided FR
    impulse_response = irfft(magnitudes, ir_size, 2);

    if window_size <= 0 || window_size > ir_size
        window_size = ir_size;
    end
    window = hann(window_size);
    
    padding = ir_size - window_size;
    if padding > 0
        half_idx = floor((window_size + 1) / 2);
        window = [window(half_idx + 1:end); zeros(padding, 1); window(1:half_idx)];
    else
        window = fftshift(window);
    end
    
    window = repmat(window', n_ir_frames, 1);
    
    % apply hann window to IR
    impulse_response = window .* real(impulse_response);
    
    if padding > 0
        first_half_start = (ir_size - (half_idx - 1)) + 1;
        second_half_end = half_idx + 1;
        impulse_response = [impulse_response(:, first_half_start+1:end) impulse_response(:, 1:second_half_end)];
    else
        impulse_response = fftshift(impulse_response, 2);
    end
    
    frame_size = ceil(n_samples / n_ir_frames);
    hop_size = frame_size;
    
    % divide audio into number of frames (= number of rows from 'magnitudes'
    audio_frames = buffer(signal, frame_size)';
    
    fft_size = 2^ceil(log2(ir_size + frame_size - 1));
    
    % convolve audio with windowed IR <=> multiply in frequency domain
    audio_fft = rfft(audio_frames, fft_size, 2);
    ir_fft = rfft(impulse_response, fft_size, 2);
    audio_ir_fft = audio_fft .* ir_fft;
    
    % apply "overlap and add" to the resulting frames to get back to samples
    audio_frames_out = irfft(audio_ir_fft, fft_size, 2);
    out_size = n_ir_frames * frame_size + max(fft_size - hop_size, 0);
    out = zeros(1, out_size);
    for i=0:n_ir_frames-1
        out(i*hop_size + 1:i * hop_size + fft_size) = out(i*hop_size + 1:i * hop_size + fft_size) + audio_frames_out(i+1, :);
    end
end

function y = scale_fn(x)
    
    exponent = 10.0;
    max_value = 2.0;
    threshold = 1e-7;
    
    y = max_value * (1./(1+exp(-x))).^log(exponent) + threshold;
end