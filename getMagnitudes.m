%% getMagnitudes 
% parameters: 1-channel audio, window_size
% output: n-d array of magnitudes

function magnitudes = getMagnitudes(audio, window_size)
    window_count = ceil(numel(audio) / window_size); 
    desired_length = window_count * window_size;
    padding_needed = desired_length - numel(audio);
    audio_padded = vertcat(audio,zeros(padding_needed, 1));
    magnitudes = [];
    for n = 1:window_size:desired_length
        magnitudes = [magnitudes abs(fft(audio_padded(n:n+window_size-1)))];
    end
end