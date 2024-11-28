%% Image Filtering to Reduce Speckle Noise

% Code by Frieden Rawding
% DIP Coursework
% Run each section to test the different filters
% Ensure to run the setup before any filters!

%% Setup

% Define what image you want to filter
%image = f_org;
image = imread("eight.tif");
image =  imnoise(image,"speckle",0.01);

% Compile any C functions in MEX if needed
%mex fastMedianC.c

[img_r, img_c] = size(image);


pad_img=padImage(image,11);
%a=fastMedianMATLAB(pad_img,3,img_r,img_c)
%a=fastMedianC(pad_img,3,img_r,img_c)

%a=adaptiveWeightedMedian(pad_img,5,99,10);
%imshow(a)

%% 1: Linear Mean Filter 

% Initialise for calculating the filters
num_mean_filters=5; % The number of filtered images you want
mean_filt_arr = ones(img_r,img_c,num_mean_filters); % Initialising an array for all the filtered images. 
comp_mean_filt_arr = uint8(ones(img_r,img_c,num_mean_filters));    % An array for comparison. Must be uint8 to display.

for i = 1:num_mean_filters
    mask_size = 2*i + 1;  % Filter sizes are 3x3, 5x5, 7x7, etc. (odd numbers)
    mean_filter = (1/(mask_size^2)) * ones(mask_size);  % Create the mean filter
    comp_mean_filt_arr(:, :, i) = imfilter(image, mean_filter); % Apply the filter using imfilter for comparison

    % Convolve the image with the filter 
    %mean_filt_arr(:,:,i)=convolveImage(image,mean_filter);
    mean_filt_arr(:,:,i)=fftConvolution(image,mean_filter); 
end

% Plotting the filtered images on a subplot
mean_filt_arr=uint8(mean_filt_arr); % Convert from double to uint8 for display
figure;
plotFilteredImageTight(image,mean_filt_arr,num_mean_filters,'Filtered Images with Different Mean Filters'); 

%% 2: Linear Gaussian Filter 

% Initialise for calculating the filters
num_gaussian_filters = 3;   % The number of filtered images you want
gauss_filt_arr = uint8(ones(img_r, img_c, num_gaussian_filters)); % Initialising an array for all the filtered images. Must be uint8 to display.
gauss_comp_filt_arr = uint8(ones(img_r, img_c, num_gaussian_filters)); % Initialising an array for all the filtered images. Must be uint8 to display.

for i = 1:num_gaussian_filters
    % Calculating the filter
    mask_size = 2*i + 1;  % Filter sizes are 3x3, 5x5, 7x7, etc. (odd numbers)
    
    % Pad the image
    pad_img=padImage(image,mask_size);

    % Create a Gaussian filter 
    sigma = i; % Standard deviation for Gaussian
    [X, Y] = meshgrid(-floor(mask_size/2):floor(mask_size/2), -floor(mask_size/2):floor(mask_size/2));
    g_filter = exp(-(X.^2 + Y.^2) / (2*sigma^2));
    g_filter = g_filter / sum(g_filter(:));  % Normalise the filter
    
    % Convolve the image with the filter 
    gauss_filt_arr(:,:,i)=convolveImage(image,g_filter);

    % MATLAB implementation for comparison
    gauss_comp_filt_arr(:,:,i)=imgaussfilt(image,sigma);

end

figure;
plotFilteredImageSigma(image,gauss_filt_arr,num_gaussian_filters,'Filtered Images with Different Gaussian Filters');

%% 3: Linear Sharpening FIXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxx



%% 4: Non-linear Median Filter (Unefficient)

num_med_filt=5; % The number of filtered images you want
med_filt_arr = ones(img_r, img_c, num_med_filt); % Initialising an array for all the filtered images. Must be uint8 to display.
med_comp_filt_arr = uint8(ones(img_r, img_c, num_med_filt)); % Comparison array
fast_med_filt_arr = ones(img_r, img_c, num_med_filt);

for i = 1:num_med_filt
    mask_size = 2*i + 1;  % Filter sizes are 3x3, 5x5, 7x7, etc. (odd numbers)   
    
    % Pad the image
    pad_img=padImage(image,mask_size);

    med_comp_filt_arr(:,:,i)=medfilt2(image,[mask_size,mask_size]); % To compare my implementation against MATLABs

    % Unefficient
    med_filt_arr(:,:,i)=medianFilter(pad_img,mask_size,img_r,img_c);

    % Efficient
    fast_med_filt_arr(:,:,i)=fastMedianMATLABold(pad_img,mask_size,img_r,img_c);
end

figure;
plotFilteredImageTight(image,med_filt_arr,num_med_filt,'Filtered Images with Different Median Filters');
figure;
plotFilteredImageTight(image,fast_med_filt_arr,num_med_filt,'Fast Filtered Images with Different Median Filters');


%% Non-Linear Filter 3: Unsharp Mask with local statistics (Sharpening Filter) (Unsure if correct)

unsharp_filt_num=5; % The number of filtered images you want
unsharp_filt_arr = uint8(ones(img_r, img_c, unsharp_filt_num)); % Initialising an array for all the filtered images.
alpha = 1;

for i = 1:unsharp_filt_num
    mask_size = 2*i + 1;  % Filter sizes are 3x3, 5x5, 7x7, etc. (odd numbers)
    pad_img=padImage(image,mask_size);
    unsharp_filt_arr(:,:,i)=unsharpMaskingFilter(pad_img,mask_size,img_r,img_c,alpha);
end

figure;
plotFilteredImageTight(image,unsharp_filt_arr,unsharp_filt_num,'Filtered Images with unsharp Masking Filters');

