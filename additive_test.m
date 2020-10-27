% TESTING ADDITIVE SYNTH

% Replication of DDSP Tutorial 0

n_samples = 64000;
sample_rate = 16000;

% Amplitude [n_samples, 1]
% Make amplitude linearly decay over time
amplitudes = linspace(1.0, -3.0, n_samples)';

% Harmonic Distribution [n_samples, n_harmonics]
% Make harmonics decrease linearly with frequency
n_harmonics = 30;
harmonic_distribution = linspace(-2.0, 2.0, n_samples)' + linspace(3.0, -3.0, n_harmonics);

% Fundamental frequency in Hz [n_samples, 1]
f0 = 440 * ones(n_samples, 1);

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
audio = additive(n_samples, sample_rate, amplitudes, harmonic_distribution, f0);
soundsc(audio, sample_rate);