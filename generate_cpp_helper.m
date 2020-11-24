%% Script for generating cpp functions for both subtractive and additive

% Subtractive
n_samples = 4096;
% magnitudes = ones(65,1);
magnitudes = linspace(1,0,65)';
% signal = rand(n_samples+65, 1) * 2 - 1;

a = subtractive(n_samples, magnitudes, 0);

% Additive
n_samples = int32(4096);
sample_rate = 44100;
amplitudes = ones(4096,1);
harmonic_distribution = [1; ones(49,1)];
f0 = ones(4096,1)*500;
prev_phases = zeros(50,1);

[b, p] = additive(n_samples, sample_rate, amplitudes, harmonic_distribution, f0, prev_phases);

sound(a,sample_rate);

tiledlayout(1,3);
nexttile
plot(a)
nexttile
plot(abs(fft(a,1024)))
nexttile
plot(b)