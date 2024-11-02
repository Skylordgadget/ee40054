function filtered_img = hkr33_imfilter(img, kernel)
    img = double(img); kernel = double(kernel); % convert to double    

    [K, L] = size(kernel); % get the length and width of the kernel

    % compute the padding length and width
    pad_const = int16(2);
    K_pad = double(idivide(int16(K), pad_const)); 
    L_pad = double(idivide(int16(L), pad_const));

    % pad the image borders with zeros
    img_pad = padarray(img,[K_pad L_pad],0,'both');
    [M_pad, N_pad] = size(img_pad);

    % initialise an array as zeros with the same dimensions as the
    % padded image
    kernel_pad = zeros(M_pad,N_pad,'like',img_pad);
    % place the kernel into the top left of the array
    kernel_pad(1:K, 1:L) = kernel(1:K, 1:L);
    
    % convert the image and kernel into the frequency domain
    img_fft = fft2(img_pad);
    kernel_fft = fft2(kernel_pad);
    
    % multiply
    fft_conv = img_fft .* kernel_fft;

    % convert back to the time domain and take the real part
    ifft_conv = real(ifft2(fft_conv));
    
    % unpad and return the image
    filtered_img = ifft_conv((K_pad*2)+1:M_pad, (L_pad*2)+1:N_pad);
end