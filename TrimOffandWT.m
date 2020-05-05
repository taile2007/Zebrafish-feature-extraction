%%
%* Author: Tai Le
%* tail3@uci.edu
%%
clear all;  % Clear workspace
clc;        % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing.
%==========================Instruction=====================================
% The input should be two column with number in the fist one
%Firstly, trim off unwanted data into segments
%Secondly, WT is used to process for each segments
noSignal = 3; % the number of signal in your dataset
Fs = 1000;
for u = 1 : noSignal
    name = sprintf('SA_%d.txt', u);
    dataPath = fullfile('\\udrive.uw.edu\udrive\ML_ECG_EEG\dataSet\RAW ECG database\SA',name);
    input1 = load(dataPath);
    input1 = input1(:,2);
%     figure, subplot (211);plot(input1);
%     subplot(212)
%     %%
%     %===========================Spectrum Power Density ========================
%     NFFT=2048;                 
%     X1=fftshift(fft(input1,NFFT));         
%     Px1=X1.*conj(X1)/(NFFT*length(input1)); %Power of each freq components         
%     fVals=Fs*(-NFFT/2:NFFT/2-1)/NFFT;  
%     plot(fVals,10*log10(Px1),'b');         
%     title('Power Spectral Density of signal');         
%     xlabel('Frequency (Hz)')         
%     ylabel('Power(dB)');
    %%
    %For data with high noise
%      ===========================Power line process=========================%
%     a = fir1(500,[55/500 65/500],'stop');
%     x = filtfilt(a,1,input1);
%     b = fir1(500,150/500,'low');
%     input1 = filtfilt(b,1,x); 
%     figure,subplot(211)
%     plot(input1,'r')
%      subplot(212)
    %%
%     %===========================Spectrum Power Density ========================
    NFFT=4096;                 
    X1=fftshift(fft(input1,NFFT));         
    Px1=X1.*conj(X1)/(NFFT*length(input1)); %Power of each freq components         
    fVals=Fs*(-NFFT/2:NFFT/2-1)/NFFT;  
    plot(fVals,10*log10(Px1),'b');         
    title('Power Spectral Density of signal');         
    xlabel('Frequency (Hz)')         
    ylabel('Power(dB)');
    %%
    %=====================================================================%
    %input(:,2)  = interp(input1(:,2),10);
    %finalData = extractNoise( interp(input1(:,2),10) ,1000,5 );
    finalData = extractNoise( input1 ,1000,5 );
    %===========================Loading all data sets==========================
    noOfData = length(finalData);

    %%
    finalOutput = preProcessingWT(noOfData,finalData,u);
   
end






