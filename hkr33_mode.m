function filtered_img = hkr33_mode(img, filter_size)
    img = double(img); 
    
    % get the length and width of the image and kernel
    [M, N] = size(img); 
    
    % pad the image with zeros
    img_pad = hkr33_pad(img,[filter_size, filter_size]);
    
    % initialise an empty array for the filtered image
    filtered_img = zeros(M,N,'like',img);

    % loop over the image
    for i = 1:M
        for j = 1:N
            % extract the window around the coordinates i and j
            window = img_pad(i:(i+filter_size-1),j:(j+filter_size-1));
            % set the target pixel as the mode
            filtered_img(i,j) = mode(window,'all');
        end
    end
end