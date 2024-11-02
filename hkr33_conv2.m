function filtered_img = hkr33_conv2(img, kernel)
    img = double(img); kernel = double(kernel); % convert to double  

    [M, N] = size(img); % get the length and width of the image
    [K, L] = size(kernel); % get the length and width of the kernel

    % compute the padding length and width
    pad_const = int16(2);
    K_pad = double(idivide(int16(K), pad_const)); 
    L_pad = double(idivide(int16(L), pad_const));

    % pad the image borders with zeros
    img_pad = padarray(img,[K_pad L_pad],0,'both');

    filtered_img = zeros(M,N,'like',img);

    for i = 1:M
        for j = 1:N
            filtered_img(i,j) = sum(img_pad(i:(i+K-1),j:(j+L-1)).*kernel,'all');
        end
    end
end