function filtered_img = hkr33_adaptive_weighted_median(img, K, W, c)
    img = double(img); % convert to double  

    [M, N] = size(img); % get the length and width of the image

    % compute the amount of pading needed either side of the image
    K_pad = floor(K / 2);

    % pad the image borders with zeros
    img_pad = hkr33_pad(img,[K, K]);

    % initialise an empty array for the filtered image
    filtered_img = zeros(M,N,'like',img);

    % make a meshgrid of the window
    [i, j] = meshgrid(1:K, 1:K);
    % compute the distance from the middle value at every point in the window
    d = sqrt((abs(i-(K_pad+1))).^2 + (abs(j-(K_pad+1))).^2);

    % loop over the image
    for i = 1:M
        for j = 1:N
            % extract the window around the coordinates i and j
            window = img_pad(i:(i+K-1),j:(j+K-1));

            % calculate the mean of the window with an in-built function
            m = mean(window,"all");
            
            % calculate the standard deviation of the window with an 
            % in-built function
            sigma = std(window,[],"all");
            
            % weigth reduction factor centred around the middle of the window
            weights = max(W - ((c.*d.*sigma))./m,0);
            % set the new pixel to be the weighted median
            filtered_img(i,j) = hkr33_weighted_median(window,weights);
        end
    end
end 