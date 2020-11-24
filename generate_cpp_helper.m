%% Script for generating cpp functions for both subtractive and additive

a = subtractive(1024, 1024, zeros(1024,1));
[b, p] = additive(int32(1024), 44100, zeros(4096,1), zeros(50,1), ones(4096,1)*440, zeros(50,1));