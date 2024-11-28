function filtered_img = hkr33_erode_dilate(img, mask, erode)
    mask(mask==0) = NaN;
    % get the length and width of the image and kernel
    [M, N] = size(img); 
    [K, L] = size(mask);
        
    % pad the image with zeros
    img_pad = hkr33_pad(img,[K, L]);
    
    % initialise an empty array for the filtered image
    filtered_img = zeros(M,N,'like',img);

    for i = 1:M
        for j = 1:N
            % extract the window around the coordinates i and j
            window = img_pad(i:(i+K-1),j:(j+L-1));
            
            % the mask is an arbitrary sized square containing either real 
            % values or NaNs
            % the min and max functions ignore NaNs, allowing arbitrary shapes
            if erode
                result = min(window.*mask,[],"all"); 
            else
                result = max(window.*mask,[],"all");
            end
            filtered_img(i,j) = result;
        end
    end
end