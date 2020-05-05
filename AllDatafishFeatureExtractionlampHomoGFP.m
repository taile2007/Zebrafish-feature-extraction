clear all;  % Clear workspace
clc;        % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing


%===========================Loading all data sets==========================
noOfData = 3;
fishPackage = cell(noOfData,1);

%========================Declare constant==================================
Fs = 1000;
RR_interval = 60;% 60 for fs = 1000; 8 for fs = 100
slopeLevel = 5;% 5 for fs = 1000; 3 for fs =100
windowLevel = 100;% 100 for fs = 1000; 8 for fs = 100
Q_wave = cell(noOfData,1);
S_wave = cell(noOfData,1);
P_wave = cell(noOfData,1);
T_wave = cell(noOfData,1);
T_wave_offset = cell(noOfData,1);
peak = cell(noOfData,1);
x = cell(noOfData,1);
R_peak = cell(noOfData,1);
R_peak_final = cell(noOfData,1);
%=======================Debug==============================================
no = 1;
flag = 1;

%==========================================================================
for i = 1 : noOfData
    name = sprintf('fish%dx.txt', i+6);
%     dataPath = fullfile('E:\HOC_TAP\Hung_Cao_Hero Lab\Zebrafish_Project\zebrafishDatabase\lamp2_ECG\lamp2 fish 09282017\lamp Hom and GFP-',name);
    fishPackage{i} = load(name);
    fishPackage{i}(:,1) = 1: length(fishPackage{i}(:,2));
    figure,
    plot(fishPackage{i}(:,2));
    %===================Remove baseline first==================================
    fDomain = fft(fishPackage{i}(:,2)); 
    fDomain(1 : round(length(fDomain)*3/Fs))=0; 
    fDomain(end - round(length(fDomain)*3/Fs) : end)=0; 
    fishPackage{i}(:,2) = real(ifft(fDomain));
    hold on, plot(fishPackage{i}(:,2),'r');
   
    %===========================Spectrum Power Density ========================
    % NFFT=4096;                 
    % X1=fftshift(fft(ecg_zebrafish(:,2),NFFT));         
    % Px1=X1.*conj(X1)/(NFFT*length(ecg_zebrafish)); %Power of each freq components         
    % fVals=Fs*(-NFFT/2:NFFT/2-1)/NFFT;  
    % figure;
    % plot(fVals,10*log10(Px1),'b');         
    % title('Power Spectral Density of Geless signal');         
    % xlabel('Frequency (Hz)')         
    % ylabel('Power(dB)');
    %===========================Slope calculation==============================
    x{i} = differential(fishPackage{i}(:,2),slopeLevel).^2;

    %=========================Peak Detection===================================
    %%
    peak{i} = max_detection(x{i},windowLevel);
  
    %%
    %============================= Peak remove=================================
    % Nhung dinh nao ma co Amplitude > 4* the average of amplitude
    % The peaks which are less than 0.8 * the average of amplitude  is removed.
    threshold = zeros(1,1);
    threshold(i) = mean(peak{i}(:,2));
    %=================================Debug====================================
    if (flag ==1)
        figure
        plot(x{no});
        title('Peak of Slope signal');
        xlabel('Sample')
        ylabel('Amplitude')
        hold on
        plot(peak{no}(:,1),x{no}(peak{no}(:,1)),'ro','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6);
        threshold(i) = mean(peak{no}(:,2));
        peak{no}(peak{no}(:,2) > 20*threshold(i),:)=[];
        length(peak{no}(:,1));
        plot(peak{no}(:,1),x{no}(peak{no}(:,1)),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
        threshold(i) = mean(peak{no}(:,2)); % Tinh lai threshold sau khi loai nhung dinh lon hon 40* old Threshold cu
        figure
        title('Tin Hieu Do Doc Final');
        xlabel('Sample')
        ylabel('Amplitude')
        hold on
        plot(peak{no}(:,1),x{no}(peak{no}(:,1)),'ro','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6);
        peak{no}(peak{no}(:,2)< threshold(i),:)=[];
        length(peak{no}(:,1))
        plot(peak{no}(:,1),x{no}(peak{no}(:,1)),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
        legend('DinhLoaiBo','DinhGiuLai');
        plot(x{no});
    end
    %==========================================================================
    if (flag ==0)
        peak{i}(peak{i}(:,2) > 20*threshold(i),:)=[];
        threshold(i) = mean(peak{i}(:,2)); % Tinh lai threshold sau khi loai nhung dinh lon hon 40* old Threshold cu
        peak{i}(peak{i}(:,2)< threshold(i),:)=[];
    end
    %%=================================Finalize R =============================
    
    for j = 1:length(peak{i}(:,1));

    temp(j,:)=((peak{i}(j,1) - RR_interval : peak{i}(j,1) + RR_interval)); % tim trong khoang 37 truoc va 37 sau

    R_peak{i}(j,1) = max_find(fishPackage{i}(:,2),temp(j,:));
    end
    %%
    %==========================Peak Final=====================================
    meanDistance = mean(diff(R_peak{i}(:,1)));
    Average_HR(i) = 60/meanDistance*Fs;
    R_peak_final{i}(:,1)= R_peak{i}(:,1);
    R_peak_final{i}(:,2) = fishPackage{i}(R_peak{i}(:,1),2);
    %%
    %====================Trim of meaningless data==============================
    if(flag ==2)
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
    end

    %%
    if (flag ==1)
    figure
    plot(fishPackage{no}(:,2));
    title('ECG signal');
    xlabel('Sample')
    ylabel('Amplitude')
    hold on
    xlim([0 length(fishPackage{no}(:,2))])
    plot(R_peak_final{no}(:,1),fishPackage{no}(R_peak_final{no}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
    end

    %%
    %============================SA detection=================================%
    if (flag == 2)
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
    end

    %%
    if (flag == 2)
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
    end

    %%
    %============================Q & S detection===============================   
    [Q_wave{i}, S_wave{i}] = findQS(fishPackage{i} ,R_peak_final{i}, 6);
    if (flag == 1)
        figure
        plot(fishPackage{no}(:,2));
        title('Plot Q,R,S wave on ECG signal');
        xlabel('Sample')
        ylabel('Amplitude')
        hold on
        plot(R_peak_final{no}(:,1),fishPackage{no}(R_peak_final{no}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
        plot(Q_wave{no},fishPackage{no}(Q_wave{no},2),'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
        plot(S_wave{no},fishPackage{no}(S_wave{no},2),'ro','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',6);
    end


    %%
    %====================== Find P wave & T wave===============================
    [P_wave{i}, T_wave{i}, T_wave_offset{i}] = findPT(fishPackage{i}(:,2),R_peak_final{i}(:,1), Q_wave{i},S_wave{i});
    if (flag ==1)
        figure
        plot(fishPackage{no}(:,2));
        title('QRS and P, T Waves');
        hold on;
        
        plot(R_peak_final{no}(:,1),fishPackage{no}(R_peak_final{no}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
        plot(Q_wave{no},fishPackage{no}(Q_wave{no},2),'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
        plot(S_wave{no},fishPackage{no}(S_wave{no},2),'ro','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',6);
        plot(P_wave{no}(2:end,1),fishPackage{no}(P_wave{no}(2:end,1),2),'g*','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6); 
        plot(T_wave{no}(1:length(T_wave{no}) - 1,1),fishPackage{no}(T_wave{no}(1:length(T_wave{no}) - 1,1),2),'g*','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',6); 
        plot(T_wave_offset{no}(:,1),fishPackage{no}(T_wave_offset{no}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6); 
%         kkk = load('fish1x.txt');
%         plot(kkk(:,2),'r');
    end
    Average_Pwave(i) = (sum(P_wave{i}(:,2))/(length(P_wave{i}) - 1));
    Average_Rwave(i) = sum(R_peak_final{i}(2:length(R_peak_final{i}),2))/(length(R_peak_final{i})) - 1;
    Ratio(i) =  Average_Pwave(i)/Average_Rwave(i);
    Average_RT(i) = sum(abs(R_peak_final{i}(1:length(R_peak_final{i}) - 1,1) - T_wave{i}(1:length(T_wave{i}) - 1,1))/Fs)/(length(T_wave{i}) - 1);
    %=========================================================================%
    %%
    flag = 0;
end




