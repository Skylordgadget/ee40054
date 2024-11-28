function butterworth = hkr33_butterworth(kernel_size, cutoff_freq, filter_order, high_pass)

    if nargin < 4 || isempty(high_pass)
        high_pass = false;
    end

    % Generate spatial coordinates
    half_size = floor(kernel_size / 2);
    [x, y] = meshgrid(-half_size:half_size, -half_size:half_size);
    distance = sqrt(x.^2 + y.^2);
    
    % Normalized distance (relative to the size of the kernel)
    normalized_distance = distance / (half_size * 2);
    
    % Butterworth filter formula
    butterworth_kernel = 1 ./ (1 + (normalized_distance / cutoff_freq).^(2 * filter_order));
    
    if (high_pass) 
        butterworth_kernel = 1 - butterworth_kernel;
    end

    % Normalize the kernel to ensure it sums to 1
    butterworth = butterworth_kernel / sum(butterworth_kernel(:));
end