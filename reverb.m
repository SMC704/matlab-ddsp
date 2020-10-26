%% Frequency Convolution Reverb for DDSP Synthesizer
% Arguments: audio, ir

function audio_out = reverb(audio, ir)
    % Use only 1st channel
    audio = audio(:,1);
    ir = ir(:,1);
    % Get size 
    ir_size = size(ir);
    
    % FFT the audio and impulse responses
    fft_size = (2.^ceil(log2(ir_size)));
    fft_size = fft_size(1);
    audio_fft = fft(audio, fft_size);
    ir_fft = fft(ir, fft_size);

    % Multiply the FFts 
    audio_ir_fft = audio_fft.*ir_fft;
    audio_out = ifft(audio_ir_fft, fft_size);

    % Compensate for group delay
    crop = 1 - ir_size;
    crop_start = ceil((ir_size - 1) / 2);
    crop_end = crop - crop_start;
    audio_out = audio_out(crop_start:-crop_end);
end

