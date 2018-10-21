function d = AdaptDLP(x, fs, L, delay, lambda)
    %---------------------------------------------------------------------%
    %                             Input
    %      x: reverb signals which have size (M, l), 
    %         where M stands for number of mic and l for length of signals
    %     fs: sampling rate
    %      L: prediction order (filter order)
    %  delay: time of direct signal and early reflection
    % lambda: forgetting factor
    % 
    %
    %                             Output
    %      d: direct signals plus early reflection
    %---------------------------------------------------------------------%
    
    % Define analysis parameters
    win  = 'hanning'; % window type
    wlen = 512;       % window length (recomended to be power of 2)
    hop  = 128;       % hop size (recomended to be power of 2)
    nfft = 1024;      % number of fft points (recomended to be power of 2)

    % STFT
    M = size(x, 1);
    for m = 1:M
        [X{m}, Freq, frame] = stft(x(m, :), win, wlen, hop, nfft, fs);
    end
    nFreqs  = size(Freq, 2);
    nFrames = size(frame, 2);
    
    % Initialize
    D = zeros(size(X{1})); % desired signal in frequency domain

    % Main
    for k = 1 : nFreqs
        k
        % Initialize for each frequency
        P = eye(M*L) / (M * L);  % inverse of covariance
        W = zeros(M*L, 1); % predict coefficient

        for n = delay+L : nFrames
            % part of X
            partX = fliplr(X{1}(k, n-delay-L+1 : n-delay)).';
            for m = 2 : M
                partX = [partX; fliplr(X{m}(k, n-delay-L+1 : n-delay)).'];
            end

            % RLS
            K = P * conj(partX) / (lambda + partX.' * P * conj(partX));
            Y(k, n) = W.' * partX;
            D(k, n) = X{1}(k, n) - Y(k, n);
            W = W + K * D(k, n);
            P = lambda^-1 * (P - K * partX.' * P);
        end
    end
    
    % ISTFT
    [d, t] = istft(D, win, wlen, hop, nfft, fs);
end