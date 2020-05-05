clc;
clear all;
close all;
fishData = load('fish10.txt');
namefile = 'fish9x.txt';
signal_interval2 = 1: 100000;
signal_interval1 = 1: length(signal_interval2);
flag = 0;
if (flag == 0)
    ecg_count(:,1) = 1:length(fishData);
    ecg_count(:,2) = fishData(1:length(fishData),2);
    ecg_zebrafish = [ecg_count(:,1) ecg_count(:,2)];
    plot(ecg_count(:,2));
else
    ecg_count(:,1) = signal_interval1;
    ecg_count(:,2) = fishData(signal_interval2,2);
    ecg_zebrafish = [ecg_count(:,1) ecg_count(:,2)];
    dlmwrite(namefile,ecg_zebrafish,'delimiter','\t');
end



