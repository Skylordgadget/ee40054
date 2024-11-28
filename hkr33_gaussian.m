function gaussian = hkr33_gaussian(kernel_size, sigma, high_pass)

    if nargin < 3 || isempty(high_pass)
        high_pass = false;
    end
    
    % Generate spatial coordinates
    half_size = floor(kernel_size / 2);
    [x, y] = meshgrid(-half_size:half_size, -half_size:half_size);
    
    % Gaussian filter formula
    gaussian_kernel = exp(-(x.^2 + y.^2) / (2 * sigma^2));
    
    if (high_pass) 
        gaussian_kernel = 1 - gaussian_kernel;
    end
    
    % gaussian = gaussian_kernel;

    % Normalize the kernel to ensure it sums to 1
    gaussian = gaussian_kernel / sum(gaussian_kernel(:));
end