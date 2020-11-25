% TESTING ADDITIVE SYNTH

% Replication of DDSP Tutorial 0

n_frames = 1000;
hop_size = 64;
n_samples = n_frames * hop_size;
sample_rate = 16000;

% Amplitude [n_samples, 1]
% Make amplitude linearly decay over time
amplitudes = linspace(1.0, -3.0, n_frames)';

% Harmonic Distribution [n_samples, n_harmonics]
% Make harmonics decrease linearly with frequency
n_harmonics = 30;
harmonic_distribution = linspace(-2.0, 2.0, n_frames)' + linspace(3.0, -3.0, n_harmonics);

% Fundamental frequency in Hz [n_samples, 1]
f0 = 440 * ones(n_frames, 1);

prev_phases = zeros(1, n_harmonics);

% Plot raw inputs
figure('Name', 'Raw Inputs');
t = tiledlayout(3,1);
nexttile;
plot(amplitudes);
title('Amplitudes');
ylabel('amplitude');
nexttile;
plot(harmonic_distribution);
title('Harmonic Distribution');
ylabel('amplitude');
nexttile;
plot(f0);
title('Fundamental Frequency');
ylabel('frequency');
xlabel(t,'samples');
t.TileSpacing = 'none';

% Synthesize audio
audio = additive(n_samples, sample_rate, amplitudes, harmonic_distribution, f0, prev_phases, 0, 0);
soundsc(audio, sample_rate);