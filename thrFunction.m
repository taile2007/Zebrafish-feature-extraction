function[output] = thrFunction(input, thresholdValue, no_selection)
% input is singal input which wants to shirnk Wavelet coeficient
% len is the length of input
% no_selection is possible case choose Threshold function
% if no_selection = 1 -> 
%    no_selection = 2 ->
%    no_selection = 3 ->
%       ......

switch no_selection
    case '1' % soft
        %do sth
        tmp = (abs(input) - thresholdValue);
        tmp = (tmp+abs(tmp))/2;
        output   = sign(input).*tmp;
    case '2' % hard
        output = input.*(abs(input) > thresholdValue);
    case '3'
        % do sth
        if ((thresholdValue < abs(input)) & (abs(input) <= 2*thresholdValue))
            tmp = (abs(input) - thresholdValue);
            tmp = (tmp+abs(tmp))/2;
            output   = 2*sign(input).*tmp;
        else
            output = input.*(abs(input) > 2*thresholdValue);
        end
    case '4'
        tmp = sqrt(input.^2 - thresholdValue^2);
        output = (sign(input).*tmp).*(abs(input) > thresholdValue);
    otherwise
        error(message('Error!!!'));
        
 end
