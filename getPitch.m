%% getPitch
% parameters: 1-channel audio
% output: pitch in hz

function p = getPitch(audio,fs)
    p = pitch(audio, fs, ...
        "WindowLength",size(audio,1), ...
        "OverlapLength",0, ...
        "Range",[50,5000]);
end

