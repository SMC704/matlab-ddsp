classdef ddsp_synth < audioPlugin
    properties
        Pitch = 0;
        Noise_Level = 1.0;
        Add_Level = 1.0;
        N_Harmonics = 5;
        Hw1 = 1.0;
        Hw2 = 1.0;
        Hw3 = 1.0;
        Hw4 = 1.0;
        Hw5 = 1.0;
        prev_phases = 0;
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
                'Mapping', {'lin', 0.0, 1.0}), ...
                audioPluginParameter('N_Harmonics', ...
                'DisplayName', 'Number of harmonics', ...
                'Label', '', ...
                'Mapping', {'int', 1, 40}), ...
                audioPluginParameter('Hw1', ...
                'DisplayName', 'First harmonic weight', ...
                'Label', '', ...
                'Mapping', {'lin', 0.0, 10.0}), ...
                audioPluginParameter('Hw2', ...
                'DisplayName', 'Second harmonic weight', ...
                'Label', '', ...
                'Mapping', {'lin', 0.0, 10.0}), ...
                audioPluginParameter('Hw3', ...
                'DisplayName', 'Third harmonic weight', ...
                'Label', '', ...
                'Mapping', {'lin', 0.0, 10.0}), ...
                audioPluginParameter('Hw4', ...
                'DisplayName', 'Fourth harmonic weight', ...
                'Label', '', ...
                'Mapping', {'lin', 0.0, 10.0}), ...
                audioPluginParameter('Hw5', ...
                'DisplayName', 'Fifth harmonic weight', ...
                'Label', '', ...
                'Mapping', {'lin', 0.0, 10.0}));
    end
    methods
        function out = process(plugin,in)
            audio = in(:,1);
            fs = plugin.getSampleRate();
            buffer_size = numel(audio);
            out = zeros(size(in));
            
            % generate noise
            window_size = 256;
            magnitudes = getMagnitudes(audio, window_size); 
            noise = subtractive(buffer_size, window_size, magnitudes)'; 
            y = noise(1:buffer_size);
            out(1:end,1) = out(1:end,1) + y*plugin.Noise_Level;
            out(1:end,2) = out(1:end,2) + y*plugin.Noise_Level;
            
            % pitch track only if over threshold
            if rms(audio) > 0.01
                plugin.Pitch = getPitch(audio, fs);
                p = ones(buffer_size, 1)*plugin.Pitch;
                n_harmonics = plugin.N_Harmonics;
                hw12 = linspace(plugin.Hw1, plugin.Hw2, ceil(n_harmonics/4));
                hw23 = linspace(plugin.Hw2, plugin.Hw3, ceil(n_harmonics/4));
                hw34 = linspace(plugin.Hw3, plugin.Hw4, ceil(n_harmonics/4));
                hw45 = linspace(plugin.Hw4, plugin.Hw5, ceil(n_harmonics/4));
                harmonic_weights = [hw12 hw23 hw34 hw45];
                harmonic_weights = harmonic_weights(1:n_harmonics);
                harmonic_distribution = ones(buffer_size, n_harmonics).*harmonic_weights;
                amplitude = ones(buffer_size, 1);
                [y, plugin.prev_phases] = additive(buffer_size, fs, amplitude, harmonic_distribution, p, plugin.prev_phases);
                out(1:end,1) = out(1:end,1) + y*plugin.Add_Level;
                out(1:end,2) = out(1:end,2) + y*plugin.Add_Level;
            end
        end
        
        function reset(plugin)
            plugin.prev_phases = zeros(1, plugin.N_Harmonics);
        end
        
        function set.N_Harmonics(plugin, val)
            plugin.N_Harmonics = val;
            plugin.prev_phases = zeros(1, val);
        end
           
    end
end