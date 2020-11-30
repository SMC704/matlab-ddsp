function [out, b] = subtractive(n_samples, magnitudes, color, ir_coeffs, recalculate_ir)
    % magnitudes: row = frames, column = freq responses
    % magnitudes should be 65
    
%     normalize magnitudes
    initial_bias = 1;
    
%     optional; colab examplees do not use it
    magnitudes = scale_fn(magnitudes + initial_bias);
    
    % generate white noise
    white_n = dsp.ColoredNoise(0, 4161, 1);
    brown_n = dsp.ColoredNoise(2, 4161, 1);
    violet_n = dsp.ColoredNoise(-1.99, 4161, 1);

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
%     signal = rand(n_samples, 1) * 2 - 1;
    
    signal = signal(1:n_samples+65);

    n_freqs = size(magnitudes, 1);
    ir_size = 2 * (n_freqs - 1);
    
    norm_freq = linspace(0,1,n_freqs-1);
    
    b = zeros(1, ir_size+1);
    
    if recalculate_ir
        b(1:ir_size+1) = firls(ir_size,norm_freq, magnitudes(1:end-1));
    else
        b(1:ir_size+1) = ir_coeffs(1:ir_size+1);
    end
    filtered_signal = filter(b, 1, signal);
    out = zeros(4096,1);
%     out(1:n_samples) = filtered_signal(66:n_samples+65);
    out(1:n_samples) = filtered_signal(66:n_samples+65);


end

function y = scale_fn(x)
    
    exponent = 10.0;
    max_value = 2.0;
    threshold = 1e-7;
    
    y = max_value * (1./(1+exp(-x))).^log(exponent) + threshold;
end