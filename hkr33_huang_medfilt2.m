function filtered_img = hkr33_huang_medfilt2(img_pad, filter_size)
    % compute the amount of pading needed either side of the image
    K_pad = floor(filter_size / 2);
    
    % get the length and width of the padded image
    [M_pad, N_pad] = size(img_pad);

    M = M_pad - K_pad*2; N = N_pad - K_pad*2;
     
    % initialise an empty array for the filtered image
    filtered_img_pad = zeros(M_pad,N_pad,'like',img_pad);
    
    win = zeros(1,filter_size*filter_size); % initialise an empty window
    h = 256;  % set the number of bins in the histogram
    htg = zeros(1,h); % initialise an empty histogram
    
    % fill up the window with the first filter_size*filter_size elements
    % add these elements to the histogram
    for y = 1:filter_size
        for x = 1:filter_size
            win((y-1) * filter_size + x) = img_pad(y, x);
            htg(img_pad(y, x) + 1) = htg(img_pad(y, x) + 1) + 1;
        end
    end

    win = sort(win); % sort the window
    th = floor((filter_size * filter_size) / 2); % initial middle position
    mdn = win(th + 1); % get the median in the window

    ltmdn = 0; % less-than-median = 0
    % loop over the values in the window
    for y = 1:filter_size
        for x = 1:filter_size
            % if the element is less than the median
            if img_pad(y,x) < mdn
                % increment less-than-median
                ltmdn = ltmdn + 1;
            end
        end
    end
   
    filtered_img_pad(K_pad+1,K_pad+1) = mdn;

    % compute the indices for a zig-zag sweep across the image
    indices = hkr33_zigzag([M_pad,N_pad],filter_size);
    
    % loop over the indices starting at the second position
    for i = 2:length(indices)
        % break out the indices into separate variables
        y = indices{i}(1); x = indices{i}(2);
        
        % get the previous and new strip of the window over the image
        [olds,news] = hkr33_strip(indices,i,filter_size);
           
        % loop over old indices and remove their values from the histogram
        for j = 1:length(olds)
            yy = olds{j}(1); xx = olds{j}(2);
            
            htg(img_pad(yy, xx) + 1) = htg(img_pad(yy, xx) + 1) - 1;
            
            % update less-than-median
            if img_pad(yy, xx) < mdn
                ltmdn = ltmdn - 1;
            end
        end
        
        % loop over new indices and add their values to the histogram
        for j = 1:length(news)
            yy = news{j}(1); xx = news{j}(2);
            
            htg(img_pad(yy, xx) + 1) = htg(img_pad(yy, xx) + 1) + 1;
             
            % update less-than-median
            if img_pad(yy, xx) < mdn
                ltmdn = ltmdn + 1;
            end
        end
        
        % if less-than-median is greater than the midpoint:
        %       decrement the median
        %       take the median value from less-than-median
        if ltmdn > th
            while ltmdn > th
                mdn = mdn - 1;
                ltmdn = ltmdn - htg(mdn + 1);
            end
        % else if less-than-median is less than or equal to the midpoint...
        % plus the number of values in the histogram at the median:
        %       add the median value to less-than-median
        %       increment the median
        else 
            while ltmdn + htg(mdn + 1) <= th
                ltmdn = ltmdn + htg(mdn + 1);
                mdn = mdn + 1;
            end
        end
        
        filtered_img_pad(y,x) = mdn;
    end
    
    % remove the padding and return the filtered image
    filtered_img = im2double(filtered_img_pad((K_pad+1):(M+K_pad),(K_pad+1):(N+K_pad)));
end

