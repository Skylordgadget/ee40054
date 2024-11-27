%% Setup

clc; clf; clear; close all;
s = settings;
s.matlab.appearance.figure.GraphicsTheme.TemporaryValue = "light";

img_path = "./original/";

sar_image = im2double(imread(img_path +"NZjers1.png"));
ultrasound_image = im2double(imread(img_path + "foetus.png"));


%% Mean
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    kernel = ones(i);
    kernel = kernel./(i^2); % equalise energy

    imshow(hkr33_imfilter(sar_image,kernel,i));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    kernel = ones(i);
    kernel = kernel./(i^2); % equalise energy

    imshow(hkr33_imfilter(ultrasound_image,kernel,i));
    title(i + "x" + i + " kernel");
end


%% Gaussian
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    
    sigma = (i-1) / 6;
    kernel = hkr33_gaussian(i,sigma);

    imshow(hkr33_imfilter(sar_image,kernel,i));
    title(i + "x" + i + " kernel, " + sigma + " sigma");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    
    sigma = (i-1) / 6;
    kernel = hkr33_gaussian(i,sigma);

    imshow(hkr33_imfilter(ultrasound_image,kernel,i));
    title(i + "x" + i + " kernel, " + sigma + " sigma" );
end

figure();
surf(kernel);
title(["Gaussian Low-Pass Kernel" i + "x" + i + " kernel, " + sigma + " sigma"])

%% Comparison
close all;

figure('Position', [0 0 1280 450])

subtightplot(2,3,1);
imshow(sar_image);
title("Original");
xlim([131 240])
ylim([92 160])
% mean 5x5
i = 5;
subtightplot(2,3,2);
kernel = ones(i);
kernel = kernel./(i^2); % equalise energy
imshow(hkr33_imfilter(sar_image,kernel,i));
title(["Mean" i + "x" + i + " kernel"]);
xlim([131 240])
ylim([92 160])

i = 9;
subtightplot(2,3,3);
sigma = (i-1) / 6;
kernel = hkr33_gaussian(i,sigma);
imshow(hkr33_imfilter(sar_image,kernel,i));
title(["Gaussian Low-Pass" i + "x" + i + " kernel, " + sigma + " sigma"]);
xlim([131 240])
ylim([92 160])


subtightplot(2,3,4);
imshow(ultrasound_image);
title("Original");
xlim([144 436])
ylim([109 278])
% mean 11x11
i = 9;
subtightplot(2,3,5);
kernel = ones(i);
kernel = kernel./(i^2); % equalise energy
imshow(hkr33_imfilter(ultrasound_image,kernel,i));
title(["Mean" i + "x" + i + " kernel"]);
xlim([144 436])
ylim([109 278])

i = 17;
subtightplot(2,3,6);
sigma = (i-1) / 6;
kernel = hkr33_gaussian(i,sigma);
imshow(hkr33_imfilter(ultrasound_image,kernel,i));
title(["Gaussian Low-Pass" i + "x" + i + " kernel, " + sigma + " sigma"]);
xlim([144 436])
ylim([109 278])

%% High Pass
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    
    sigma = (i-1) / 6;
    kernel = hkr33_gaussian(i,sigma,true);
    imshow(hkr33_imfilter(sar_image,kernel,i));
    title(i + "x" + i + " kernel, " + sigma + " sigma");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    sigma = (i-1) / 6;
    kernel = hkr33_gaussian(i,sigma,true);

    imshow(hkr33_imfilter(ultrasound_image,kernel,i));
    title(i + "x" + i + " kernel, " + sigma + " sigma");
end

figure();
surf(kernel);
title(["Gaussian High-Pass Kernel" i + "x" + i + " kernel, " + sigma + " sigma"])


%% Sharpening

close all;

figure('Position', [0 0 1280 450])

filter_size = 3;
laplacian_mask = zeros(filter_size);
laplacian_mask = laplacian_mask - 1;
centre_pos = [floor(filter_size/2), floor(filter_size/2)];
laplacian_mask(centre_pos) = (filter_size^2) - 1;


subtightplot(2,2,1);
imshow(sar_image);
title("Original");

subtightplot(2,2,2);
imshow(hkr33_imfilter(sar_image,laplacian_mask,filter_size));
title(filter_size + "x" + filter_size + " Laplacian Mask");

subtightplot(2,2,3);
imshow(ultrasound_image);
title("Original");

subtightplot(2,2,4);
imshow(hkr33_imfilter(ultrasound_image,laplacian_mask,filter_size));
title(filter_size + "x" + filter_size + " Laplacian Mask");


