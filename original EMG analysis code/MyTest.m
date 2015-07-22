%%%%  Load EMG Data from TP01 %%%%
% Plots the acc magnitude curves
% Finds the peaks of the filtered acc data

[bfa,afa]=butter(3,25/(ax(1).freq/2));
clear amag amagf;
for i=1:3
    axf=filtfilt(bfa,afa,ax(i).data);
    ayf=filtfilt(bfa,afa,ay(i).data);
    azf=filtfilt(bfa,afa,az(i).data);
    amag(:,i)=(ax(i).data.^2+ay(i).data.^2+az(i).data.^2).^0.5;
    amagf(:,i)=(axf.^2+ayf.^2+azf.^2).^0.5;
%     subplot(410+i);
%     %Plots the raw acc data of x,y,z for each ankle and lumbar
%     plot(ax(1).time,[ax(i).data ay(i).data az(i).data]);
%     hold on;
%     %Plots the filtered acc data of x,y,z for each ankle and lumbar
%     %overlayed as dashes
%     plot(ax(1).time,[axf ayf azf],'--');
%     hold off
%     title(ax(i).label);
end

%Uses the magnitudes from filtered acc data and finds the peaks
clear hsr hsl hsrp hslp;
[hsr, hsrp]=findpeaks(amagf(:,1),'MinPeakHeight',2.,'MinPeakDistance',100);
[hsl, hslp]=findpeaks(amagf(:,2),'MinPeakHeight',2.,'MinPeakDistance',100);
% %Plots the peaks as x's and o's
% subplot(414);
% plot(ax(1).time,amagf,'-');
% hold on;
% plot(ax(1).time(hsrp),hsr, 'o');
% plot(ax(1).time(hslp),hsl,'x');
% hold off;

%Filter the EMG data
% Use 3 filters to remove non-EMG frequency range noise, drift, and
% then get nice activation envelopes - numbers are set for 2000 Hz
% collection
[b,a]=butter(4,0.35,'low'); %Used to remove high-frequency noise above 350Hz
[bb,aa]=butter(4,0.001,'high'); %Used to remove low-frequency drift below 1Hz
[bbb,aaa]=butter(4,0.01,'low'); %Used to filter to 10Hz to get envelope
for ii=1:12  
emgdatar(:,ii)=emg(ii).data; %Raw emg data - Here just pulling the matrix of data out of the structure I loaded

end
 EMfr=filtfilt(bb,aa,emgdatar); %Zero-shift filter removing drift first
 EMGr=filtfilt(b,a,EMfr); %Zero-shift filter removing high frequency noise
 EMGabs=abs(EMGr); %Rectify data
 emgdata=filtfilt(bbb,aaa,EMGabs); %Filter to envelopes of activation

%Computes the average emg cycle
clear emgc;
emgtime=emg(1).time;
for j=1:6
        emgc(j)=avgcycle(emgtime,emgdata(:,j),ax(1).time(hsrp),10,50);
        emgc(6+j)=avgcycle(emgtime,emgdata(:,6+j),ax(2).time(hslp),10,50);
end

%Normalize the EMG data
clear emgrms;
for j=1:12
    emgrms(j)=rms(emgdata(:,j));
    
    normemg(:,j)=(emgc(j).avg)./(emgrms(j));
    normemgstd(:,j)=(emgc(j).sd)./(emgrms(j));
end



%%%% Load EMG Data from TP02 %%%%
% Plots the acc magnitude curves
% Finds the peaks of the filtered acc data

[bfa2,afa2]=butter(3,25/(ax2(1).freq/2));
clear amag2 amagf2;
for i=1:3
    axf2=filtfilt(bfa2,afa2,ax2(i).data);
    ayf2=filtfilt(bfa2,afa2,ay2(i).data);
    azf2=filtfilt(bfa2,afa2,az2(i).data);
    amag2(:,i)=(ax2(i).data.^2+ay2(i).data.^2+az2(i).data.^2).^0.5;
    amagf2(:,i)=(axf2.^2+ayf2.^2+azf2.^2).^0.5;
end

