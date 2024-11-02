function [old, new] = hkr33_strip(indices, i, K)
    y = indices{i}(1); x = indices{i}(2);
    prev_y = indices{i-1}(1); prev_x = indices{i-1}(2);
    
    dir_y = y-prev_y; dir_x = x-prev_x;

    K_pad = floor(K / 2);

    old = {};
    new = {};
    if dir_y == 0
        for yy = (y-K_pad):(y+K_pad)
            old{end+1} = [yy, x - dir_x * (K_pad+1)];
            new{end+1} = [yy, x + dir_x * (K_pad)];
        end
    else
        for xx = (x-K_pad):(x+K_pad)
            old{end+1} = [y - dir_y * (K_pad+1), xx];
            new{end+1} = [y + dir_y * (K_pad), xx];
        end
    end
end