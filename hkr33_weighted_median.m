function weigthed_median = hkr33_weighted_median(A, B)
    
    n = numel(A); % get the number of elements in the window
    % reshape into 1D matrices
    A = reshape(A,[n,1]); 
    B = reshape(B,[n,1]);
    
    % sort the window in ascending order
    [A, idx] = sort(A);
    
    % find the midpoint in terms of weight
    total_weight_half = sum(B,"all") / 2;

    % the weighted median is the pixel at which the cumulative weight 
    % equals or exceeds the weight midpoint
    cumulative_weights = 0;
    for i = 1:n
        cumulative_weights = cumulative_weights + B(idx(i)); 
        if (cumulative_weights >= total_weight_half)
            weigthed_median = A(i);
            break;
        end
    end

    
end