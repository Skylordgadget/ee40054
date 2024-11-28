function filtered_img = hkr33_truncated_median(img, kernel_size, iterations)
    img = double(img); % Convert to double for computations

    [M, N] = size(img); % Get the dimensions of the image

    % Compute the padding length and width
    img_pad = hkr33_pad(img,[kernel_size kernel_size]);

    filtered_img = zeros(M, N, 'like', img);

    for i = 1:M
        for j = 1:N
            % Extract the local neighborhood (kernel_size x kernel_size window)
            window = img_pad(i:(i+kernel_size-1), j:(j+kernel_size-1));
            
            med = median(window,"all");
            % Roy Davies technique
            for k = 1:iterations % number of times to truncate
                % calculate difference in pixel intensites for the 
                % min and max
                min_diff = med - min(window,[],"all");
                max_diff = max(window,[],"all") - med;
                
                % depending on which is larger the intensities are skewed
                % in either direction
                if (min_diff < max_diff)
                    % skewed left, so truncate higher values
                    window = window(window <= med + min_diff);
                else
                    % skewed right, so truncate lower values
                    window = window(window >= med - max_diff);
                end
        
            end
            
            % recalculate the median
            filtered_img(i,j) = median(window,"all");
        end
    end
end