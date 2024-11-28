function [filtered_image] = adaptiveWeightedMedian(pad_img, filter_size, central_weight, scaling_constant)
    % Parameters
    padding = floor(filter_size / 2);
    image_rows = size(pad_img, 1) - 2 * padding;
    image_cols = size(pad_img, 2) - 2 * padding;
    filtered_image = zeros(image_rows, image_cols); % Initialize output image

    % Define the range of indices for i and j
    [i, j] = meshgrid(-padding:padding, -padding:padding);
    % Calculate distances for weights
    distance = sqrt(i.^2 + j.^2);

    % Convolution process
    for row = padding + 1 : image_rows + padding
        for col = padding + 1 : image_cols + padding
            % Extract the window around the current pixel
            filtWindow = pad_img(row - padding : row + padding, col - padding : col + padding);
            mean_val = mean(filtWindow(:));
            std_val = std(double(filtWindow(:)));
            
            % Calculate adaptive weights for the window
            weights = max(central_weight - ((scaling_constant .* distance .* std_val) / mean_val), 0);
            
            % Flatten filtWindow and weights to vectors
            pixelValues = filtWindow(:);
            weightValues = weights(:);

            % Sort pixel values and associated weights by pixel intensity
            [sortedPixels, sortIdx] = sort(pixelValues);
            sortedWeights = weightValues(sortIdx);
            
            % Calculate the cumulative sum of the weights
            cumWeights = cumsum(sortedWeights);
            totalWeight = sum(sortedWeights);

            % Find the weighted median
            medianIdx = find(cumWeights >= totalWeight / 2, 1, 'first');
            median_val = sortedPixels(medianIdx);
            
            % Assign the median value to the corresponding pixel in the output image
            filtered_image(row - padding, col - padding) = median_val;
        end
    end
    
    % Convert the filtered image to uint8 format for display
    filtered_image = uint8(filtered_image);
end
