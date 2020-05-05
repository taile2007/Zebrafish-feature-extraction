function max_peak = max_find(signal,temp)
max_index = 1;
max_peak = temp(max_index);
for i=1:length(temp)
  
    if(signal(temp(i)) > signal(temp(max_index)))
        max_index = i;
        max_peak = temp(max_index);
    end
    
end