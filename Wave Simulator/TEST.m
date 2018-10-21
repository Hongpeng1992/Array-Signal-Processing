clear, close all; clc;

[x, sr] = audioread('../Results/Speech_16k_30s.wav');
y = Propagate(x(1: sr * 5), sr, [127], [0, 0.02, 0.04, 0.06; 0, 0, 0, 0]);

audiowrite('../Results/t1.wav', y(:, 1), sr);
audiowrite('../Results/t2.wav', y(:, 2), sr);
audiowrite('../Results/t3.wav', y(:, 3), sr);
audiowrite('../Results/t4.wav', y(:, 4), sr);