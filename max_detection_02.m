function [output] = max_detection_02(input, n)
high = zeros(length(input) - 2*n, 1);
for i = 1: length(input) - 2*n
    window_max = max(i : i + 2*n);
    max_position = find(input(i : i + 2*n) == window_max);
    if(length(max_position == 1))
        if (input(i + n) == window_max)
            high_index = i + n;
        else
            high_index = 0;
        end
    else
        if (input(i + n) == window_max)
            high_index = i + min(max_position) - 1;% chon gia tri bang nhau o cuoi cung ben tay phai.
        else
            high_index = 0;
        
        end
    end
   
end
 high(i) = high_index;
 
end
high(high==0)=[];
high(input(high)==0)=[];
high=unique(high);
output = high;