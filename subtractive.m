function out = subtractive(n_samples, magnitudes, color, initial_bias)
% function [out, b] = subtractive(n_samples, magnitudes, color, ir_coeffs, recalculate_ir)

% magnitudes: row = frames, column = freq responses
    % magnitudes should be 65

    magnitudes = scale_fn(magnitudes + initial_bias);
    
    % generate white noise
    white_n = dsp.ColoredNoise(0, 4096, 1);
    brown_n = dsp.ColoredNoise(2, 4096, 1);
    violet_n = dsp.ColoredNoise(-1.99, 4096, 1);

    white_noise = white_n();
    brown_noise = brown_n();
    violet_noise = violet_n();
    
    release(white_n);
    release(brown_n);
    release(violet_n);
    
    signal = (1 - abs(color))*white_noise;
    if (color > 0)
        signal = signal + color*violet_noise;
    end
    if (color < 0)
        signal = signal + abs(color)*brown_noise;
    end
    
    signal = signal(1:n_samples);
    signal = rescale(signal,-1,1);

    NFFT = 2^(nextpow2(n_samples));

    X = fft(signal, NFFT)/n_samples;
%     noise_freq = real(fft(signal, NFFT))/NFFT;
%     noise_freq_half = noise_freq(1:end/2+1);
    
    mag_rel_bin_size = ceil(double(n_samples)/size(magnitudes,1));
    
    mag_rescaled = zeros(size(magnitudes,1)*mag_rel_bin_size,1);
    
    for m = 1:size(magnitudes,1)
        for n = 1:mag_rel_bin_size
           mag_rescaled(n*m,1) = magnitudes(n,1);
        end
    end
    
    H = mag_rescaled(1:n_samples);
    
    X_conv = X .* H;

    sub = real(ifft(X_conv,n_samples));
    
    out = zeros(4096,1);
    out(1:n_samples) = sub;
    
end

function y = scale_fn(x)
    
    exponent = 10.0;
    max_value = 2.0;
    threshold = 1e-7;
    
    y = max_value * (1./(1+exp(-x))).^log(exponent) + threshold;

end