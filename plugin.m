classdef plugin < audioPlugin
    properties
        Pitch = 10;
    end
    properties (Constant)
        PluginInterface = audioPluginInterface( ...
            audioPluginParameter("Pitch", ...
                "Label","Hz", ...
                "Mapping",{"lin",10,10000}))
    end
    methods
        function out = process(plugin,in)
            audio = in(:,1);
            fs = plugin.getSampleRate();
            plugin.Pitch = getPitch(audio, fs);
            buffersize = size(in);
            n = 0:1:(buffersize(1))-1;
            t = n/fs;
            y = sawtooth(2*pi*plugin.Pitch*t)';
            out = y;
        end
    end
end