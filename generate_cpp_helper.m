%% Script for generating cpp functions for both subtractive and additive
n_samples = 4096;

sample_rate = 44100;
s = n_samples/sample_rate;
t = 0:1/sample_rate:s;
a = sin(2*pi*440*t);
a = a(1:n_samples)';

% Get pitch
f0_p = getPitch(n_samples,a,sample_rate);

% Scale f0
f0_in = ones(100,1) * f0_p;
f0_midi = scale_f0(f0_in,true);
f0_out = scale_f0(f0_midi,false);

% Compute loudness
ld = compute_loudness(n_samples, a, sample_rate);
amplitude = 10.^(ld / 20);

% Subtractive synth
magnitudes = rand(65, 1)*2 - 1;
color = 0;
initial_bias = -5;
[a] = subtractive(n_samples, magnitudes, color, initial_bias);

% Additive synth
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