%% Unsharp Masking
close all;

figure('Position', [0 0 1280 450])

scale_factor = 3;

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    kernel = zeros(i);
    kernel(floor(i/2),floor(i/2)) = 1;
    sigma = (i-1) / 6;
    kernel = kernel + (kernel - hkr33_gaussian(i,sigma)).*scale_factor;

    imshow(hkr33_imfilter(sar_image,kernel,i));
    title(i + "x" + i + " kernel, " + sigma + " sigma, scale factor " + scale_factor);
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    kernel = zeros(i);
    kernel(floor(i/2),floor(i/2)) = 1;
    sigma = (i-1) / 6;
    kernel = kernel + (kernel - hkr33_gaussian(i,sigma)).*scale_factor;

    imshow(hkr33_imfilter(ultrasound_image,kernel,i));
    title(i + "x" + i + " kernel, " + sigma + " sigma, scale factor " + scale_factor);
end

%% Adaptive Unsharp Masking
close all;

figure('Position', [0 0 1280 450])

strength = 3;

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_adaptive_unsharp_mask(sar_image,i,strength));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_adaptive_unsharp_mask(ultrasound_image,i,strength));
    title(i + "x" + i + " kernel");
end

%% Sharpening Comparison

close all;

figure('Position', [0 0 1280 450])

scale_factor = 3;

filter_size = 3;
laplacian_mask = zeros(filter_size);
laplacian_mask = laplacian_mask - 1;
centre_pos = [floor(filter_size/2), floor(filter_size/2)];
laplacian_mask(centre_pos) = (filter_size^2) - 1;

subtightplot(2,4,1);
imshow(sar_image);
title("Original");
xlim([131 240])
ylim([92 160])

subtightplot(2,4,2);
imshow(hkr33_imfilter(sar_image,laplacian_mask,filter_size));
title(["Laplacian Mask" filter_size + "x" + filter_size + " Laplacian Mask"]);
xlim([131 240])
ylim([92 160])

subtightplot(2,4,3);
i = 3;
kernel = zeros(i);
kernel(floor(i/2),floor(i/2)) = 1;
sigma = (i-1) / 6;
kernel = kernel + (kernel - hkr33_gaussian(i,sigma)).*scale_factor;
imshow(hkr33_imfilter(sar_image,kernel,i));
title(["Unsharp Mask" i + "x" + i + " kernel, " + sigma + " sigma, scale factor " + scale_factor]);
xlim([131 240])
ylim([92 160])

subtightplot(2,4,4);
i = 11;
imshow(hkr33_adaptive_unsharp_mask(sar_image,i,strength));
title(["Adaptive Unsharp Mask" i + "x" + i + " kernel"]);
xlim([131 240])
ylim([92 160])

subtightplot(2,4,5);
imshow(ultrasound_image);
title("Original");
xlim([144 436])
ylim([109 278])

subtightplot(2,4,6);
imshow(hkr33_imfilter(ultrasound_image,laplacian_mask,filter_size));
title(["Laplacian Mask" filter_size + "x" + filter_size + " Laplacian Mask"]);
xlim([144 436])
ylim([109 278])

subtightplot(2,4,7);
i = 17;
kernel = zeros(i);
kernel(floor(i/2),floor(i/2)) = 1;
sigma = (i-1) / 6;
kernel = kernel + (kernel - hkr33_gaussian(i,sigma)).*scale_factor;
imshow(hkr33_imfilter(ultrasound_image,kernel,i));
title(["Unsharp Mask" i + "x" + i + " kernel, " + sigma + " sigma, scale factor " + scale_factor]);
xlim([144 436])
ylim([109 278])

subtightplot(2,4,8);
i = 17;
imshow(hkr33_adaptive_unsharp_mask(ultrasound_image,i,strength));
title(["Adaptive Unsharp Mask" i + "x" + i + " kernel"]);
xlim([144 436])
ylim([109 278])
%% Median
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_medfilt2(sar_image,i));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_medfilt2(ultrasound_image,i));
    title(i + "x" + i + " kernel");
end

%% Huang's Algorithm (MATLAB)
close all;

uint8_sar_image = imread(img_path +"NZjers1.png");
uint8_ultrasound_image = imread(img_path + "foetus.png");

figure('Position', [0 0 1280 450])

cnt = 0;
for i = 3:2:17
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_huang_medfilt2(uint8_sar_image,i));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 0;
for i = 3:2:17
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_huang_medfilt2(uint8_ultrasound_image,i));
    title(i + "x" + i + " kernel");