%Uses the magnitudes from filtered acc data and finds the peaks
clear hsr2 hsl2 hsrp2 hslp2;
[hsr2, hsrp2]=findpeaks(amagf2(:,1),'MinPeakHeight',2.,'MinPeakDistance',100);
[hsl2, hslp2]=findpeaks(amagf2(:,2),'MinPeakHeight',2.,'MinPeakDistance',100);

%Filter the EMG data
% Use 3 filters to remove non-EMG frequency range noise, drift, and
% then get nice activation envelopes - numbers are set for 2000 Hz
% collection
[b2,a2]=butter(4,0.35,'low'); %Used to remove high-frequency noise above 350Hz
[bb2,aa2]=butter(4,0.001,'high'); %Used to remove low-frequency drift below 1Hz
[bbb2,aaa2]=butter(4,0.01,'low'); %Used to filter to 10Hz to get envelope
for ii=1:12  
     emgdatar2(:,ii)=emg2(ii).data; %Raw emg data - Here just pulling the matrix of data out of the structure I loaded
end
 EMfr2=filtfilt(bb2,aa2,emgdatar2); %Zero-shift filter removing drift first
 EMGr2=filtfilt(b2,a2,EMfr2); %Zero-shift filter removing high frequency noise
 EMGabs2=abs(EMGr2); %Rectify data
 emgdata2=filtfilt(bbb2,aaa2,EMGabs2); %Filter to envelopes of activation

%Computes the average emg cycle
clear emgc2;
emgtime2=emg2(1).time;
for j=1:6
        emgc2(j)=avgcycle(emgtime2,emgdata2(:,j),ax2(1).time(hsrp2),10,50);
        emgc2(6+j)=avgcycle(emgtime2,emgdata2(:,6+j),ax2(2).time(hslp2),10,50);
end

%Normalize the EMG data
clear emgrms2;
for j=1:12
    emgrms2(j)=rms(emgdata2(:,j));
    
    normemg2(:,j)=(emgc2(j).avg)./(emgrms2(j));
    normemgstd2(:,j)=(emgc2(j).sd)./(emgrms2(j));
end



% %%%% Load EMG Data from TP06 %%%%
% % Plots the acc magnitude curves
% % Finds the peaks of the filtered acc data
% 
% [bfa6,afa6]=butter(3,25/(ax6(1).freq/2));
% clear amag6 amagf6;
% for i=1:3
%     axf6=filtfilt(bfa6,afa6,ax6(i).data);
%     ayf6=filtfilt(bfa6,afa6,ay6(i).data);
%     azf6=filtfilt(bfa6,afa6,az6(i).data);
%     amag6(:,i)=(ax6(i).data.^2+ay6(i).data.^2+az6(i).data.^2).^0.5;
%     amagf6(:,i)=(axf6.^2+ayf6.^2+azf6.^2).^0.5;
% end
% 
% %Uses the magnitudes from filtered acc data and finds the peaks
% clear hsr6 hsl6 hsrp6 hslp6;
% [hsr6, hsrp6]=findpeaks(amagf6(:,1),'MinPeakHeight',2.,'MinPeakDistance',100);
% [hsl6, hslp6]=findpeaks(amagf6(:,2),'MinPeakHeight',2.,'MinPeakDistance',100);
% 
% %Filter the EMG data
% % Use 3 filters to remove non-EMG frequency range noise, drift, and
% % then get nice activation envelopes - numbers are set for 2000 Hz
% % collection
% [b6,a6]=butter(4,0.35,'low'); %Used to remove high-frequency noise above 350Hz
% [bb6,aa6]=butter(4,0.001,'high'); %Used to remove low-frequency drift below 1Hz
% [bbb6,aaa6]=butter(4,0.01,'low'); %Used to filter to 10Hz to get envelope
% for ii=1:12  
%      emgdatar6(:,ii)=emg6(ii).data; %Raw emg data - Here just pulling the matrix of data out of the structure I loaded
% end
%  EMfr6=filtfilt(bb6,aa6,emgdatar6); %Zero-shift filter removing drift first
%  EMGr6=filtfilt(b6,a6,EMfr6); %Zero-shift filter removing high frequency noise
%  EMGabs6=abs(EMGr6); %Rectify data
%  emgdata6=filtfilt(bbb6,aaa6,EMGabs6); %Filter to envelopes of activation
% 
% %Computes the average emg cycle
% clear emgc6;
% emgtime6=emg6(1).time;
% for j=1:6
%         emgc6(j)=avgcycle(emgtime6,emgdata6(:,j),ax6(1).time(hsrp6),10,50);
%         emgc6(6+j)=avgcycle(emgtime6,emgdata6(:,6+j),ax6(2).time(hslp6),10,50);
% end
% 
% %Normalize the EMG data
% clear emgrms6;
% for j=1:12
%     emgrms6(j)=rms(emgdata6(:,j));
%     
%     normemg6(:,j)=(emgc6(j).avg)./(emgrms6(j));
%     normemgstd6(:,j)=(emgc6(j).sd)./(emgrms6(j));
% end



