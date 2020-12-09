%% getPitch
% parameters: 1-channel audio
% output: pitch in hz

function f0 = getPitch(y,fs)
% 
%     p = pitch(audio, fs, ...
%         "WindowLength",size(audio,1), ...
%         "OverlapLength",0, ...
%         "Range",[100,2000], ...
%         "Method",'PEF');
      
    detect_range = [100,2000];
    window_length = size(y,1);
    max_detect_pitch = 4000;
    num_candidates = 1; % We could increase thes to maybe look at outliers
    min_peak_distance = 1;

    NFFT = 2^nextpow2(2*window_length-1);
    log_spaced_frequency = logspace(1,log10(min(fs/2-1,max_detect_pitch)),NFFT)';
    lin_spaced_frequency = linspace(0,fs/2,round(NFFT/2)+1)';
    w_band_edges = zeros(1,numel(detect_range));
    for i = 1:numel(detect_range)
        [~,w_band_edges(i)] = min(abs(log_spaced_frequency-detect_range(i)));
    end
    edge = w_band_edges;
    bw_temp = (log_spaced_frequency(3:end) - log_spaced_frequency(1:end-2))/2;
    bw = [bw_temp(1);bw_temp;bw_temp(end)]./NFFT;
    [a_filt, num_to_pad] = createPitchEstimationFilter(log_spaced_frequency');
    % Hamming window
    win = hamming(window_length);
    yw = y.*win;
    % Power spectrum
    Y = fft(yw,NFFT);
    Y_half = Y(1:(NFFT/2)+1,1:1);
    Y_power = real(Y_half.*conj(Y_half));
    % Interpolate onto log-frequency grid
    Y_log = interp1(lin_spaced_frequency, Y_power, log_spaced_frequency);
    % Weight bins by bandwidth
    Y_log = Y_log.*repmat(bw,1,1);
    Z = [zeros(num_to_pad(1),1);Y_log];
    % Cross correlation
    m = max(size(Z,1), size(a_filt,1));
    mxl = min(edge(end),m-1);
    m2 = min(2^nextpow2(2*m-1), NFFT*4);
    X = fft(Z,m2,1);
    Y = fft(a_filt,m2,1);
    c1 = real(ifft(X.*repmat(conj(Y),1,1),[],1));
    R = [c1(m2-mxl+(1:mxl),:); c1(1:mxl+1,:)];
    domain = R(edge(end)+1:end,:);
    % Peak-picking
    [~, locs] = getCandidates(domain,edge,num_candidates, min_peak_distance);
    
    f0 = log_spaced_frequency(locs);

    % Force pitch estimate inside band edges
    % Why though? 
    bE = detect_range;
    f0(f0<bE(1)) = bE(1);
    f0(f0>bE(end)) = bE(end);


end

function [PEF_filter, PEF_num_to_pad] = createPitchEstimationFilter(freq)
    K = 10;
    gamma = 1.8;
    num = round(numel(freq)/2);
    q = logspace(log10(0.5),log10(K+0.5),num);
    h = 1./(gamma - cos(2*pi*q));
    delta = diff([q(1),(q(1:end-1)+q(2:end))./2,q(end)]);
    beta = sum(h.*delta)/sum(delta);
    PEF_filter = (h-beta)';
    PEF_num_to_pad = find(q<1,1,'last');
end

function [peaks, locs] = getCandidates(domain,edge,num_candidates,peak_distance)
    num_col = size(domain,2);
    locs = zeros(num_col,num_candidates);
    peaks = zeros(num_col, num_candidates);
    lower = edge(1);
    upper = edge(end);
    
    for c = 1:num_col
        for b = 1:num_candidates
            [temp_peak, temp_loc] = max( domain(lower:upper,c) );
            idx_to_remove = max(temp_loc - peak_distance + lower, lower):min(temp_loc + peak_distance + lower, upper);
            domain(idx_to_remove,c) = nan;
            locs(c,b) = lower + temp_loc -1;
            peaks(c,b) = temp_peak;
        end
    end
end

