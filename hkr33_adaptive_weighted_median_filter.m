function filtered_img = hkr33_adaptive_weighted_median_filter(img, K, W, c)
    img = double(img); % convert to double  

    [M, N] = size(img); % get the length and width of the image

    % compute the padding length and width
    pad_const = int16(2);
    K_pad = double(idivide(int16(K), pad_const)); 

    % pad the image borders with zeros
    img_pad = padarray(img,[K_pad K_pad],0,'both');

    filtered_img = zeros(M,N,'like',img);
    n = K*K;
    [i, j] = meshgrid(1:K, 1:K);
    d = sqrt((abs(i-(K_pad+1))).^2 + (abs(j-(K_pad+1))).^2);

    for i = 1:M
        for j = 1:N
            window = img_pad(i:(i+K-1),j:(j+K-1));

            m = mean(window,"all");
            sigma = sqrt(((sum(window-m,"all"))^2)/n);
            
            x = ((c.*d.*sigma)./m);
            x(isnan(x)) = 0;
            weights = W - x;
           
            filtered_img(i,j) = hkr33_weighted_median(window,weights);
        end
    end
end 