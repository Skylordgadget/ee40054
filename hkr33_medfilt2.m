function filtered_img = hkr33_medfilt2(img, K, L)
    img = double(img); % convert to double  

    [M, N] = size(img); % get the length and width of the image

    % compute the padding length and width
    pad_const = int16(2);
    K_pad = double(idivide(int16(K), pad_const)); 
    L_pad = double(idivide(int16(L), pad_const));

    % pad the image borders with zeros
    img_pad = padarray(img,[K_pad L_pad],0,'both');

    filtered_img = zeros(M,N,'like',img);

    for i = 1:M
        for j = 1:N
            img_part = img_pad(i:(i+K-1),j:(j+L-1));
            median(img_part);
            filtered_img(i,j) = median(img_part, 'all');
        end
    end
end