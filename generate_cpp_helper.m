%% Script for generating cpp functions for both subtractive and additive

% Subtractive
n_samples = 4096;
% magnitudes = ones(65,1);
magnitudes = linspace(1,0,65)';
% signal = rand(n_samples+65, 1) * 2 - 1;

% [a, coeffs] = subtractive(n_samples, magnitudes, 0, zeros(1, 129), true);
color = 0;
initial_bias = 1;
[a] = subtractive(n_samples, magnitudes, color, initial_bias);
% soundsc(a,44100);

% Additive
n_samples = 4096;
sample_rate = 44100;
amplitudes = ones(4096,1);
n_harmonics = 60;
harmonic_distribution = [1; zeros(59,1)];
f0 = ones(4096,1)*500;
prev_phases = zeros(60,1);
shift = 0;
stretch = 0;

[b, p] = additive(n_samples, sample_rate, amplitudes, n_harmonics, harmonic_distribution, f0, prev_phases, shift, stretch);

% buffer = zeros(4096,1);
% write_pointer = int32(0);
% [audio_out, buffer, write_pointer, phase_out] = chorus(n_samples, sample_rate, b, buffer, write_pointer, single(10), single(10), single(0));

f0_out = getPitch2(n_samples,b,sample_rate)

% soundsc(audio_out,sample_rate);

tiledlayout(1,3);
nexttile
plot(a)
nexttile
plot(abs(fft(a,1024)))
nexttile
plot(b)