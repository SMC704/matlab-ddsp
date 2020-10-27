classdef plugin < audioPlugin
    properties
        Pitch = 0;
        Noise_Level = 1.0;
        Add_Level = 1.0;
    end
    properties (Constant)
        PluginInterface = ...
            audioPluginInterface( ...
                audioPluginParameter('Noise_Level', ...
                'DisplayName', 'Noise Synth', ...
                'Label', '', ...
                'Mapping', {'lin', 0.0, 1.0}), ...
                audioPluginParameter('Add_Level', ...
                'DisplayName', 'Additive Synth', ...
                'Label', '', ...
                'Mapping', {'lin', 0.0, 1.0}));
    end
    methods
        function out = process(plugin,in)
            audio = in(:,1);
            fs = plugin.getSampleRate();
            buffer_size = size(in);
            buffer_size = buffer_size(1);
            out = zeros(size(in));
            
            % generate noise
            window_size = 256;
            magnitudes = getMagnitudes(audio, window_size); 
            noise = subtractive(buffer_size, window_size, magnitudes)'; 
            out = out + noise(1:buffer_size)*plugin.Noise_Level;
            
            % pitch track only if over threshold
            if rms(audio) > 0.01
                plugin.Pitch = getPitch(audio, fs);
                p = ones(buffer_size, 1)*plugin.Pitch;
                n_harmonics = 30;
                harmonic_distribution = linspace(-2.0, 2.0, buffer_size)' + linspace(3.0, -3.0, n_harmonics);
                amplitude = ones(1024, 1);
                audio = additive(buffer_size, fs, amplitude, harmonic_distribution, p);
                out = out + audio*plugin.Add_Level;
            end
        end
    end
end