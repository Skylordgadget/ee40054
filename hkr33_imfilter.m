function filtered_img = hkr33_imfilter(img, kernel, kernel_size)
    img = double(img); kernel = double(kernel); % convert to double    

    % compute the amount of pading needed either side of the image
    half_size = floor(kernel_size / 2);

    % pad the image with zeros
    img_pad = hkr33_pad(img,[kernel_size, kernel_size]);
    [M_pad, N_pad] = size(img_pad);

    % initialise an array as zeros with the same dimensions as the
    % padded image
    kernel_pad = zeros(M_pad,N_pad,'like',img_pad);
    % place the kernel into the top left of the array
    kernel_pad(1:kernel_size, 1:kernel_size) = ...
                                    kernel(1:kernel_size, 1:kernel_size);
    
    % convert the image and kernel into the frequency domain
    img_fft = fft2(img_pad);
    kernel_fft = fft2(kernel_pad);
    
    % multiply
    fft_conv = img_fft .* kernel_fft;

    % convert back to the time domain and take the real part
    ifft_conv = real(ifft2(fft_conv));
    
    % unpad and return the image
    filtered_img = ifft_conv((half_size*2)+1:M_pad, (half_size*2)+1:N_pad);
end