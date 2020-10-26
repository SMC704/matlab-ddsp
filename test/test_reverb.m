% % Test data ------------------ %
[audio, fs_a] = audioread("Snare.wav");
audio = audio(:,1);
[ir, fs_ir] = audioread("IR.wav");
ir = ir(:,1);
% % ---------------------------- %

audio_out = reverb(audio, ir); 

soundsc(audio_out, fs_a);

tiledlayout(3,1);
nexttile
plot(audio);
title("Audio in");
nexttile
plot(ir);
title("IR");
nexttile
plot(audio_out);
title("Audio out");