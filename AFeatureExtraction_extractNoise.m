clear all;  % Clear workspace
clc;        % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing.
% What you need to edit:
%1) Enter the number of signal you want to analyze (line 12)
%2) Copy the link of folder that contains your data (line 20)
%3) Change the name of your data name (lin 18)
%4) Delete excel files in Result folder !!!!
%5) Change SA criteria
%6) Change the name of excel file you want to save (line 15)
noSignal = 1;
% SA_criteria = 1.2; % Change the SA criteria
test = xlsread('frog ecg raw.xlsx');
figure,plot(test);
for u = 1 : noSignal
    name01 = sprintf('ECG signal_1 years %d.xlsx',u+3);
    pathOfResult = fullfile('Results\',name01);
%     A = [12.7 5.02 -98 63.9 0 -.2 56];
%     xlswrite(pathOfResult,A)
    name = sprintf('zebrafish_ECG%d.txt', u+3);
    %ECG_Data_2.23.2019_9.55 AM_filtered_data.txt
    dataPath = fullfile('E:\Study\Hung_Cao_Hero Lab\Collabration_Hero_Lab\zebraFishDrYang\convertTo1000Hz\newData\1 years wt',name);
    input = load(dataPath);
    input = -test;
    %input = input(1:120000);
    [row col] = size(input);
    if (col == 1)
        finalData = extractNoise( input ,1000,5 );
    else
        finalData = extractNoise( input(:,2) ,1000,5 );
    end
   
    noOfData = length(finalData);
    finalOutput = preProcessingWT(noOfData,finalData,u);
    finalData = finalOutput';
    noOfData = length(finalData);
    %===========================Loading all data sets==========================
  
    fishPackage = cell(noOfData,1);
    fishPackage2 = cell(noOfData,1);

    %========================Declare constant==================================
    Fs = 1000;
    RR_interval = 60;% 60 for fs = 1000; 8 for fs = 100
    slopeLevel = 5;% 5 for fs = 1000; 3 for fs =100
    windowLevel = 100;% 100 for fs = 1000; 8 for fs = 100
    QS_window = 6;% 6 for fs = 1000; 2 for fs = 100
    threshold = zeros(1,1);
    Q_wave = cell(noOfData,1);
    S_wave = cell(noOfData,1);
    P_wave = cell(noOfData,1);
    T_wave = cell(noOfData,1);
    peak = cell(noOfData,1);
    x = cell(noOfData,1);
    R_peak = cell(noOfData,1);
    R_peak_final = cell(noOfData,1);
    %=======================Debug==============================================
    no = 1;
    flag1 = 1;
    flag2 = 0;
    flag3 = 0;
    %==========================================================================
    for i = 1 : noOfData
        name_sheet = sprintf('Segment %d',i);
        fishPackage{i}(:,2) = finalData{i};
        fishPackage{i}(:,1) = 1: length(finalData{i});
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
        threshold(i) = mean(peak{i}(:,2));
        %=================================Debug====================================
        if (flag3 ==1)
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
            flag3 = 1;
        end
        %==========================================================================
        if (flag1 ==1)
            peak{i}(peak{i}(:,2) > 15*threshold(i),:)=[];
            threshold(i) = mean(peak{i}(:,2)); % Tinh lai threshold sau khi loai nhung dinh lon hon 40* old Threshold cu
            peak{i}(peak{i}(:,2)<0.7*threshold(i),:)=[];
        end
        if (flag3 == 1)
            figure
            plot(fishPackage{i}(:,2));
            title(['ECG signal part ', num2str(i)]);
            xlabel('Sample')
            ylabel('Amplitude')
            hold on
            xlim([0 length(fishPackage{i}(:,2))])
            plot(peak{i}(:,1),fishPackage{i}(peak{i}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
        end
        %%=================================Finalize R =============================

        for j = 1:length(peak{i}(:,1))
            if ((peak{i}(j,1) + RR_interval+50) > length(fishPackage{i}(:,1)))
                 break;
            end
        temp(j,:)=((peak{i}(j,1) - RR_interval-20 : peak{i}(j,1) + RR_interval+50)); % tim trong khoang 37 truoc va 37 sau

        R_peak{i}(j,1) = max_find(fishPackage{i}(:,2),temp(j,:));
        end
        %%
        
        %==========================Peak Final=====================================
        meanDistance = mean(diff(R_peak{i}(:,1)));
        segment_HR = (60*Fs)./diff(R_peak{i}(:,1));
        Average_HR(i) = 60/meanDistance*Fs;
        Average_std(i) = std(segment_HR);
        R_peak_final{i}(:,1)= R_peak{i}(:,1);
        R_peak_final{i}(:,2) = fishPackage{i}(R_peak{i}(:,1),2);
        RR_interval_title = {'RR Interval(s)'};
        xlswrite(pathOfResult,RR_interval_title, name_sheet,'A1');
        xlswrite(pathOfResult,((diff(R_peak_final{i}(:,1))/Fs)), name_sheet,'A2');
       % xlswrite(pathOfResult,std((diff(R_peak_final{i}(:,1))/Fs)), name_sheet,'A3');
        R_amplitude = {'R amplitude'};
        xlswrite(pathOfResult,R_amplitude, name_sheet,'B1');
        xlswrite(pathOfResult,R_peak_final{i}(:,2), name_sheet,'B2');
        %%
        figure
        plot(fishPackage{i}(:,2));
        title(['ECG signal part PEAK FINAL ', num2str(i)]);
        xlabel('Sample')
        ylabel('Amplitude')
        hold on
        xlim([0 length(fishPackage{i}(:,2))])
        plot(R_peak_final{i}(:,1),fishPackage{i}(R_peak_final{i}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
        %====================Trim off meaningless data==============================
        if(flag1 ==1)
          distance = diff(R_peak_final{i}(:,1));
          temp = zeros(length(distance),1);
          k = 0;
          for j = 1 : length(distance) - 2
             if (distance(j) >= 2.5* distance(j+1)) && (distance(j+1) <= 0.5 * distance (j+2))  
                 k = k+1;
                 temp(k) = j;
             end
          end
         temp_02 = zeros(k,1);
         for m = 1: length(temp_02)
            temp_02(m) = temp(m); 
         end
          if R_peak_final{i}(temp_02(1: length(temp_02)) +1,2) > R_peak_final{i}(temp_02(1: length(temp_02)) +2,2)
             R_peak_final{i}(temp_02(1: length(temp_02)) + 2,:) = []; % delete 
         else
              R_peak_final{i}(temp_02(1: length(temp_02)) +1 ,:) = []; % delete 
         end
%         j = 0;
%         temp = zeros(length(distance),1);
%          for k  = 1 :length(distance) -4
%             if(k == length(R_peak_final{i}(:,1)-1))
%                 break;
%             end
%             a = R_peak_final{i}(k+2,1) - R_peak_final{i}(k+1,1);
%             b = R_peak_final{i}(k+1,1) - R_peak_final{i}(k,1);
%             if(a >= 3*b || a <= 0.7* b)
%                 j = j +1;
%                 temp(j) = k; 
%             end
%          end
%          temp_02 = zeros(j,1);
%          for m = 1: length(temp_02)
%             temp_02(m) = temp(m); 
%          end
%          
%          if R_peak_final{i}(temp_02(1: length(temp_02)) + 2,2) > R_peak_final{i}(temp_02(1: length(temp_02)) + 3,2)
%              R_peak_final{i}(temp_02(1: length(temp_02)) + 3,:) = []; % delete 
%          else
%               R_peak_final{i}(temp_02(1: length(temp_02)) + 2,:) = []; % delete 
%          end
         
%         for k = 1:length(distance)-3;
%             flag1 = 1;
%         
%             for j = 1:3;
%                 if((distance(k+j)<0.7*distance(k))||(distance(k+j)>1.3*distance(k)))
%                     flag1 = 0;
%                     break;
%                 end
%             end
%                 if(flag1 == 1)
%                     averageRPeak = (distance(k)+distance(k+1)+distance(k+2)+distance(k+3))/4;
%                 end
%         end
        
        
%         for k=1:length(R_peak_final{i}(:,1))-1
%             if(k==length(R_peak_final{i}(:,1)-1))
%                 break;
%             end
%             if((R_peak_final{i}(k+1,1) - R_peak_final{i}(k,1))<0.6*averageRPeak)
%                 R_peak_final{i}(k+1,:) = [];
%                 k = k-1;
%             end
%         end
        end

        %%
        if (flag1 ==1)
        figure
        plot(fishPackage{no}(:,2));
        title('ECG signal Peak Final_TEST');
        xlabel('Sample')
        ylabel('Amplitude')
        hold on
        xlim([0 length(fishPackage{no}(:,2))])
        plot(R_peak_final{no}(:,1),fishPackage{no}(R_peak_final{no}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
        end

        %%
        %============================SA detection=================================%
        SA_criteria = [1.1, 1.2, 1.3, 1.4];
        columnSAfrequency = {'G1','H1','I1','J1'};
        columnSAvalue ={'G2','H2','I2','J2'};
        columnRRinterval ={'G3','H3','I3','J3'};
        columnRRvalue ={'G4','H4','I4','J4'};
        RR_temp = diff(R_peak_final{i}(:,1))/Fs;
        RR_counter = 0;
        SA_counter = 0;
        isSA_flag = 0;
        for k = 1: length(SA_criteria)
            for j = 1: length(RR_temp)
                if (RR_temp(j) > SA_criteria(k))
                    isSA_flag = 0;
                    RR_counter = RR_counter + 1;
%                    SA_index_front(RR_counter) = R_peak_final{i}(j,1);
 %                   SA_index_after(RR_counter) = R_peak_final{i}(j+1,1);
                end
                if (j >2 && RR_temp(j) > SA_criteria(k) && RR_temp(j) > 2*RR_temp(j - 1))
                    SA_counter = SA_counter +1;
                end
            end
            SA_title = {['SA frequency with ', num2str(SA_criteria(k))]};
            xlswrite(pathOfResult,SA_title, name_sheet,columnSAfrequency{k});
            xlswrite(pathOfResult,SA_counter, name_sheet,columnSAvalue{k});
            RR_title = {['RR interval with ', num2str(SA_criteria(k))]};
            xlswrite(pathOfResult,RR_title, name_sheet, columnRRinterval{k});
            xlswrite(pathOfResult,RR_counter, name_sheet,columnRRvalue{k});
            
            SA_counter = 0;
            RR_counter = 0;
        end
        if (isSA_flag == 1)
            figure
            plot(fishPackage{i}(:,2));
            title(['ECG signal part with SA marker', num2str(i)]);
            xlabel('Sample')
            ylabel('Amplitude')
            hold on
            xlim([0 length(fishPackage{i}(:,2))])
            plot(R_peak_final{i}(:,1),fishPackage{i}(R_peak_final{i}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
            plot(SA_index_front, fishPackage{i}(SA_index_front,2),'g*','MarkerEdgeColor','g','MarkerFaceColor','k','MarkerSize',6);
            plot(SA_index_after, fishPackage{i}(SA_index_after,2),'g*','MarkerEdgeColor','g','MarkerFaceColor','k','MarkerSize',6);
            
        end
           % SA_index_front = [];
            %SA_index_after = [];
        

        %%
        if (flag1 == 2) % hide figures
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
        [Q_wave{i}, S_wave{i}] = findQS(fishPackage{i} ,R_peak_final{i}, QS_window);
        QRS_duration = S_wave{i}(1:end-1) - Q_wave{i}(1:end-1);
        QRS_title = {'QRS Duration'};
        xlswrite(pathOfResult,QRS_title, name_sheet,'C1');
        xlswrite(pathOfResult,QRS_duration/Fs, name_sheet,'C2');
        if (flag1 == 10) % hide figure
            figure
            plot(fishPackage{i}(:,2));
            title(['Plot Q,R,S wave on ECG signal part ',num2str(i)]);
            xlabel('Sample')
            ylabel('Amplitude')
            hold on
            plot(R_peak_final{i}(:,1),fishPackage{i}(R_peak_final{i}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
            plot(Q_wave{i}(1:length(Q_wave{i}) - 1,1),fishPackage{i}(Q_wave{i}(1:length(Q_wave{i}) - 1,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
            plot(S_wave{i}(1:length(S_wave{i}) - 1,1),fishPackage{i}(S_wave{i}(1:length(S_wave{i}) - 1,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',6);
        end


        %%
        %====================== Find P wave & T wave===============================
         [P_wave{i}, T_wave{i}, T_wave_offset{i}] = findPT(fishPackage{i}(:,2),R_peak_final{i}(:,1), Q_wave{i},S_wave{i});
         P_amplitude_title = {'P amplitude'};
         xlswrite(pathOfResult,P_amplitude_title, name_sheet,'D1');
         xlswrite(pathOfResult,P_wave{i}(2:end-1,2), name_sheet,'D2');
         PP_interval = {'PP interval'};
         xlswrite(pathOfResult,PP_interval, name_sheet,'E1');
         xlswrite(pathOfResult,diff(P_wave{i}(2:end-1,1))/Fs, name_sheet,'E2');
         HR_title = {'HR(BPM)'};
         xlswrite(pathOfResult,HR_title, name_sheet,'F1');
         xlswrite(pathOfResult,60./(diff(R_peak_final{i}(:,1))/Fs), name_sheet,'F2');
        if (flag1 == 1)
            figure
            plot(fishPackage{i}(:,2));
            title(['QRS and P, T Waves part ', num2str(i)]);
            hold on;

            plot(R_peak_final{i}(:,1),fishPackage{i}(R_peak_final{i}(:,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
            plot(Q_wave{i}(2:length(Q_wave{i}) - 1,1),fishPackage{i}(Q_wave{i}(2:length(Q_wave{i}) - 1,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6);
            plot(S_wave{i}(2:length(S_wave{i}) - 1,1),fishPackage{i}(S_wave{i}(2:length(S_wave{i}) - 1,1),2),'ro','MarkerEdgeColor','r','MarkerFaceColor','k','MarkerSize',6);
            plot(P_wave{i}(2:end-1,1),fishPackage{i}(P_wave{i}(2:end-1,1),2),'g*','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',6); 
            plot(T_wave{i}(2:length(T_wave{i}) - 1,1),fishPackage{i}(T_wave{i}(2:length(T_wave{i}) - 1,1),2),'g*','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',6); 
           % plot(T_wave_offset{i}(:,1),fishPackage{i}(T_wave_offset{i}(:,1),2),'g+','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6); 
        end
        Average_Pwave(i) = sum(abs(P_wave{i}(:,2)))/(length(P_wave{i}) - 2);
        
        Average_Rwave(i) = sum(abs(R_peak_final{i}(2:end-1,2)))/(length(R_peak_final{i}) - 2);
        
        Ratio(i) =  Average_Pwave(i)/Average_Rwave(i);
        Average_RR(i) = sum(abs(diff(R_peak_final{i}(2:end-1,1)))/Fs)/(length(R_peak_final{i}) - 2);
        %Average_RT(i) = sum(abs(R_peak_final{i}(1:length(R_peak_final{i}) - 1,1) - T_wave{i}(1:length(T_wave{i}) - 1,1))/Fs)/(length(T_wave{i}) - 1);
        Average_RT(i) = sum(abs(R_peak_final{i}(1:length(R_peak_final{i}) - 1,1) - T_wave{i}(1:length(T_wave{i}) - 1,1))/Fs)/(length(T_wave{i}) - 1);
        Average_QT(i) = sum(abs(Q_wave{i}(1:length(R_peak_final{i}) - 1,1) - T_wave_offset{i}(:,1)))/(length(T_wave{i}) - 1);
        QTc(i) =(Average_QT(i).*10)./sqrt(Average_RR(i));
        RTc(i) =(Average_RT(i).*10)./sqrt(Average_RR(i));
       
        %NoRPeak(i) = length(P_wave{i});
        %%
    end
    mean_Average_Pwave(u) = mean(Average_Pwave);
    mean_Average_Rwave(u) = mean(Average_Rwave);
    mean_Ratio(u) = mean(Ratio);
    mean_Average_HR(u) = mean(Average_HR);
    mean_Average_std(u) = mean(Average_std);
    %mean_Average_RT(u) = mean(Average_RT);
    mean_Average_RR(u) = mean (Average_RR);
    mean_QTc(u) = mean(QTc);
    mean_RTc(u) = mean(RTc);
    
end
Ave_Ratio = mean_Ratio';
% Ave_RT = Average_RT';
% Ave_QT = Average_QT';
% NoR = NoRPeak';
% A_QTc = QTc';
% A_RTc = RTc';
Ave_RR = mean_Average_RR';
Ave_HR = mean_Average_HR';
Ave_std = mean_Average_std';
Ave_R = mean_Average_Rwave';
Ave_RTc = mean_RTc';
Ave_QTc = mean_QTc';





