function filtered_img = hkr33_open(img, mask)
    dilated = hkr33_erode_dilate(img,mask,0); % dilate
    filtered_img = hkr33_erode_dilate(dilated,mask,1);  % erode
end