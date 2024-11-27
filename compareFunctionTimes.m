function [runtime1, runtime2]= compareFunctionTimes(func1, func2, varargin)
    % compareFunctionTimes times two functions using timeit and compares their execution times
    % 
    % Inputs:
    %   func1 - handle to the first function (e.g., @myFunction1)
    %   func2 - handle to the second function (e.g., @myFunction2)
    %   varargin - input arguments to pass to both functions
    %
    % Outputs:
    %   Prints time taken by each function and which one is faster

    % Define anonymous functions that include the arguments
    wrappedFunc1 = @() func1(varargin{:});
    wrappedFunc2 = @() func2(varargin{:});

    % Time each function using timeit
    time1 = timeit(wrappedFunc1);
    fprintf('Time taken by func1: %.6f seconds\n', time1);

    time2 = timeit(wrappedFunc2);
    fprintf('Time taken by func2: %.6f seconds\n', time2);

    % Compare the times
    if time1 < time2
        fprintf('func1 is faster than func2 by %.6f seconds\n', time2 - time1);
    elseif time2 < time1
        fprintf('func2 is faster than func1 by %.6f seconds\n', time1 - time2);
    else
        disp('Both functions have the same execution time.');
    end

    runtime1 = time1;
    runtime2 = time2;
end
