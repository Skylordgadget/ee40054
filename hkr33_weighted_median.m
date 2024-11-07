function weigthed_median = hkr33_weighted_median(A, B)
    
    n = numel(A);
    A = reshape(A,[n,1]);
    B = reshape(B,[n,1]);

    [A, idx] = sort(A);
    B = sort(idx);
    
    total_weight_half = sum(B,"all") / 2;
    cumulative_weights = 0;
    for i = 1:n
        cumulative_weights = cumulative_weights + B(i);
        if (cumulative_weights >= total_weight_half)
            weigthed_median = A(i);
            break;
        end
    end

    
end