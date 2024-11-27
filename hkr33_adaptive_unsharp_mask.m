function filtered_img = hkr33_adaptive_unsharp_mask(img, filter_size, strength)
    [M, N] = size(img); % get the length and width of the image

    % compute the padding length and width
    pad_const = int16(2);
    K_pad = double(idivide(int16(filter_size), pad_const)); 
    n = filter_size*filter_size;
    % pad the image borders with zeros
    img_pad = padarray(img,[K_pad K_pad],0,'both');

    filtered_img = zeros(M,N,'like',img);
    k_img = zeros(M,N,'like',img);
    for i = 1:M
        for j = 1:N
        
            window = img_pad(i:(i+filter_size-1),j:(j+filter_size-1));
            m = mean(window,"all");
            
            sigma = sqrt(((sum(window-m,"all"))^2)/n);
            k_img(i,j) = sigma/m;
            %k_img(i,j) = sigma;
        end
    end

    k_img = normalize(k_img,"range");
    k_img(isnan(k_img)) = 0;
    
    for i = 1:M
        for j = 1:N

            window = img_pad(i:(i+filter_size-1),j:(j+filter_size-1));
            m = mean(window,"all");
   
          
          
            filtered_img(i,j) = m + strength*k_img(i,j)*(img(i,j)-m);
        end
    end
end