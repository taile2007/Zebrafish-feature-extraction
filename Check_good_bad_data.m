clc
clear all
close all

noSignal = 11;

for i = 1: noSignal
    name = sprintf('zebrafish_ECG%d.txt',i);
    pathfile = fullfile('E:\Study\Hung_Cao_Hero Lab\Collabration_Hero_Lab\zebraFishDrYang\convertTo1000Hz\newData\9m wt\male',name);
    input = load(pathfile);
    len(i) = length(input)';
    figure, plot(input);
end