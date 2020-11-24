%% Script for generating cpp functions for both subtractive and additive

a = subtractive(1024, 1024, zeros(1024,1));


n_samples = int32(4096);
sample_rate = 44100;
amplitudes = ones(4096,1);
harmonic_distribution = [1; ones(49,1)];
f0 = ones(4096,1)*440;
prev_phases = zeros(50,1);


[b, p] = additive(n_samples, sample_rate, amplitudes, harmonic_distribution, f0, prev_phases);

soundsc(b,sample_rate);

tiledlayout(1,2);
nexttile
plot(a)
nexttile
plot(b)