% %%%% Load EMG Data from TP10 %%%%
% % Plots the acc magnitude curves
% % Finds the peaks of the filtered acc data
% 
% [bfa10,afa10]=butter(4,25/(ax10(1).freq/2));
% clear amag10 amagf10;
% for i=1:3
%     axf10=filtfilt(bfa10,afa10,ax10(i).data);
%     ayf10=filtfilt(bfa10,afa10,ay10(i).data);
%     azf10=filtfilt(bfa10,afa10,az10(i).data);
%     amag10(:,i)=(ax10(i).data.^2+ay10(i).data.^2+az10(i).data.^2).^0.5;
%     amagf10(:,i)=(axf10.^2+ayf10.^2+azf10.^2).^0.5;
% end
% 
% %Uses the magnitudes from filtered acc data and finds the peaks
% clear hsr10 hsl10 hsrp10 hslp10;
% [hsr10, hsrp10]=findpeaks(amagf10(:,1),'MinPeakHeight',2.,'MinPeakDistance',100);
% [hsl10, hslp10]=findpeaks(amagf10(:,2),'MinPeakHeight',2.,'MinPeakDistance',100);
% 
% %Filter the EMG data
% % Use 3 filters to remove non-EMG frequency range noise, drift, and
% % then get nice activation envelopes - numbers are set for 2000 Hz
% % collection
% [b10,a10]=butter(4,0.35,'low'); %Used to remove high-frequency noise above 350Hz
% [bb10,aa10]=butter(4,0.001,'high'); %Used to remove low-frequency drift below 1Hz
% [bbb10,aaa10]=butter(4,0.01,'low'); %Used to filter to 10Hz to get envelope
% for ii=1:12  
%      emgdatar10(:,ii)=emg10(ii).data; %Raw emg data - Here just pulling the matrix of data out of the structure I loaded
% end
%  EMfr10=filtfilt(bb10,aa10,emgdatar10); %Zero-shift filter removing drift first
%  EMGr10=filtfilt(b10,a10,EMfr10); %Zero-shift filter removing high frequency noise
%  EMGabs10=abs(EMGr10); %Rectify data
%  emgdata10=filtfilt(bbb10,aaa10,EMGabs10); %Filter to envelopes of activation
% 
% %Computes the average emg cycle
% clear emgc10;
% emgtime10=emg10(1).time;
% for j=1:6
%         emgc10(j)=avgcycle(emgtime10,emgdata10(:,j),ax10(1).time(hsrp10),10,50);
%         emgc10(6+j)=avgcycle(emgtime10,emgdata10(:,6+j),ax10(2).time(hslp10),10,50);
% end
% 
% %Normalize the EMG data
% clear emgrms10;
% for j=1:12
%     emgrms10(j)=rms(emgdata10(:,j));
%     
%     normemg10(:,j)=(emgc10(j).avg)./(emgrms10(j));
%     normemgstd10(:,j)=(emgc10(j).sd)./(emgrms10(j));
% end



%Plots the mean from every test point on the same graph
%Plots 2 figures, each with 6 muscles (mean +/- std)

