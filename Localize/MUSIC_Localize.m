function [Spectrum, F] = MUSIC_Localize(x, sr, BeamAng, NumSor, MicPos)  
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
    buf2 = zeros(length(BeamAng));
    for f = 1 : length(F)
        % Wave number
        WaveNum = 2 * pi * F(f) / c;
        
        % Correlation Matrix
        buf1(:, :) = X(:, f, :);
        R = buf1 * buf1' / length(T);
        [EigVec, EigVal] = eig(R);
        Noise_Subspace = EigVec(:, 1 : NumMic - NumSor);
        Tmp = Noise_Subspace * Noise_Subspace';
        
        for i = 1 : length(BeamAng)
            % Manifold Matrix
            A = exp(- 1i * WaveNum * MicPos.' * kappa(:, i));
            buf2(i) = abs(1 / (A' * Tmp * A));
        end
        Spectrum(f, :) = buf2 / max(buf2);
    end
end