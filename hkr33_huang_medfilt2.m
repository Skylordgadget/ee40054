function filtered_img = hkr33_huang_medfilt2(img, K)
    [M, N] = size(img);
    
    % compute the padding length and width
    K_pad = floor(K / 2);

    % pad the image borders with zeros
    img_pad = padarray(img,[K_pad K_pad],0,'both');
    [M_pad, N_pad] = size(img_pad); 
    filtered_img_pad = zeros(M_pad,N_pad,'like',img_pad);

    win = [];
    h = 256;
    htg = zeros(1,h);
    for y = 1:K
        for x = 1:K
            win(end+1) = img_pad(y, x);
            htg(img_pad(y, x) + 1) = htg(img_pad(y, x) + 1) + 1;
        end
    end

    win = sort(win);
    th = floor((K * K) / 2);
    mdn = win(th + 1);

    ltmdn = 0;
    for y = 1:K
        for x = 1:K
            if img_pad(y,x) < mdn
                ltmdn = ltmdn + 1;
            end
        end
    end

    filtered_img_pad(K_pad+1,K_pad+1) = mdn;

    indices = hkr33_zigzag([M_pad,N_pad],K);

    for i = 2:length(indices)
        y = indices{i}(1); x = indices{i}(2);
       
        [olds,news] = hkr33_strip(indices,i,K);
        
        for j = 1:length(olds)
            yy = olds{j}(1);
            xx = olds{j}(2);
            
            htg(img_pad(yy, xx) + 1) = htg(img_pad(yy, xx) + 1) - 1;
            
            if img_pad(yy, xx) < mdn
                ltmdn = ltmdn - 1;
            end
        end

        for j = 1:length(news)
            yy = news{j}(1);
            xx = news{j}(2);
            
            htg(img_pad(yy, xx) + 1) = htg(img_pad(yy, xx) + 1) + 1;
            
            if img_pad(yy, xx) < mdn
                ltmdn = ltmdn + 1;
            end
        end

        if ltmdn > th
            while ltmdn > th
                mdn = mdn - 1;
                ltmdn = ltmdn - htg(mdn + 1);
            end
        else 
            while ltmdn + htg(mdn + 1) <= th
                ltmdn = ltmdn + htg(mdn + 1);
                mdn = mdn + 1;
            end
        end

        filtered_img_pad(y,x) = mdn;
    end
    
    filtered_img = im2double(filtered_img_pad((K_pad+1):(M+K_pad),(K_pad+1):(N+K_pad)));
end

