%% getPitch2
% parameters: n_samples (int32), input (double[4096]), fs (double)
% output: f0 (double)

function f0 = getPitch2(n_samples, input, fs)
    y = input(1:n_samples,1);
    window_length = size(y,1);
    NFFT = 2^nextpow2(2*window_length-1);
    max_detect_pitch = 4000;
    detect_range = [100, 4000];
    log_spaced_frequency = logspace(1,log10(min(fs/2-1,max_detect_pitch)),NFFT)';
    lin_spaced_frequency = linspace(0,fs/2,round(NFFT/2)+1)';
    w_band_edges = zeros(1,numel(detect_range));
    for i = 1:numel(detect_range)
        [~,w_band_edges(i)] = min(abs(log_spaced_frequency-detect_range(i)));
    end
    bw_temp = (log_spaced_frequency(3:end) - log_spaced_frequency(1:end-2))/2;
    bw = [bw_temp(1);bw_temp;bw_temp(end)]./NFFT;
    win = hamming(window_length);
    yw = y.*win;
    Y = fft(yw,NFFT);
    Y_half = Y(1:(NFFT/2)+1,1:1);
    Y_power = real(Y_half.*conj(Y_half));
    Y_log = interp1(lin_spaced_frequency, Y_power, log_spaced_frequency);
    Y_log = Y_log.*repmat(bw,1,1);
    [pks, locs] = findpeaks(Y_log);
    candidates_pks = pks > 10;
    candidates_locs = locs(candidates_pks);
    candidates = log_spaced_frequency(candidates_locs);
    if(size(candidates,1) < 1)
        f0 = -1;
    else
        f0 = candidates(1);
    end
end