% %Defines line colors
% c1 = rgb('Blue');
% c2 = rgb('Green');
% c6 = rgb('Red');
% c10 = rgb('Gold');
figure
for j=1:6
    subplot(6,1,j);
    hold on
    rightleg1=shadedErrorBar([0:100]',normemg(:,j),normemgstd(:,j),'b',1);
    %rightleg2=shadedErrorBar([0:100]',normemg2(:,j),normemgstd2(:,j),'r',1);
    %rightleg6=shadedErrorBar([0:100]',normemg6(:,j),normemgstd6(:,j),'g',1);
    %rightleg10=shadedErrorBar([0:100]',normemg10(:,j),normemgstd10(:,j),'k',1);
    plot([0:100]',normemg(:,j),'b');
    plot([0:100]',normemg2(:,j),'r');
%     plot([0:100]',normemg6(:,j),'g');
%     plot([0:100]',normemg10(:,j),'k');
%     plot([0:100]',normemg(:,j)+normemgstd(:,j),':b');
%     plot([0:100]',normemg(:,j)-normemgstd(:,j),':b');
%     plot([0:100]',normemg2(:,j)+normemgstd2(:,j),':r');
%     plot([0:100]',normemg2(:,j)-normemgstd2(:,j),':r');
%     plot([0:100]',normemg6(:,j)+normemgstd6(:,j),':g');
%     plot([0:100]',normemg6(:,j)-normemgstd6(:,j),':g');
%     plot([0:100]',normemg10(:,j)+normemgstd10(:,j),':k');
%     plot([0:100]',normemg10(:,j)-normemgstd10(:,j),':k');
    hold off
     title(emg(j).label);
     ylim([0,3]);
     %axis([0,100,0,inf]);
end

figure
for j=1:6
    subplot(6,1,j);
    hold on
    leftleg1=shadedErrorBar([0:100]',normemg(:,6+j),normemgstd(:,6+j),'b',1);
    %leftleg2=shadedErrorBar([0:100]',normemg2(:,6+j),normemgstd2(:,6+j),'r',1);
    %leftleg6=shadedErrorBar([0:100]',normemg6(:,6+j),normemgstd6(:,6+j),'g',1);
    %leftleg10=shadedErrorBar([0:100]',normemg10(:,6+j),normemgstd10(:,6+j),'k',1);
    plot([0:100]',normemg(:,6+j),'b');
    plot([0:100]',normemg2(:,6+j),'r');
%     plot([0:100]',normemg6(:,6+j),'g');
%     plot([0:100]',normemg10(:,6+j),'k');
%     plot([0:100]',normemg(:,6+j)+normemgstd(:,6+j),':b');
%     plot([0:100]',normemg(:,6+j)-normemgstd(:,6+j),':b');
%     plot([0:100]',normemg2(:,6+j)+normemgstd2(:,6+j),':r');
%     plot([0:100]',normemg2(:,6+j)-normemgstd2(:,6+j),':r');
%     plot([0:100]',normemg6(:,6+j)+normemgstd6(:,6+j),':g');
%     plot([0:100]',normemg6(:,6+j)-normemgstd6(:,6+j),':g');
%     plot([0:100]',normemg10(:,6+j)+normemgstd10(:,6+j),':k');
%     plot([0:100]',normemg10(:,6+j)-normemgstd10(:,6+j),':k');
    hold off
     title(emg(6+j).label);
     ylim([0,3]);
     %axis([0,100,0,inf]);
end       























%%%% Figures for the powerpoint %%%%

% figure
% plot(ax(1).time,[ax(1).data ay(1).data az(1).data]);
% title('Raw Accelerometer Data - Right Ankle')
% xlabel('Time (s)')

% figure
% plot(ax(1).time,amagf);
% title('Filtered and Magnified Accelerometer Data')
% xlabel('Time (s)')
% legend ('Right heel strike','Left heel strike')

% figure
% plot(ax(1).time,amagf,'-');
% hold on;
% plot(ax(1).time(hsrp),hsr, 'o');
% plot(ax(1).time(hslp),hsl,'x');
% hold off;
% title('Finding Heel Strikes')
% xlabel('Time (s)')
% legend ('0 = right','x = left')

% figure
% plot(emgc(2).cycles);
% title('Every EMG Cycle - R Gastrocnemius')
% xlabel('Percent of Gait Cycle (%)')

% figure
% hold on
% plot([0:100]',emgc(2).avg);
% plot([0:100]',emgc(2).avg+emgc(2).sd,':');
% plot([0:100]',emgc(2).avg-emgc(2).sd,':');
% hold off
% title('R Gastrocnemius');
% xlabel('Percent of Gait Cycle (%)')
% ylim([0,max(emgc(2).avg+emgc(2).sd)*1.25])