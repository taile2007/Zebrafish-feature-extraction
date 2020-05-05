function [ filteredOutput ] = combineData( outputPartition )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i = 1: length(outputPartition)
     temp = 0;
    [row, col] = size(outputPartition{i});
    for j = 1: row
        for k = 1: length(outputPartition{i})
            filteredOutput{i}(k + temp) = outputPartition{i}(j,k); 
        end
        temp = temp + length(outputPartition{i});
    end
    
end
end