end

% works, needs timing
%% Huang's Algorithm (C)
close all;

uint8_sar_image = imread(img_path +"NZjers1.png");
uint8_ultrasound_image = imread(img_path + "foetus.png");



figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:17
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    uint8_sar_image_pad = hkr33_pad(uint8_sar_image,[i i]);
    imshow(hkr33_huang_medfilt2_c(uint8_sar_image_pad,i));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    uint8_ultrasound_image_pad = hkr33_pad(uint8_ultrasound_image,[i i]);
    imshow(hkr33_huang_medfilt2_c(uint8_ultrasound_image_pad,i));
    title(i + "x" + i + " kernel");
end



%% Adaptive Weighted Median
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_adaptive_weighted_median(sar_image,i,250,100));
    title([i + "x" + i + " kernel" "central weight " + 250 "constant " + 100]);
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_adaptive_weighted_median(ultrasound_image,i,250,100));
    title([i + "x" + i + " kernel" "central weight " + 250 "constant " + 100]);
end

%% Mode
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_mode(sar_image,i));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_mode(ultrasound_image,i));
    title(i + "x" + i + " kernel");
end

%% Truncated Median
close all;

figure('Position', [0 0 1280 450])

iterations = 2;

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_truncated_median(sar_image,i,iterations));
    title([i + "x" + i + " kernel" "truncations " + iterations]);
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);

    imshow(hkr33_truncated_median(ultrasound_image,i,iterations));
    title([i + "x" + i + " kernel" "truncations " + iterations]);
end

%% Non-linear Comparison 

close all;

figure('Position', [0 0 1280 450])

subtightplot(2,5,1);
imshow(sar_image);
title("Original");
xlim([131 240])
ylim([92 160])

filter_size = 5;
subtightplot(2,5,2);
imshow(hkr33_medfilt2(sar_image,filter_size));
title(["Median" filter_size + "x" + filter_size + " kernel"]);
xlim([131 240])
ylim([92 160])

subtightplot(2,5,3);
i = 3;
imshow(hkr33_adaptive_weighted_median(sar_image,i,250,100));
title(["Adaptive Weighted Median" i + "x" + i + " kernel, central weight " + 250 + ", constant " + 100]);
xlim([131 240])
ylim([92 160])

subtightplot(2,5,4);
i = 3;
imshow(hkr33_mode(sar_image,i));
title(["Mode" i + "x" + i + " kernel"]);
xlim([131 240])
ylim([92 160])

subtightplot(2,5,5);
i = 5;
imshow(hkr33_truncated_median(sar_image,i,2));
title(["Truncated Median" i + "x" + i + " kernel, truncations " + 2 ]);
xlim([131 240])
ylim([92 160])

subtightplot(2,5,6);
imshow(ultrasound_image);
title("Original");
xlim([144 436])
ylim([109 278])

subtightplot(2,5,7);
filter_size = 13;
imshow(hkr33_medfilt2(ultrasound_image,filter_size));
title(["Median" filter_size + "x" + filter_size]);
xlim([144 436])
ylim([109 278])

subtightplot(2,5,8);
i = 13;
imshow(hkr33_adaptive_weighted_median(ultrasound_image,i,250,100));
title(["Adaptive Weighted Median" i + "x" + i + " kernel, central weight " + 250 + ", constant " + 100]);
xlim([144 436])
ylim([109 278])

subtightplot(2,5,9);
i = 9;
imshow(hkr33_mode(ultrasound_image,i));
title(["Mode" i + "x" + i + " kernel"]);
xlim([144 436])
ylim([109 278])

subtightplot(2,5,10);
i = 9;
imshow(hkr33_truncated_median(ultrasound_image,i,2));
title(["Truncated Median" i + "x" + i + " kernel, truncations " + 2]);
xlim([144 436])
ylim([109 278])



%% Erosion
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    V = round((i:-1:1)/(i+1));
    kernel = toeplitz(V);
    kernel = double(kernel & rot90(kernel));
    imshow(hkr33_erode_dilate(sar_image,kernel,1));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    V = round((i:-1:1)/(i+1));
    kernel = toeplitz(V);
    kernel = double(kernel & rot90(kernel));
    imshow(hkr33_erode_dilate(ultrasound_image,kernel,1));
    title(i + "x" + i + " kernel");
end



