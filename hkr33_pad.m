function img_pad = hkr33_pad(img, kernel_size)
    % kernel_size = scalar length and width of the kernel
    % img = greyscale matrix (uint8 or double)
    
    % compute the padding length and width
    K_pad = floor(kernel_size(1) / 2);
    L_pad = floor(kernel_size(2) / 2);

    % pad the image borders with zeros
    img_pad = padarray(img,[K_pad L_pad],0,'both');
end