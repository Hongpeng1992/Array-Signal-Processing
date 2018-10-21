function y = MINT(x, fs, h)
    %---------------------------------------------------------------------%
    %                             Input
    %       x: reverb signals which have size (M, x_len), 
    %          where M stands for number of mic and x_len for length of 
    %          signal
    %      fs: sampling rate
    %       h: impulse response which have size (M, h_len)
    %
    %                             Output
    %       y: desird signal
    %---------------------------------------------------------------------%

    %
    [M, h_len] = size(h);
    H = convmtx(h(1, :).', h_len);
    tap_len = size(H, 2);
    for m = 2 : M
        Tmp = convmtx(h(m, :).', h_len);
        H = [H Tmp];
    end

    %
    G = pinv(H) * [1; zeros(size(H, 1) - 1, 1)];
    for m = 1 : M
        front = tap_len * (m - 1) + 1;
        g = G(front : front + tap_len - 1, 1);
        channel(m, :) = conv(g, x(m, :));
    end
    y = sum(channel);
end
    