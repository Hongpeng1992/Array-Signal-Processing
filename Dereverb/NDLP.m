function d = NDLP(x, fs, L, delay)
    %---------------------------------------------------------------------%
    %                             Input
    %      x: reverb signals which have size (M, l), 
    %         where M stands for number of mic and l for length of signals
    %     fs: sampling rate
    %      L: prediction order (filter order)
    %  delay: time of direct signal and early reflection
    % 
    %
    %                             Output
    %      d: direct signals plus early reflection
    %---------------------------------------------------------------------%

    % define analysis parameters
    win  = 'hanning'; % window type
    wlen = 512;       % window length (recomended to be power of 2)
    hop  = 128;       % hop size (recomended to be power of 2)
    nfft = 1024;      % number of fft points (recomended to be power of 2)

    %% STFT
    M = size(x, 1); % number of mic
    for m = 1:M
        [X{m}, Freq, frame] = stft(x(m, :), win, wlen, hop, nfft, fs);
    end
    nFreqs  = size(Freq, 2);
    nFrames = size(frame, 2);

    %% Initialize
    D = zeros(size(X{1})); % desired signal in frequency domain
    CovMat = zeros(M*L, M*L); % covariance matrix
    CovVec = zeros(M*L, 1); % covariance vector
    E = X{1} .^ 2; % energy
    minbound = 0.0001; % minimum energy bound for signal 
    E(E < minbound) = minbound;

    %% Main
    for k = 1 : nFreqs
        k
        % initialize for each frequency
        CovMat = zeros(M*L, M*L); % covariance matrix
        CovVec = zeros(M*L, 1); % covariance vector

        for n = delay+L : nFrames
            % part of X
            partX{n} = fliplr(X{1}(k, n-delay-L+1 : n-delay)).';
            for m = 2 : M
                partX{n} = [partX{n}; fliplr(X{m}(k, n-delay-L+1 : n-delay)).'];
            end

            % Covariance matrix
            CovMat = CovMat + conj(partX{n}) * partX{n}.' / E(k, n);

            % Covariance vector
            CovVec = CovVec + conj(partX{n}) * X{1}(k, n) / E(k, n);
        end

        % Filter Wieght
        W = pinv(CovMat) * CovVec;

        for n = delay+L : nFrames
            % Predcition
            Y(k, n) = W.' * partX{n};

            % Desirde signal
            D(k, n) = X{1}(k, n) - Y(k, n);

            % Energy
            E(k, n) = D(k, n) ^ 2;
            if E(k, n) < minbound, E(k, n) = minbound; end
        end
    end

    %% ISTFT
    % desired signal
    [d, t] = istft(D, win, wlen, hop, nfft, fs);
end