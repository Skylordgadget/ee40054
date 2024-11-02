clear; clf; close all;

% a = zeros(9);
% a(1:3,1:3) = 255;

% figure();
% imshow(a);

original_foetus_uint8 = imread("./original/foetus.png");
original_foetus = im2double(original_foetus_uint8);
original_SAR = im2double(imread("./original/NZjers1.png"));

figure(); imshow(original_foetus);
figure(); imshow(original_SAR);

simple_filt = ones(11)./121;

% my_filt = @(img) hkr33_imfilter(img, simple_filt);
% mat_filt = @(img) hkr33_conv2(img, simple_filt);

K = 11;
K_pad = floor(K / 2);
img_pad = padarray(original_foetus_uint8,[K_pad K_pad],0,'both');

my_filt = hkr33_huang_medfilt2_c(img_pad, int32(K));
mat_filt = medfilt2(original_foetus, [11,11]);

indices = hkr33_zigzag(size(original_foetus),11);

% compareFunctionTimes(my_filt, mat_filt, original_foetus);

figure();
diff = abs(my_filt - mat_filt);
imshow(diff);


% Step 6: Display the results
figure;
subplot(1, 2, 1);
imshow(mat_filt, []);
title('Mat Image');

subplot(1, 2, 2);
imshow(my_filt, []);
title('Filtered Image');
