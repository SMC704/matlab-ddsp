function [out] = subtractive(n_samples, window_size, magnitudes)
    % magnitudes: row = frames, column = freq responses
    signal = rand(1, n_samples) * 2 - 1;
    n_freqs = size(magnitudes, 2);
    ir_size = 2 * (n_freqs - 1);
    n_ir_frames = size(magnitudes, 1);
    
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
    audio_frames = buffer(signal, frame_size)';
    
    fft_size = 2^ceil(log2(ir_size + frame_size - 1));
    audio_fft = rfft(audio_frames, fft_size, 2);
    ir_fft = rfft(impulse_response, fft_size, 2);
    
    audio_ir_fft = audio_fft .* ir_fft;
    

    audio_frames_out = irfft(audio_ir_fft, fft_size, 2);
    out_size = n_ir_frames * frame_size + max(fft_size - hop_size, 0);
    out = zeros(1, out_size);
    for i=0:n_ir_frames-1
        out = out + [zeros(1, i*hop_size) audio_frames_out(i+1, :) zeros(1, out_size - fft_size - i * hop_size)];
    end
end