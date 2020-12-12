%% Script for generating cpp functions for both subtractive and additive
n_samples = 4096;
% [a,fs] = audioread("Utanmyra.wav");
% a = a(3000:end,1);

sample_rate = 44100;
s = n_samples/sample_rate;
t = 0:1/sample_rate:s;
a = sin(2*pi*440*t);
a = a(1:n_samples)';

f0_p = getPitch(n_samples,a,sample_rate);

f0_in = ones(100,1) * f0_p;
f0_midi = scale_f0(f0_in,true);
f0_out = scale_f0(f0_midi,false);

ld = compute_loudness(n_samples, a, sample_rate);
amplitude = 10.^(ld / 20);

% magnitudes = linspace(1,0,65)';
magnitudes = rand(65, 1)*2 - 1;

% [a, coeffs] = subtractive(n_samples, magnitudes, 0, zeros(1, 129), true);
color = 0;
initial_bias = -5;
[a] = subtractive(n_samples, magnitudes, color, initial_bias);
sound(a,44100);
plot(a)

% Additive
% amplitudes = rand(4096,1)*-4 -1;
amplitudes = ones(4096,1)*-2.27;
n_harmonics = 50;
harmonic_distribution = 6 - rand(60,1)*12;
f0 = ones(4096,1)*440;
prev_phases = zeros(60,1);
shift = 0;
stretch = 0;

[b1, p] = additive(n_samples, sample_rate, amplitudes, n_harmonics, harmonic_distribution, f0, prev_phases, shift, stretch);
f0 = zeros(4096,1);
[b2, p] = additive(n_samples, sample_rate, amplitudes, n_harmonics, harmonic_distribution, f0, p, shift, stretch);

% buffer = zeros(4096,1);
% write_pointer = int32(0);
% [audio_out, buffer, write_pointer, phase_out] = chorus(n_samples, sample_rate, b, buffer, write_pointer, single(10), single(10), single(0));

% sound(b1,sample_rate);
% sound(b2,sample_rate);
% 
% tiledlayout(2,2);
% nexttile
% plot(ld)
% title("Loudness")
% nexttile
% plot(f0_midi*127)
% title("f0 midi")
% nexttile
% plot(b1)
% title("Additive 440hz")
% nexttile
% plot(b2)
% title("Additive 0hz")