%% Dilation
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    V = round((i:-1:1)/(i+1));
    kernel = toeplitz(V);
    kernel = double(kernel & rot90(kernel));
    imshow(hkr33_erode_dilate(sar_image,kernel,0));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    V = round((i:-1:1)/(i+1));
    kernel = toeplitz(V);
    kernel = double(kernel & rot90(kernel));
    imshow(hkr33_erode_dilate(ultrasound_image,kernel,0));
    title(i + "x" + i + " kernel");
end
%% Opening
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    V = round((i:-1:1)/(i+1));
    kernel = toeplitz(V);
    kernel = double(kernel & rot90(kernel));
    imshow(hkr33_open(sar_image,kernel));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    V = round((i:-1:1)/(i+1));
    kernel = toeplitz(V);
    kernel = double(kernel & rot90(kernel));
    imshow(hkr33_open(ultrasound_image,kernel));
    title(i + "x" + i + " kernel");
end
%% Closing
close all;

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(sar_image);
title("Original");
for i = 3:2:15
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    V = round((i:-1:1)/(i+1));
    kernel = toeplitz(V);
    kernel = double(kernel & rot90(kernel));
    imshow(hkr33_close(sar_image,kernel));
    title(i + "x" + i + " kernel");
end

figure('Position', [0 0 1280 450])

cnt = 1;
subtightplot(2,4,cnt);
imshow(ultrasound_image);
title("Original");
for i = 5:4:29
    cnt = cnt + 1;
    subtightplot(2,4,cnt);
    V = round((i:-1:1)/(i+1));
    kernel = toeplitz(V);
    kernel = double(kernel & rot90(kernel));
    imshow(hkr33_close(ultrasound_image,kernel));
    title(i + "x" + i + " kernel");
end
%% Combined
close all;
figure();
cnt = 1;
subtightplot(2,4,1);
imshow(sar_image);
title("Original");
subtightplot(2,4,2);
imshow(edge(sar_image,"canny"));
title("Canny Edge Detector")
img = hkr33_adaptive_weighted_median(sar_image,3,250,100);
cutoff = 0.151;
img(img < cutoff) = 0;
img(img > cutoff) = 1;
subtightplot(2,4,3);
imshow(edge(img,"canny"));
title(["Adaptive Weighted Median" "Threshold (>0.151=1,<0.151=0)"])
% truncated_median((truncated_median > lower_bound) & (truncated_median < upper_bound)) = 0.5;
% truncated_median(truncated_median > upper_bound) = 1;

subtightplot(2,4,4);
imshow(edge(hkr33_mode(img,11),"canny"));
title(["Adaptive Weighted Median" "Threshold (>0.151=1,<0.151=0)" "Mode"])

subtightplot(2,4,5);
imshow(ultrasound_image);
title("Original");
subtightplot(2,4,6);
imshow(edge(ultrasound_image,"canny"));
title("Canny Edge Detector")
img2 = hkr33_truncated_median(ultrasound_image,9,2);
cutoff = 0.1;
img2(img2 < cutoff) = 0;
img2(img2 > cutoff) = 1;
subtightplot(2,4,7);
imshow(edge(img2,"canny"));
title(["Adaptive Weighted Median" "Threshold (>0.1=1,<0.1=0)"])
subtightplot(2,4,8);
imshow(edge(hkr33_mode(img2,11),"canny"));
title(["Adaptive Weighted Median" "Threshold (>0.1=1,<0.1=0)" "Mode"])


figure();
imshow(edge(hkr33_mode(img,11),"canny")+sar_image);
title("Edge Detector and Original Composite")

figure();
imshow(edge(hkr33_mode(img2,11),"canny")+ultrasound_image);
title("Edge Detector and Original Composite")
%% End of Program

%% Timer
img_path = "./original/";
uint8_image = imread(img_path + "NZjers1.png");

k = 5;
[M, N] = size(uint8_image);
uint8_sar_image_pad = hkr33_pad(uint8_image,[k k]);

% Call compareFunctionTimes


t = zeros(10,4);
k = 5:4:41;
for i = 1:10
    hkr33_mf2 = @() hkr33_medfilt2(uint8_sar_image_pad, k(i));
    hkr33_huang_mf2 = @() hkr33_huang_medfilt2(uint8_sar_image_pad, k(i));
    hkr33_huang_mf2_c = @() hkr33_huang_medfilt2_c(uint8_sar_image_pad, k(i));
    mf2 = @() medfilt2(uint8_sar_image_pad, [k(i) k(i)]);
    t(i,1) = timeit(hkr33_mf2);
    t(i,2) = timeit(hkr33_huang_mf2);
    t(i,3) = timeit(hkr33_huang_mf2_c);
    t(i,4) = timeit(mf2);
end