%% Opening Morphological 

open_num=3;
open_arr = uint8(ones(img_r, img_c, open_num));
for i=1:open_num
    mask_size = 2*i + 1;  % Filter sizes are 3x3, 5x5, 7x7, etc. (odd numbers)
    pad_img=padImage(image,mask_size);
    open_arr(:,:,i)=open(image,mask_size);
end
figure;
plotFilteredImage(image,open_arr,open_num,'Closing the image');

%% Closing Morphological 

closing_num=3;
closing_arr = uint8(ones(img_r, img_c, closing_num));
for i=1:closing_num
    mask_size = 2*i + 1;  % Filter sizes are 3x3, 5x5, 7x7, etc. (odd numbers)
    pad_img=padImage(image,mask_size);
    closing_arr(:,:,i)=closeIm(med_filt_arr(:,:,i),mask_size);
end
figure;
plotFilteredImage(image,closing_arr,closing_num,'Opening the image');

%% Adaptive Weighted Median Filter 


% Initialise for calculating the filters
num_adap_med_filt=5; % The number of filtered images you want
adap_med_filt_arr = ones(img_r,img_c,num_adap_med_filt); % Initialising an array for all the filtered images. 
adap_med_comp_filt_arr = uint8(ones(img_r,img_c,num_adap_med_filt));    % An array for comparison. Must be uint8 to display.

for i = 1:num_adap_med_filt
    mask_size = 2*i + 1;  % Filter sizes are 3x3, 5x5, 7x7, etc. (odd numbers)
    mean_filter = (1/(mask_size^2)) * ones(mask_size);  % Create the mean filter
    pad_img=padImage(image,mask_size);
    %adap_med_comp_filt_arr(:, :, i) = medfilt2(image,mask_size); % Apply the filter using imfilter for comparison

    %adap_med_filt_arr(:,:,i) = adaptiveWeightedMedian(pad_img,mask_size,100,100);
    % 100, 30 best?
    adap_med_filt_arr(:,:,i) = adaptiveWeightedMedian(pad_img,mask_size,100,50);

end

% Plotting the filtered images on a subplot
adap_med_filt_arr=uint8(adap_med_filt_arr); % Convert from double to uint8 for display
figure;
plotFilteredImageTight(image,adap_med_filt_arr,num_adap_med_filt,'Filtered Images with Different Adaptive Mean Filters'); 

%% Testing

% Edge Detection
test_array=med_filt_arr;
num_edges=size(test_array,3);
type = ["sobel","prewitt","roberts","canny","log"]; % order will always stay the same
[edges_arr,num_edges_arr] = edgeComp(image,test_array,num_edges,type(4));

figure();
plotEdgeImages(edges_arr,num_edges,num_edges_arr,'Opening the image');


test=0;
if (test)
    % Timing Comparisons
    %timingFunctions(@() convolveImage(image,mean_filter),@() imfilter(image, mean_filter), 3);
    %timingFunctions(@() medianFilter(pad_img,5,img_r,img_c), @() medfilt2(image,[5,5]), 3);
    %timingFunctions(@() convolveImage(pad_img,g_filter,img_r,img_c),@() imgaussfilt(image,sigma), 3);
    %timingFunctions(@() fastMedianMATLABold(pad_img,3,img_r,img_c), @() medfilt2(image,[3,3]), 3)
    
    % Comparisons
    compareFilters(image,...
        adaptiveWeightedMedian(pad_img,mask_size,50,50),...
        medianFilter(pad_img,mask_size),...
        "Adaptive Weighted Median",...
        "Median",...
        mask_size);

    compareFilters(image,...
        adaptiveWeightedMedian(pad_img,mask_size,100,300),...
        closeIm(adaptiveWeightedMedian(pad_img,mask_size,100,300),mask_size),...
        "Adaptive Weighted Median",...
        "Closing on an Adaptive Weighted Median filtered image",...
        mask_size);

    compareFilters(image,...
        adaptiveWeightedMedian(pad_img,mask_size,100,300),...
        adaptiveWeightedMedian(closeIm(pad_img,mask_size),mask_size,100,300),...
        "Adaptive Weighted Median",...
        "Adaptive Weighted Median on a closed image",...
        mask_size);

    compareFilters(image,...
        adaptiveWeightedMedian(pad_img,mask_size,100,300),...
        medianFilter(adaptiveWeightedMedian(pad_img,mask_size,100,300),3),...
        "Adaptive Weighted Median",...
        "Adaptive Weighted Median with a 3x3 Median Filter after",...
        mask_size);

    compareFilters(image,...
        adaptiveWeightedMedian(pad_img,mask_size,100,300),...
        fftConvolution(adaptiveWeightedMedian(pad_img,mask_size,100,300),[0,-1/4,0; -1/4, 2, -1/4; 0, 1/4, 0]),...
        "Adaptive Weighted Median",...
        "Adaptive Weighted Median convolved with a Gaussian High Pass Filter",...
        mask_size);

    compareFilters(image,...
        adaptiveWeightedMedian(pad_img,mask_size,50,50),...
        fftConvolution(image,[0,-1/4,0; -1/4, 2, -1/4; 0, 1/4, 0]),...
        "Adaptive Weighted Median",...
        "Gaussian High Pass Filter",...
        mask_size);

    % Testing my implementations against MATLABs
    %testImplementation(mean_filt_arr,comp_mean_filt_arr,1);
    %testImplementation(med_filt_arr,med_comp_filt_arr,4);
    %testImplementation(fast_med_filt_arr,med_comp_filt_arr,5);
    %testImplementation(gauss_filt_arr,gauss_comp_filt_arr,2);
end

