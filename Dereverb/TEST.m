clear , close all; clc

%% MINT
M = 2;
fs = 8000;
Tmp = load('For_MINT/x.mat');
x = Tmp.x;
Tmp = load('For_MINT/h.mat');
h = Tmp.h;
d = MINT(x, fs, h);

%% Wiener Filter
% M = 7;
% beta = 0.8;
% for m = 1:M
%     [Tmp, fs] = audioread(['Reverb_Signal_Example/Speech_ISM_', num2str(beta), '_', num2str(m), '.wav']);
%     x(m, :) = Tmp(1 : 30 * fs);
% end
% MicPos = [3.95, 2.35; 3.95, 2.40; 3.95, 2.45; 3.95, 2.50; 3.95, 2.55; 3.95, 2.60; 3.95, 2.65].';
% BeamAng = -90;

% d = WienerFilter(x, fs, MicPos, BeamAng);



%% NDLP
% M = 7;
% beta = 0.8;
% for m = 1:M
%     [Tmp, fs] = audioread(['Reverb_Signal_Example/Speech_ISM_', num2str(beta), '_', num2str(m), '.wav']);
%     x(m, :) = Tmp(1 : 30 * fs);
% end
% L = 20;
% delay = 2;
% 
% d = NDLP(x, fs, L, delay);

%% AdaptDLP
% M = 7;
% beta = 0.8;
% for m = 1:M
%     [Tmp, fs] = audioread(['Reverb_Signal_Example/Speech_ISM_', num2str(beta), '_', num2str(m), '.wav']);
%     x(m, :) = Tmp(1 : 30 * fs);
% end
% L = 20;
% delay = 2;

% d = AdaptDLP(x, fs, L, delay, lambda);


%% normalize & write audio
d = d / max(abs(d));
audiowrite('TestAudio.wav', d, fs);