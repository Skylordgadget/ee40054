function filtered_img = hkr33_close(img, mask)
    eroded = hkr33_erode_dilate(img,mask,1); % erode
    filtered_img = hkr33_erode_dilate(eroded,mask,0); %dilate
end