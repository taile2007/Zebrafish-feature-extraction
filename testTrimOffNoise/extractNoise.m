function [finalData ] = extractNoise( input,fs, coef )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%===================Remove baseline first==================================
fDomain=fft(input); 
fDomain(1 : round(length(fDomain)*1.5/fs))=0; 
fDomain(end - round(length(fDomain)*1.5/fs) : end)=0; 
final_input = real(ifft(fDomain));

figure, subplot(211); plot(input);
subplot(212); plot(final_input,'r');
%=========================================================================%
maxWindow = coef * fs;
max_index = zeros(round(length(input)/maxWindow),1);
min_index = zeros(round(length(input)/maxWindow),1);
j = 1;
for i = 1 : maxWindow: length(input) - maxWindow
    max_index(j) = find(input(i: i + maxWindow) == max(input(i: i + maxWindow)));
    min_index(j) = find(input(i: i + maxWindow) == min(input(i: i + maxWindow)));
    maxPoint(j) = max_index(j) + i - 1;
    minPoint(j) = min_index(j) + i - 1;
    j = j + 1;
    
end
aveMax = mean(input(maxPoint));
aveMin = mean(input(minPoint));
j = 1;
flag1 = 2; flag2 = 2; flag3 = 0;
for i = 1: length(minPoint)
    if abs(input(minPoint(i))) >= 2*abs(aveMin)
        bottomPoint(j) = minPoint(i);
        j = j+1;
        flag1 = 0;
    end
end
if (j == 1)
    bottomPoint(j) = 0;
    bottomPoint(j) = [];
end
j = 1;
for i = 1: length(maxPoint)
    if abs(input(maxPoint(i))) >= 2* aveMax
        topPoint(j) = maxPoint(i);
        j = j+1;
        flag2 = 1;
    end
end
 if (j == 1)
     topPoint(j) = 0;   
     topPoint(j) = [];
 end
j = 0;
for i = 1: length(bottomPoint) + length(topPoint)
    if (isempty(bottomPoint))
        combinedPoint(i) = topPoint(i);     
    elseif(isempty(topPoint))     
        combinedPoint(i) = bottomPoint(i);
    elseif (isempty(bottomPoint) && isempty(topPoint))
       break; 
    end
    if (i <= length(bottomPoint))
        combinedPoint(i) = bottomPoint(i);
    else
       combinedPoint(i) = topPoint(i - length(bottomPoint)); 
    end
end
combinedPoint = unique(combinedPoint);
%=========================================================================%
subData = cell(length(combinedPoint) + 1,1);
subData{1} = input(1: combinedPoint(1)-fs);
if combinedPoint(end) < length(input) - fs -1
   subData{end} = input(combinedPoint(end) + fs : length(input)); 
end
for i = 1: length(combinedPoint)-1
    subData{i+1} = input(combinedPoint(i) + fs : combinedPoint(i+1) - fs);
end
for i = 1:  length(subData)
   if length(subData{i}) < 3*fs
     subData{i} = [];
     j = j + 1;
   end
end
finalData = cell(j,1);
k = 1;
for i = 1 : length(subData)
   if (~isempty(subData{i}))
       finalData{k} = subData{i};
       k = k+1;
   end
end
figure;
plot(input)
hold on
plot(maxPoint, input(maxPoint),'r');
plot(minPoint, input(minPoint),'r');
plot(1: length(input), aveMax*ones(length(input),1),'g');
plot(1: length(input), aveMin*ones(length(input),1),'g');
if (flag1 == 0)
   plot(bottomPoint, input(bottomPoint),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
end
if(flag2 == 1)
   plot(topPoint, input(topPoint),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
end 
if(flag3 == 1)
    plot(cutPoint(:,1), input(cutPoint(:,1)),'r*','MarkerEdgeColor','g','MarkerFaceColor','r','MarkerSize',6); 
    plot(cutPoint(:,2), input(cutPoint(:,2)),'r*','MarkerEdgeColor','g','MarkerFaceColor','r','MarkerSize',6); 
end
 

end


