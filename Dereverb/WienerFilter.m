function y = WienerFilter(x, fs, MicPos, BeamAng)
    %---------------------------------------------------------------------%
    %                             Input
    %       x: reverb signals which have size (M, l), 
    %          where M stands for number of mic and l for length of signals
    %      fs: sampling rate
    %  MicPos: mic position in 2D has size (M, 2)
    % BeamAng: beamforming angle for MVDR
    % 
    %
    %                             Output
    %       y: desird signal
    %---------------------------------------------------------------------%
    
    % Parameters
    c = 343;  %sound speed
    eps = 10e-8;  % diagonal loading
    M = size(x, 1);

    % define analysis parameters
    win  = 'hanning'; % window type
    wlen = 512;       % window length (recomended to be power of 2)
    hop  = 128;       % hop size (recomended to be power of 2)
    nfft = 1024;      % number of fft points (recomended to be power of 2)
    
    % STFT
    for m = 1:M
        [X{m}, Freqs, Frames] = stft(x(m, :), win, wlen, hop, nfft, fs);
    end
    nFreqs  = size(Freqs, 2);
    nFrames = size(Frames, 2);

    
    % Main
    kappa = [cosd(BeamAng) sind(BeamAng)];
    for k = 1 : nFreqs
        k
        % Initialize
        gamma_vv = zeros(M, M);
        inv_gamma = zeros(M, M);
        Rxx = zeros(M, M);
        % ---------------------- MVDR: time-invariant -------------------------
        wavnum = 2 * pi * Freqs(k) / c;  % wave number
        A = exp(1i * wavnum * kappa * MicPos).'; % manifold vector
        % gamma_vv
        for i = 1:M
            for j = 1:M
                gamma_vv(i, j) = sinc(wavnum * norm(MicPos(:, i) - MicPos(:, j)));
            end
        end
        % optimal weight of MVDR
        inv_gamma = inv(gamma_vv + eps * eye(M, M));
        W_MVDR = inv_gamma * A / (A' * inv_gamma * A);
        % ------------------- Rxx: average of frames ---------------------
        matX = [];
        for n = 1:nFrames
            vecX = [];
            for m = 1 : M
                vecX = [vecX; X{m}(k, n)];
            end
            Rxx = Rxx + vecX * vecX';
            matX = [matX, vecX];
        end
        Rxx = Rxx / nFrames;
        % ----------------------- Wiener Filter ---------------------------
        % (1) estimate fi_noise (EVD-based Approach) 
        eigvalue = eig(Rxx * inv_gamma);
        fi_noise = (sum(eigvalue) - max(eigvalue)) / (M - 1);
        
        % (2) estimate fi_signal_out and fi_noise_out
        fi_noise_out = abs(fi_noise / (A' * inv_gamma * A));
        fi_signal_out = abs(W_MVDR' * (Rxx - fi_noise * gamma_vv) * W_MVDR);

        % (3) snr and postfilter
        snr = fi_signal_out / (fi_signal_out + fi_noise_out);
        if(snr < 0.1), snr = 0.1; end
        Y(k, :) = snr * W_MVDR' * matX;
    end

    % ISTFT
    % desired signal
    [y, t] = istft(Y, win, wlen, hop, nfft, fs);
end