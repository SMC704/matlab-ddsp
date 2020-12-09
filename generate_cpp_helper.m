%% Script for generating cpp functions for both subtractive and additive
n_samples = 4096;
% [a,fs] = audioread("Utanmyra.wav");
% a = a(3000:end,1);

fs = 44100;
s = n_samples/fs;
t = 0:1/fs:s;
a = sin(2*pi*440*t);
a = a(1:n_samples)';

f0_p = getPitch(n_samples,a,fs);

f0_in = ones(100,1) * f0_p;
f0_midi = scale_f0(f0_in,true);
f0_out = scale_f0(f0_midi,false);

ld = compute_loudness(n_samples, a, sample_rate);
amplitude = 10.^(ld / 20);

magnitudes = linspace(1,0,65)';

% [a, coeffs] = subtractive(n_samples, magnitudes, 0, zeros(1, 129), true);
color = 0;
initial_bias = 1;
[a] = subtractive(n_samples, magnitudes, color, initial_bias);
% soundsc(a,44100);

% Additive
amplitudes = ones(4096,1)*-1.8;
n_harmonics = 50;
harmonic_distribution = ones(60,1)*0.5;
f0 = ones(4096,1)*500;
prev_phases = zeros(60,1);
shift = 0;
stretch = 0;

[b, p] = additive(n_samples, sample_rate, amplitudes, n_harmonics, harmonic_distribution, f0, prev_phases, shift, stretch);

% buffer = zeros(4096,1);
% write_pointer = int32(0);
% [audio_out, buffer, write_pointer, phase_out] = chorus(n_samples, sample_rate, b, buffer, write_pointer, single(10), single(10), single(0));

soundsc(b,sample_rate);

tiledlayout(1,3);
nexttile
plot(ld)
title("Loudness")
nexttile
plot(f0_midi*127)
title("f0 midi");
nexttile
plot(b)