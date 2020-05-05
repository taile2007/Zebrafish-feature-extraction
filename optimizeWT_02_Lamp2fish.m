
%==================================NOTICE==================================
%1. You should remove any words such as Time or ECG in your file.
%2. Notice the format of data:
%   if data have two columns as [Time  ECG] --refer line 15
%   if data have 1 clolumn as [ECG] --comment line 15
%3. Locate those two files: optimizeWT_02.m and thrFunction.m in folder
%contains the data.
%==================================END=====================================
clc; clear all; close all;
noOfData = 1;
fishPackage = cell(noOfData,1);
for i = 1 : noOfData
    name = sprintf('fish%d.txt', i);
    dataPath = fullfile('E:\HOC_TAP\Hung_Cao_Hero Lab\Zebrafish_Project\zebrafishDatabase\lamp2_ECG\lamp2 fish 09282017\lamp Hom and GFP-',name);
    fishPackage{i} = load(dataPath);

end
%================Remove noisy interval fist================================
x = load('E:\HOC_TAP\Hung_Cao_Hero Lab\Zebrafish_Project\zebrafishDatabase\lamp2_ECG\lamp2 fish 09282017\lamp Hom and GFP-\fish1.txt');
figure,plot(x(:,2))
% size = 4096*7;%round(log2(length((fishPackage{1})))) - 1;
% x = x(200000:4096*7 + 200000-1,2);
size = 4096*4;%round(log2(length((fishPackage{1})))) - 1;
x = x(220000:4096*4 + 220000-1,2);
start = 1;
Fs = 1000;

%===========================Nomalization of signal=========================
% x = fishPackage{2}(start:start+size-1,2);
% x = (x - max(x))/(max(x) - min(x));
% figure,plot(x);
%===========================Spectrum Power Density ========================
NFFT=1024;                 
X1=fftshift(fft(x,NFFT));         
Px1=X1.*conj(X1)/(NFFT*length(x)); %Power of each freq components         
fVals=Fs*(-NFFT/2:NFFT/2-1)/NFFT;  
figure;
plot(fVals,10*log10(Px1),'b');         
title('Power Spectral Density of signal');         
xlabel('Frequency (Hz)')         
ylabel('Power(dB)');
%===========================Power line process============================%
% a = fir1(500,[55/500 65/500],'stop');
% x = filtfilt(a,1,x);
% b = fir1(500,400/500,'low');
% x = filtfilt(b,1,x);
% figure,plot(x)
%=========================================================================%

[swa,swd]=swt(x,10,'coif5');
%ThreshML = wthrmngr('sw1ddenoLVL','penallo',swd,1.5);
%thr = wthrmngr('sw1ddenoLVL','penallo',swtdec,alpha)
ThreshML = wthrmngr('sw1ddenoLVL','sqrtbal_sn',swd,'sln');
%bal_sn  sqrtbal_sn
% sqtwolog: universal thereshold
% thr = wthrmngr('sw1ddenoLVL','sqtwolog',swtdec,scale)
% thr = wthrmngr('sw1ddenoLVL','rigrsure',swtdec,scale)
% thr = wthrmngr('sw1ddenoLVL','heursure',swtdec,scale)
% thr = wthrmngr('sw1ddenoLVL','minimaxi',swtdec,scale)
% mln is scale: one, sln
% figure;
% for i=1:1:5
% subplot(5,2,2*i-1);plot(swa(i,:));
% title(['0-',num2str(500/2^i),'Hz']);
% subplot(5,2,2*i);plot(swd(i,:));
% title([num2str(500/2^i),'-',num2str(500/2^(i-1)),'Hz']);
% end
% figure;
% for i=6:1:10
% subplot(5,2,2*(i-5)-1);plot(swa(i,:));
% title(['0-',num2str(500/2^i),'Hz']);
% subplot(5,2,2*(i-5));plot(swd(i,:));
% title([num2str(500/2^i),'-',num2str(500/2^(i-1)),'Hz']);
% end

selectThrFunc = '1';
for i = 1: length(ThreshML)
   nswd(i,:) =  thrFunction(swd(i,:), ThreshML(:,i), selectThrFunc);
end
%nswd(9,:) = thrFunction(swd(9,:), ThreshML(:,8), selectThrFunc);
nswd(10,:) = zeros(1,size);
nswa(10,:) = zeros(1,size);
new = iswt(nswa, nswd,'coif5');
time=0:size-1;

figure;
plot(time,new,'r'); 
xlabel('Time (msec)');ylabel('Voltage(V)')
hold on;plot(x); title('RAW & FILTERED signal');
xlabel('Time (msec)');ylabel('Voltage(V)')
legend('Filtered signal','Raw signal')
figure;
subplot(2,1,1);plot(time,new); title('FILTERED signal');
xlabel('Time (msec)');ylabel('Voltage(V)')
subplot(2,1,2);plot(x); title('RAW signal');
xlabel('Time (msec)');ylabel('Voltage(V)')
