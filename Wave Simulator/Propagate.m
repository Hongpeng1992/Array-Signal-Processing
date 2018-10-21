function y = propagate(x, sr, Ang, MicPos)
    % Parameters
    c = 343;  %sound speed
    [~, NumSor] = size(Ang);
    [~, NumMic] = size(MicPos);


    % STFT
    win  = 'hanning'; % window type
    wlen = 512;       % window length (recomended to be power of 2)
    hop  = 128;       % hop size (recomended to be power of 2)
    nfft = 1024;      % number of fft points (recomended to be power of 2)

    for i = 1 : NumSor
        [X(i, :, :), F, T] = stft(x(:, i), win, wlen, hop, nfft, sr);
    end


    % 3D point source propagation
    Y = zeros(NumMic, length(F), length(T));
    Tmp = zeros(NumSor, length(T));
    kappa = [cosd(Ang); sind(Ang)];
    
    for j = 1 : length(F)
        % Wave number
        WaveNum = 2 * pi * F(j) / c;

        % Manifold Matrix
        A = exp(- 1i * WaveNum * MicPos.' * kappa);

        % Propagate
        Tmp(:, :) = X(:, j, :);
        Y(:, j, :) = A * Tmp;
    end

    % ISTFT
    for i = 1 : NumMic
        [y(:, i), ~] = istft(squeeze(Y(i, :, :)), win, wlen, hop, nfft, sr);
    end
end