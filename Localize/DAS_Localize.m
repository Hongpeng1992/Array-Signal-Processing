function [Spectrum, F] = DAS_Localize(x, sr, BeamAng, MicPos)    
    % Parameters
    c= 343;
    [~, NumMic] = size(MicPos);
    

    % STFT
    win  = 'hanning'; % window type
    wlen = 512;       % window length (recomended to be power of 2)
    hop  = 128;       % hop size (recomended to be power of 2)
    nfft = 1024;      % number of fft points (recomended to be power of 2)

    for i = 1 : NumMic
        [X(i, :, :), F, T] = stft(x(:, i), win, wlen, hop, nfft, sr);
    end


    % Main
    Spectrum = zeros(length(F), length(BeamAng));
    kappa = [cosd(BeamAng); sind(BeamAng)];
    buf1 = zeros(NumMic, length(T));
    buf2 = zeros(length(BeamAng), length(T));
    for f = 1 : length(F)
        % Wave number
        WaveNum = 2 * pi * F(f) / c;

        % Manifold Matrix
        A = exp(- 1i * WaveNum * MicPos.' * kappa);
        buf1(:, :) = X(:, f, :);
        buf2(:, :) = abs(A' * buf1);
        Spectrum(f, :) = mean(buf2 ./ max(buf2, [], 1), 2);   
    end
end