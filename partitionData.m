function [ dataForWT ] = partitionData( input, len_partition, noOfData)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
k = 0;
for i = 1: noOfData
    if length(input{i}) > len_partition
        k = k+1;
        for j = 1: length(input{i})/len_partition
            dataForWT{k}(j,:) = input{i}(len_partition*(j- 1) +1 : j*len_partition,2);
        end
    end
      
end

end

