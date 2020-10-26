%% Test getMagnitudes function

% % Test data ------------------ %
[audio, fs] = audioread("test/Snare.wav");
audio = audio(:,1);
% % ---------------------------- %

magnitudes = getMagnitudes(audio, 1024);

k = 1;
[rows, coloumns] = size(magnitudes);
for n = 1:1:coloumns
    plot(magnitudes(:,n),'color',rand(1,3))
    hold on
    k = k+1
end
