% MATLAB Reimplementation of ddsp.spectral_ops.compute_loudness
function [loudness] = compute_loudness(n_samples, audio, sample_rate)
    x = audio(1:n_samples,1);
    NFFT = 2048;
    window_length = n_samples;
    window = hann(window_length);
    x_win = x.*window;
    X = fft(x_win, NFFT);
%     s = stft(x, sample_rate, 'Window', window, 'FFTLength', NFFT); 
    amplitude = abs(X);
    amin = 1e-20; 
    power_db = log10(max(amin, amplitude)) * 20;
    frequencies = real(fft(audio, NFFT*2));
    A_weighting = weightingFilter('A-weighting',sample_rate);
    freq_filtered = A_weighting(frequencies(1:NFFT));
    loudness = power_db;
    for i = 1:size(loudness,2)
        loudness(1:end,i) = loudness(1:end,i) + freq_filtered(1:end);
    end
    loudness = loudness - 20.7;
    LD_RANGE = 120;
    loudness = max(loudness, -LD_RANGE);
    loudness = mean(loudness,1);
end
