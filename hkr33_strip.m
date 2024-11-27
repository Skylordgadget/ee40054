function [old, new] = hkr33_strip(indices, i, K)
    % extract the current and previous indices
    y = indices{i}(1); x = indices{i}(2); % x and y of the current indicies
    % x and y of the previous indices 
    prev_y = indices{i-1}(1); prev_x = indices{i-1}(2);
    
    % determine the direction of movement
    dir_y = y-prev_y; dir_x = x-prev_x;

    K_pad = floor(K / 2);

    old = {};
    new = {};
    % check if the movement is horizontal (dir_y == 0) or vertical
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