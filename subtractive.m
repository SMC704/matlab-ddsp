function out = subtractive(n_samples, magnitudes, color)
% function [out, b] = subtractive(n_samples, magnitudes, color, ir_coeffs, recalculate_ir)

% magnitudes: row = frames, column = freq responses
    % magnitudes should be 65
    
%     normalize magnitudes
%     initial_bias = 1;
    
%     optional; colab examplees do not use it
%     magnitudes = scale_fn(magnitudes + initial_bias);
    
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

    NFFT = 2 * (n_samples - 1);

    noise_freq = real(fft(signal, NFFT));
    noise_freq_half = noise_freq(1:end/2+1);
    
    mag_rel_bin_size = ceil(double(n_samples)/size(magnitudes,1));
    
    mag_rescaled = zeros(size(magnitudes,1)*mag_rel_bin_size,1);
    
    for m = 1:size(magnitudes,1)
        for n = 1:mag_rel_bin_size
           mag_rescaled(n*m,1) = magnitudes(n,1);
        end
    end
    
    mag_rescaled = mag_rescaled(1:n_samples);
    
    sub_freq = noise_freq_half .* mag_rescaled;

    sub = real(ifft(sub_freq,n_samples*2));
    sub = sub(1:end/2);
    
    sub = rescale(sub(1:n_samples),-1,1);
    
    out = zeros(4096,1);
    out(1:n_samples) = sub;
    
end

function y = scale_fn(x)
    
    exponent = 10.0;
    max_value = 2.0;
    threshold = 1e-7;
    
    y = max_value * (1./(1+exp(-x))).^log(exponent) + threshold;
end