clc; clear all; close all;

[x(:, 1), sr] = audioread('../Results/t1.wav');
[x(:, 2), sr] = audioread('../Results/t2.wav');
[x(:, 3), sr] = audioread('../Results/t3.wav');
[x(:, 4), sr] = audioread('../Results/t4.wav');
NumMic = 4;
BeamAng = 0 : 5 : 360;
MicPos = [0, 0.02, 0.04, 0.06; 0, 0, 0, 0];

[DAS_Spectrum, F] = DAS_Localize(x, sr, BeamAng, MicPos);
[MVDR_Spectrum, F] = MVDR_Localize(x, sr, BeamAng, MicPos, 10 ^ -5);
[MPDR_Spectrum, F] = MPDR_Localize(x, sr, BeamAng, MicPos, 10 ^ -5);
[MUSIC_Spectrum, F] = MUSIC_Localize(x, sr, BeamAng, 1, MicPos);

% Plot
figure(1)
contourf(BeamAng, F, DAS_Spectrum)
title('DAS')
xlabel('Angle (degree)')
ylabel('Frequency (Hz)')

figure(2)
contourf(BeamAng, F, MVDR_Spectrum)
title('MVDR')
xlabel('Angle (degree)')
ylabel('Frequency (Hz)')

figure(3)
contourf(BeamAng, F, MPDR_Spectrum)
title('MPDR')
xlabel('Angle (degree)')
ylabel('Frequency (Hz)')

figure(4)
contourf(BeamAng, F, MUSIC_Spectrum)
title('MUSIC')
xlabel('Angle (degree)')
ylabel('Frequency (Hz)')