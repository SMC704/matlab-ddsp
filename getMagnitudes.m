%% getMagnitudes 
% parameters: 1-channel audio, window_size
% output: n-d array of magnitudes

function magnitudes = getMagnitudes(audio, window_size)
    window_count = ceil(numel(audio) / window_size); 
    desired_length = window_count * window_size;
    padding_needed = desired_length - numel(audio);
    audio_padded = vertcat(audio,zeros(padding_needed, 1));
    magnitudes = zeros(window_count, window_size);
    start_pos = 1;
    end_pos = window_size;
    for n = 1:1:window_count
        magnitudes(n,:) = abs(fft(audio_padded(start_pos:end_pos)));
        start_pos = start_pos + window_size;
        end_pos = end_pos + window_size;
    end
    
%     magnitudes = [];
%     for n = 1:window_size:desired_length
%         magnitudes = [magnitudes abs(fft(audio_padded(n:n+window_size-1)))];
%     end
%     magnitudes = magnitudes';
end