function filtered_img = hkr33_conv2(img, kernel, kernel_size)
    img = double(img); kernel = double(kernel); % convert to double  
    
    % get the length and width of the image and kernel
    [M, N] = size(img); 
    
    % pad the image with zeros
    img_pad = hkr33_pad(img,[kernel_size, kernel_size]);
    
    % initialise an empty array for the filtered image
    filtered_img = zeros(M,N,'like',img);

    % loop over the image
    for i = 1:M
        for j = 1:N
            % extract the window around the coordinates i and j
            window = img_pad(i:(i+kernel_size-1),j:(j+kernel_size-1));
            % multiply and sum the window and the kernel
            filtered_img(i,j) = sum(window.*kernel,'all');
        end
    end
end