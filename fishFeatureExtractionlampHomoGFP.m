clear all;  % Clear workspace
clc;        % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing.

%===========================Display signal time domain=====================
noOfData = 3;
fishPackage = cell(noOfData,1);
% for i = 1 : noOfData
%     name = sprintf('fish%d.txt', i);
%     dataPath = fullfile('E:\HOC_TAP\Hung_Cao_Hero Lab\Zebrafish_Project\zebrafishDatabase\lamp2_ECG\lamp2 fish 09282017\lamp Hom and GFP-',name);
%     fishPackage{i} = load(dataPath);
% 
% end
fishData = load('newFish5.txt');

signal_interval2 = 1: 40000;
signal_interval1 = 1: length(signal_interval2);
flag = 0;
if (flag == 1)
    ecg_count(:,1) = 1:length(fishData);
    ecg_count(:,2) = fishData(1:length(fishData),2);
    ecg_zebrafish = [ecg_count(:,1) ecg_count(:,2)];
    plot(ecg_count(:,2));
else
    ecg_count(:,1) = signal_interval1;
    ecg_count(:,2) = fishData(signal_interval2);
    ecg_zebrafish = [ecg_count(:,1) ecg_count(:,2)];
    plot(ecg_count(:,2));
end
Fs = 1000;
RR_interval = 60;% 60 for fs = 1000; 8 for fs = 100
slopeLevel = 5;% 5 for fs = 1000; 3 for fs =100
windowLevel = 100;% 100 for fs = 1000; 8 for fs = 100

%===========================Spectrum Power Density ========================
NFFT=4096;                 
X1=fftshift(fft(ecg_zebrafish(:,2),NFFT));         
Px1=X1.*conj(X1)/(NFFT*length(ecg_zebrafish)); %Power of each freq components         
fVals=Fs*(-NFFT/2:NFFT/2-1)/NFFT;  
figure;
plot(fVals,10*log10(Px1),'b');         
title('Power Spectral Density of Geless signal');         
xlabel('Frequency (Hz)')         
ylabel('Power(dB)');

%===========================Slope calculation==============================
x = differential(ecg_zebrafish(:,2),slopeLevel).^2;
figure
plot(x);
title('Slope Signal');
xlabel('Sample')
ylabel('Amplitude')

%=========================Peak Detection===================================
peak = max_detection(x,windowLevel);
length(peak(:,1));
% figure
% plot(x);
% title('Peak of Slope signal');
% xlabel('Sample')
% ylabel('Amplitude')
% hold on
% plot(peak(:,1),x(peak(:,1)),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);


