%% Script for generating cpp functions for both subtractive and additive

a = subtractive(1024, 1024, zeros(1,1024));
[b, p] = additive(44100, zeros(1024,1), zeros(50,1), ones(1024,1)*440, zeros(50,1));
