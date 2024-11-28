function [outputImage] = padImage(image,filter_size)
%padImage Pads an input image with zeros 

    [image_rows,image_cols] = size(image);

    % Creating a zero padded matrix to fit the image inside, to handle boundries
    % imfilter uses zero padding, but other types could be used
    pad_size = floor(filter_size / 2);  % a 3x3 filter, pad by 1. 5x5, pad by 2 etc.
    outputImage = zeros((image_rows+2*pad_size), image_cols+2*pad_size);  % 2* as padded on either side

    % Place original image in the new padded matrix
    outputImage(1+pad_size:end-pad_size,1+pad_size:end-pad_size) = image;

end