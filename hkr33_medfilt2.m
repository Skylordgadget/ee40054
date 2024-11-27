function filtered_img = hkr33_medfilt2(img_pad, filter_size)
    img_pad = double(img_pad); % convert to double  
    
    [M_pad, N_pad] = size(img_pad);
    
    % get the length and width of the image
    M = M_pad - filter_size - 1; N = N_pad - filter_size - 1; 
    
    % initialise an empty array for the filtered image
    filtered_img = zeros(M,N,'like',img_pad);
    
    % loop over the image
    for i = 1:M
        for j = 1:N
            % extract the window around the coordinates i and j
            window = img_pad(i:(i+filter_size-1),j:(j+filter_size-1));
            % set the target pixel as the median
            filtered_img(i,j) = median(window, 'all');
        end
    end
end