function indices = hkr33_zigzag(img_size, K)
    validateattributes(img_size, {'numeric'}, {'size', [1, 2]})
    indices = {};
    M = img_size(1); N = img_size(2);

    K_pad = floor(K / 2);
    row = 0;
    for i = (K_pad+1):M-K_pad
        coordinates = {};
        for j = (K_pad+1):N-K_pad
            coordinates{end+1} = [i,j];
        end

        if mod(row,2) == 0
            coordinates = flip(coordinates);
        end

        indices = cat(2,indices,coordinates);
        row = row + 1;
    end
end