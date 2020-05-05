function output=high_detection(input,n)

high =zeros(length(input)-2*n,1);

for i=1:length(input)-2*n
    window_max= max(input(i:i+2*n));% max cua cua so
    window_max_position= find(input(i:i+2*n)==window_max); % vi_tri cua max trong cua so
    if length(window_max_position)==1 % neu chi co 1 gia tri max cua cua so
        if input(i+n)==window_max
            high_index=i+n;
        else
            high_index=0;
        end
    else
        if input(i+n)==window_max
            high_index=i+min(window_max_position)-1; % tai sao lai tru di 1
        else
            high_index=0;
        end
    end
    high(i) = high_index;
end
%???????
high(high==0)=[];
high(input(high)==0)=[];
high=unique(high);
output=high;
