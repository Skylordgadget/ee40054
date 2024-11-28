function chebyshev = hkr33_chebyshev(kernel_size, cutoff_freq, ripple, high_pass)
    % default low-pass
    if nargin < 4 || isempty(high_pass)
        high_pass = false;
    end
    
    % generate spacial coordinates
    half_size = floor(kernel_size / 2); 
    [x, y] = meshgrid(-half_size:half_size, -half_size:half_size);
    distance = sqrt(x.^2 + y.^2);
    
    % normalised distance (relative to the kernel size)
    normalised_distance = distance / (half_size * 2);
    
    % Chebyshev Type I filter approximation in the spatial domain
    epsilon = sqrt(10^(ripple / 10) - 1); % ripple factor
    chebyshev_kernel = ...
        1 ./ sqrt(1 + epsilon^2 * (normalised_distance / cutoff_freq).^2);
    
    % Apply exponential factor to make it low-pass (spatial approximation)
    if (high_pass)
        chebyshev_kernel = 1 - chebyshev_kernel;
    end
    % if (high_pass)
    %     chebyshev_kernel(normalised_distance < cutoff_freq) = 0;
    % else 
    %     chebyshev_kernel(normalised_distance > cutoff_freq) = 0;
    % end
    
    % Normalize the kernel to ensure it sums to 1
    chebyshev = chebyshev_kernel / sum(chebyshev_kernel(:));
end