classdef plugin < audioPlugin
    properties
        Pitch = 0;
    end
    methods
        function out = process(plugin,in)
            audio = in(:,1);
            fs = plugin.getSampleRate();
            buffer_size = size(in);
            buffer_size = buffer_size(1);
            out = zeros(size(in));
            
            % pitch track only if over threshold
            if rms(audio) > 0.01
                plugin.Pitch = getPitch(audio, fs);
                n = 0:1:(buffer_size)-1;
                t = n/fs;
                sine = sin(2*pi*plugin.Pitch*t)';
                out = out + sine*0.7;
            end
            
            % generate noise
            window_size = 256;
            magnitudes = getMagnitudes(audio, window_size); 
            noise = subtractive(buffer_size, window_size, magnitudes)'; 
            out = out + noise(1:buffer_size)*0.7;
        end
    end
end