%============================= Peak remove=================================
% Nhung dinh nao ma co Amplitude > 4* the average of amplitude
% The peaks which are less than 0.8 * the average of amplitude  is removed.
threshold = mean(peak(:,2));
figure
plot(x);
title('Peak of Slope signal');
xlabel('Sample')
ylabel('Amplitude')
hold on
plot(peak(:,1),x(peak(:,1)),'ro','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6);
  threshold = mean(peak(:,2));
  peak(peak(:,2) > 20*threshold,:)=[];
  length(peak(:,1));
  plot(peak(:,1),x(peak(:,1)),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
  threshold = mean(peak(:,2)); % Tinh lai threshold sau khi loai nhung dinh lon hon 40* old Threshold cu
%%

%%
figure
title('Tin Hieu Do Doc Final');
xlabel('Sample')
ylabel('Amplitude')
hold on
plot(peak(:,1),x(peak(:,1)),'ro','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6);
peak(peak(:,2)< threshold,:)=[];
length(peak(:,1))
plot(peak(:,1),x(peak(:,1)),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
legend('DinhLoaiBo','DinhGiuLai');
plot(x);

% figure
% plot(ecg_zebrafish(:,2));
% title('ECG signal');
% xlabel('Sample')
% ylabel('Amplitude')
% hold on
% xlim([0 length(ecg_zebrafish)])
% plot(peak(:,1),ecg_zebrafish(peak(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
%%=================================TIM R ==============================
for i=1:length(peak(:,1));

    temp(i,:)=((peak(i,1) - RR_interval : peak(i,1) + RR_interval)); % tim trong khoang 37 truoc va 37 sau
    
    R_peak(i) = max_find(ecg_zebrafish(:,2),temp(i,:));
end
%%
%%
meanDistance = mean(diff(R_peak));

HR = 60/meanDistance*Fs;
fprintf('Average HeartRate is %f\n',HR);
R_peak_final = [R_peak' ecg_zebrafish(R_peak,2)];

%%
%%%%% Xu ly bi mat dinh bla bla%%%%%%%%%%%%%%%%%%
distance = diff(R_peak_final(:,1));
% j = 0;
% temp = zeros(length(distance),1);
%  for i  = 1 :length(distance) -4
%     if(i == length(R_peak_final(:,1)-1))
%         break;
%     end
%     a = R_peak_final(i+2,1) - R_peak_final(i+1,1);
%     b = R_peak_final(i+1,1) - R_peak_final(i,1);
%     if(a >= 3*b || a <= 0.7* b)
%         j = j +1;
%         temp(j) = i;
%         
%     end
%  end
%  R_peak_final(temp(1: length(temp)) + 2,:) = [];
% for i = 1:length(distance)-3;
%     flag = 1;
% 
%     for j = 1:3;
%         if((distance(i+j)<0.7*distance(i))||(distance(i+j)>1.3*distance(i)))
%             flag = 0;
%             break;
%         end
%     end
%         if(flag == 1)
%             averageRPeak = (distance(i)+distance(i+1)+distance(i+2)+distance(i+3))/4;
%         end
% end
% 
% 
% for i=1:length(R_peak_final(:,1))-1
%     if(i==length(R_peak_final(:,1)-1))
%         break;
%     end
%     if((R_peak_final(i+1,1) - R_peak_final(i,1))<0.6*averageRPeak)
%         R_peak_final(i+1,:) = [];
%         i = i-1;
%     end
% end
%%
figure
plot(ecg_zebrafish(:,2));
title('ECG signal');
xlabel('Sample')
ylabel('Amplitude')
hold on
xlim([0 length(ecg_zebrafish)])
plot(R_peak_final(:,1),ecg_zebrafish(R_peak_final(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
%%
%============================SA detection=================================%
j = 0;
SA_point = zeros(length(R_peak_final(:,1)),2);
for i = 1: length(R_peak_final(:,1)) - 3
    post = R_peak_final(i +2,1) - R_peak_final(i + 1,1);
    prior = R_peak_final(i +1,1) - R_peak_final(i,1);
   if (post >= 2*prior)
       j = j+1;
       SA_point(j,1) = R_peak_final(i+1,1);
       SA_point(j,2) = R_peak_final(i+2,1);
       
   end
end
if (j == 0)
    disp('No SA symtom');
    k = 0;
else
    k = 0;
    disp ('Yes SA symtom ')
    % Delete 0 value in SA_point
    for i = 1: length( SA_point(:,1))
       if (SA_point(i,1) ==0)
           if (k == 0)
           j = i;
           k = 1;
           end
       end
       j2 = i;  
    end
    SA_point(j:j2,:) =[];
end
%%
figure
plot(ecg_zebrafish(:,2));
title('Tin Hieu ECG');
xlabel('Sample')
ylabel('Amplitude')
hold on
xlim([0 length(ecg_zebrafish)])
plot(R_peak_final(:,1),ecg_zebrafish(R_peak_final(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
if (k == 1)
    plot(SA_point(:,1),ecg_zebrafish(SA_point(:,1),2),'ro','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',6);
    plot(SA_point(:,2),ecg_zebrafish(SA_point(:,2),2),'ro','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',6);
end
xlim([0 length(ecg_zebrafish)]);
%%
%============================Q & S detection=============================== 
[Q ,S] = findQS(ecg_zebrafish ,R_peak_final, 6);

length(R_peak_final(:,1))
figure
plot(ecg_zebrafish(:,2));
title('Tin Hieu ECG');
xlabel('Sample')
ylabel('Amplitude')
hold on
plot(R_peak_final(:,1),ecg_zebrafish(R_peak_final(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
plot(Q,ecg_zebrafish(Q,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
plot(S,ecg_zebrafish(S,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',6);
plot(1: length(ecg_zebrafish(:,1)), mean(ecg_zebrafish(:,2)), 'r');

%%
%====================== Find P wave & T wave===============================
[P_wave,T_wave] = findPT(ecg_zebrafish(:,2),Q,S,150, 150);
figure
plot(ecg_zebrafish(:,2));
hold on;
plot(R_peak_final(:,1),ecg_zebrafish(R_peak_final(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
plot(Q,ecg_zebrafish(Q,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
plot(S,ecg_zebrafish(S,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',6);
plot(P_wave(:,1),ecg_zebrafish(P_wave(:,1),2),'r*','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
plot(T_wave(1:length(R_peak_final)-1,1),ecg_zebrafish(T_wave(1:length(R_peak_final)-1,1),2),'g*','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',6);
%=========================================================================%
% plot(R_peak_final(1:length(R_peak_final)-1,1),ecg_zebrafish(R_peak_final(1:length(R_peak_final)-1,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
% plot(Q(1:length(R_peak_final)-1),ecg_zebrafish(Q(1:length(R_peak_final)-1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
% plot(S(1:length(R_peak_final)-1),ecg_zebrafish(S(1:length(R_peak_final)-1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',6);
% plot(P_wave((1:length(R_peak_final)-1),1),ecg_zebrafish(P_wave((1:length(R_peak_final)-1),1),2),'r*','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
% plot(T_wave(:,1),ecg_zebrafish(T_wave(:,1),2),'g*','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
%%
% %plot(T,ecg_zebrafish(T,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','b','MarkerSize',6);
% %%
% new_input = IsInverse(ecg_zebrafish(:,2) ,ecg_zebrafish(R_peak_final(:,1),2), ecg_zebrafish(S,2), ecg_zebrafish(Q,2));
% figure, plot(new_input);
% %%
% Fs=500;
% L=length(ecg_zebrafish(:,2));
% NFFT = 2^nextpow2(L);
% 
% fft_signal = fft(ecg_zebrafish(:,2),NFFT)/L;
% f_50hz = Fs/2*linspace(0,1,NFFT/2+1);
% amp_fft_signal_50hz=2*abs(fft_signal(1:NFFT/2+1));
% figure
% plot(f_50hz,20*log(amp_fft_signal_50hz));
% title('Pho Sau loc 50hz');
% xlabel('F(hz)')
% ylabel('Amplitude')
% figure
% plot(signal*100)
% hold on
% plot(diff(signal)*2000,'r');
% hold on
% %%%%DaoHam%%%%%%%
% diff1=diff(signal);
% %%%%DaoHam2%%%%%%
% diff2=diff(diff(signal));
% %%%%Tonset%%%%%%%
% for i=1:length(S)
%     point=S(i);
%     while(1)
%     if((diff2(point-1)<0||diff2(point-1)==0)&&(diff2(point+1)>0||diff2(point+1)==0))
%         Tonset(i)=point;
%         break;
%     else
%         point=point+1;
%         
%     end
%     end
% 
% end
% plot(diff2*100000,'k')
% plot(Tonset,diff2(Tonset)*100000,'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
% grid on
% figure
% plot(ecg_zebrafish(:,1),ecg_zebrafish(:,2));
% hold on
%  plot(Tonset,ecg_zebrafish(Tonset,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','b','MarkerSize',6);
% title('Tin Hieu Loc 100hz');
% xlabel('Sample')
% ylabel('Amplitude')
% 
% 
% 
% 
% ecg_filt_20hz=ecg_zebrafish;
% N=300;
% window=hamming(N+1);
% Wn1=[10]/(Fs/2);
% [b1 a1]=fir1(N,Wn1,'low',window);
% freqz(b1,a1)
% for i=1:length(Q)-1
%     A=ecg_zebrafish(Tonset(i):Q(i+1),2)-ecg_zebrafish(Tonset(i),2);
%     X=ecg_zebrafish(Tonset(i):Q(i+1),2);
%     A1=conv(b1,A);
%     A2=A1(N/2+1:length(X)+N/2)+ecg_zebrafish(Tonset(i),2);
%     ecg_filt_20hz(Tonset(i):Q(i+1),2)=A2;
% 
% end
% figure
% plot(ecg_filt_20hz(:,1),ecg_filt_20hz(:,2),'r');
% 
% 
% %%%%DaoHam%%%%%%%
% diff1=diff(ecg_filt_20hz(:,2));
% %%%%DaoHam2%%%%%%
% diff2=diff(diff(ecg_filt_20hz(:,2)));
% %%%%TIm T%%%%%%%
% for i=1:length(Tonset)-1
%     point=Tonset(i)+1;
%     while(1)
%     if((diff1(point-1)>0||diff1(point-1) == 0)&&(diff1(point+1)<0||diff1(point+1)==0))
%         T(i) = point;
%         break;
%     else
%         point = point+1;
%         
%     end
%     end
% 
% end
% %%%%Toffset%%%%%%
% for i=1:length(T)
%     point=T(i);
%     while(1)
%     if((diff2(point-1)>0||diff2(point-1)==0)&&(diff2(point+1)<0||diff2(point+1)==0))
%         Toffset(i)=point;
%         break;
%     else
%         point=point+1;
%         
%     end
%     end
% 
% end
% 
% hold on
%  plot(R_peak_final(:,1),ecg_filt_20hz(R_peak_final(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
%  plot(Q,ecg_filt_20hz(Q,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
%  plot(S,ecg_filt_20hz(S,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',6);
%  plot(T,ecg_filt_20hz(T,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','b','MarkerSize',6);
%  plot(Tonset,ecg_filt_20hz(Tonset,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','b','MarkerSize',6);
%  plot(Toffset,ecg_filt_20hz(Toffset,2),'ro','MarkerEdgeColor','r','MarkerFaceColor','b','MarkerSize',6);
%  
%  %%



