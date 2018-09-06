% Filename: plotWalkDMC.m
% Author:   Samuel Acuña
% Date:     14 Jun 2018
% Description: plots the walkDMC metric

clear; close all; clc;

% choose which trial types to plot
tt = 2; % index for trialType
trialType = {'baseline', 'overground','preferred'};

emg_type = {'avg_peak','avg_unitVar','concat_peak','concat_unitVar'};
leg = {'right','left','both','averageLeg'};

%% load walkDMC data
datafolder = [tbiStudy.constants.dataFolder 'walkDMC/'];
plotfolder = [datafolder 'plots/'];
load([datafolder 'walkDMC_' trialType{tt} '.mat']); % creates variable called 'walkDMC'

% distinguish cohorts
sqlquery = ['select subject_id, stimulation_level, age_at_consent, time_since_last_TBI from tbi_subjects order by subject_id'];
disp(['query: ' sqlquery]);
querydata = tbiStudy.load(sqlquery);

for TP = 1:length(querydata) % put subject info into structure
    subject_info(querydata{TP,1}).subject_id = querydata{TP,1};
    subject_info(querydata{TP,1}).stimulation_level = querydata{TP,2};
    subject_info(querydata{TP,1}).age_at_consent = str2num(querydata{TP,3});
    subject_info(querydata{TP,1}).time_since_last_TBI = str2num(querydata{TP,4});
    switch querydata{TP,2} % code stimulation_level into cohort
        case 'Active'
            subject_info(querydata{TP,1}).cohort = 1;
        case 'Control'
            subject_info(querydata{TP,1}).cohort = 2;
    end
end
clear sqlquery querydata

% account for missing subject 2
subject_info(2).subject_id          = NaN;
subject_info(2).stimulation_level   = NaN;
subject_info(2).age_at_consent      = NaN;
subject_info(2).time_since_last_TBI = NaN;
subject_info(2).cohort              = NaN;

% index of cohorts
iActive = find([subject_info.cohort] == 1);
iControl = find([subject_info.cohort] == 2);

iAge1 = find([subject_info.age_at_consent] < 50);
iAge2 = find([subject_info.age_at_consent] >= 50 & [subject_info.age_at_consent] <= 60);
iAge3 = find([subject_info.age_at_consent] > 60);

iTime1 = find([subject_info.time_since_last_TBI] < 5);
iTime2 = find([subject_info.time_since_last_TBI] >= 5 & [subject_info.time_since_last_TBI] <= 10);
iTime3 = find([subject_info.time_since_last_TBI] > 10);

indices = {{iActive, iControl},{iAge1, iAge2, iAge3},{iTime1, iTime2, iTime3}};
indices_label = {{'iActive', 'iControl'},{'iAge1', 'iAge2', 'iAge3'},{'iTime1', 'iTime2', 'iTime3'}};
indices_group_label = {'StimulationLevel','AgeAtConsent','TimeSinceLastTBI'};
return
%% compare histograms walkDMC ALL Subjects
% xLimits = [60, 130];
% yLimits = [0 12];
% 
% for k = 1:4
%     fig = figure();
%     for j = 1:4
%         wdmc = walkDMC.(emg_type{j}).(leg{k}).walkDMC;
%         for TP = 1:4
%             subplot(4,4,TP*4-4+j);
%             histogram(wdmc(:,TP),'BinWidth',3,'facealpha',.5,'edgecolor','none');
%             title([emg_type{j} ': TP ' num2str(TP) ],'Interpreter','none');
%             xlim(xLimits); ylim(yLimits);
%         end
%     end
%     legend('All TBI subjects','Location','southoutside');
%     suptitle(['walkDMC  TBI ' walkDMC.trialType ': ' leg{k}]);
%     
%     % save fig
%     fig = gcf; %tightfig(gcf);
%     fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 30 15];
%     filename = [walkDMC.trialType '_walkDMC_ALL_' leg{k}];
%     path_orig = pwd;
%     cd(plotfolder);
%     print(filename,'-dpng','-painters','-loose');
%     cd(path_orig);
%     disp(['Plot of walkDMC saved as: ' filename '.png']);
%     close(fig);
%     
% end


%% compare histograms walkDMC by cohort
% xLimits = [60, 130];
% yLimits = [0 10];
% 
% 
% 
% for c = 1:length(indices) % cycle through cohorts
%     ind = indices{c};
%     for k = 1:4 % cycle through legs
%         fig = figure();
%         for j = 1:4 % cycle through emg types
%             wdmc = walkDMC.(emg_type{j}).(leg{k}).walkDMC; % extract walkDMC of interest
%             for TP = 1:4
%                 subplot(4,4,TP*4-4+j);
%                 hold on;
%                 for i = 1:length(ind)
%                     histogram(wdmc(ind{i},TP),'BinWidth',3,'facealpha',.5,'edgecolor','none'); % plot histogram
%                 end
%                 hold off;
%                 title([emg_type{j} ': TP ' num2str(TP) ],'Interpreter','none');
%                 xlim(xLimits); ylim(yLimits);
%             end
%         end
%         legend(indices_label{c},'Location','southoutside','Orientation','horizontal');
%         suptitle(['walkDMC  TBI ' indices_group_label{c} '  ' walkDMC.trialType ': ' leg{k}]);
%         
%         % save fig
%         fig = gcf; %tightfig(gcf);
%         fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 30 15];
%         filename = [walkDMC.trialType '_walkDMC_' indices_group_label{c} '_' leg{k}];
%         path_orig = pwd;
%         cd(plotfolder);
%         print(filename,'-dpng','-painters','-loose');
%         cd(path_orig);
%         disp(['Plot of walkDMC saved as: ' filename '.png']);
%         close(fig);
%     end
% end


%% plot walkDMC over time
close all

% specifiy data to use
for j = 3%1:4 %cycle through EMG type
    for k = 4%3:4 %cycle through leg type
        wdmcH = walkDMC.(emg_type{j}).(leg{k}).walkDMC_healthy;
        wdmc = walkDMC.(emg_type{j}).(leg{k}).walkDMC;
        
        % set up figure
        fig = figure();
        fig.Color = [1 1 1]; % set background color to white
        barColor = rgb('Gray');
        
        % plot spread
        data = {wdmcH,wdmc(:,1),wdmc(:,2),wdmc(:,3),wdmc(:,4)};
        wdmc_grouping = [ones(20,1); 2*ones(45,1);3*ones(45,1);4*ones(45,1);5*ones(45,1)];
        catIdx = wdmc_grouping;
        xNames = {'Healthy Controls','Pre-Intervention','After In-Clinic Training','After At-Home Training','After Washout Period'};
        yLabelName = 'walk-DMC';
        h = plotSpread(data,'categoryIdx',catIdx,'categoryMarkers',{'o','s','s','s','s'},'categoryColors',{'r','b','b','b','b'},'spreadWidth',2,'xNames',xNames,'yLabel',yLabelName);%,'xyOri','flipped')
        
        % box plot
        wdmc_vec = [wdmcH; reshape(wdmc,[45*4,1])]; % arrange as one vector
        hold on; % remember, the middle line on the box plot is the median!
        h_bp = boxplot(wdmc_vec,wdmc_grouping,'Labels',xNames);
        hold off
        
        % plot connecting lines
        h2 = get(h{1}(2,2)); %TP01 handle
        h3 = get(h{1}(3,3)); %TP02
        h4 = get(h{1}(4,4)); %TP06
        h5 = get(h{1}(5,5)); %TP10
        linesXData = NaN(45,4); linesYData = NaN(45,4); % create empty matrices
        index2 = find(~isnan(data{2})); % find where original data was
        index3 = find(~isnan(data{3}));
        index4 = find(~isnan(data{4}));
        index5 = find(~isnan(data{5}));
        linesXData(index2,1) = h2.XData; linesYData(index2,1) = h2.YData; % pull plot position of that data point
        linesXData(index3,2) = h3.XData; linesYData(index3,2) = h3.YData;
        linesXData(index4,3) = h4.XData; linesYData(index4,3) = h4.YData;
        linesXData(index5,4) = h5.XData; linesYData(index5,4) = h5.YData;
        for i = 1:45 % account for missing datapoints, still plot, just skill over them.
            % strategy: move the rightmost values left to cover up the NaNs
            if isnan(linesXData(i,3)) && ~isnan(linesXData(i,4))
                linesXData(i,3) = linesXData(i,4);
                linesYData(i,3) = linesYData(i,4);
                linesXData(i,4) = NaN; linesYData(i,4) = NaN;
            end
            if isnan(linesXData(i,2)) && ~isnan(linesXData(i,3))
                linesXData(i,2) = linesXData(i,3);
                linesYData(i,2) = linesYData(i,3);
                linesXData(i,3) = NaN; linesYData(i,3) = NaN;
            end
            if isnan(linesXData(i,1)) && ~isnan(linesXData(i,2))
                linesXData(i,1) = linesXData(i,2);
                linesYData(i,1) = linesYData(i,2);
                linesXData(i,2) = NaN; linesYData(i,2) = NaN;
            end
        end
        hold on;
        h_cl = plot(linesXData', linesYData','k'); % plot connecting lines
        hold off;
        title([(emg_type{j}) '  ' (leg{k})],'Interpreter','none');
        
%         % save fig
%         fig = gcf; %tightfig(gcf);
%         fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 30 15];
%         filename = [walkDMC.trialType '_overTime_walkDMC_ALL_' (emg_type{j}) '_' leg{k}];
%         path_orig = pwd;
%         cd(plotfolder);
%         print(filename,'-dpng','-painters','-loose');
%         % print(filename,'-depsc','-painters','-loose'); % use this to export to illustrator, since it is in vector format
%         cd(path_orig);
%         disp(['Plot of walkDMC saved as: ' filename '.png']);
%         close(fig);
    end
end

%% plot walkDMC over time, by cohort
close all

% specifiy data to use
j = 3 %cycle through EMG type
k = 4 %cycle through leg type
        wdmcH = walkDMC.(emg_type{j}).(leg{k}).walkDMC_healthy;
        wdmc = walkDMC.(emg_type{j}).(leg{k}).walkDMC;
        
        % set up figure
        fig = figure();
        fig.Color = [1 1 1]; % set background color to white
        barColor = rgb('Gray');
        
        % plot spread
        
        data = {wdmcH,wdmc(:,1),wdmc(:,2),wdmc(:,3),wdmc(:,4)};
        wdmc_grouping = [ones(20,1); 2*ones(45,1);3*ones(45,1);4*ones(45,1);5*ones(45,1)];
        catIdx = wdmc_grouping;
        xNames = {'Healthy Controls','Pre-Intervention','After In-Clinic Training','After At-Home Training','After Washout Period'};
        yLabelName = 'walk-DMC';
        h = plotSpread(data,'categoryIdx',catIdx,'categoryMarkers',{'o','s','s','s','s'},'categoryColors',{'r','b','b','b','b'},'spreadWidth',2,'xNames',xNames,'yLabel',yLabelName);%,'xyOri','flipped')
        
        hold on;
        wdmc_grouping2 = [subject_info.cohort]';
        catIdx = [ones(20,1); 1+wdmc_grouping2;1+wdmc_grouping2;1+wdmc_grouping2;1+wdmc_grouping2];
        xNames = {'Healthy Controls','Pre-Intervention','After In-Clinic Training','After At-Home Training','After Washout Period'};
        yLabelName = 'walk-DMC';
        h_unused = plotSpread(data,'categoryIdx',catIdx,'categoryMarkers',{'o','s','s'},'categoryColors',{'r','b','g'},'spreadWidth',2,'xNames',xNames,'yLabel',yLabelName);%,'xyOri','flipped')
        hold off
        
        % box plot
        wdmc_vec = [wdmcH; reshape(wdmc,[45*4,1])]; % arrange as one vector
        hold on; % remember, the middle line on the box plot is the median!
        h_bp = boxplot(wdmc_vec,wdmc_grouping,'Labels',xNames);
        hold off
        
        % plot connecting lines
        h2 = get(h{1}(2,2)); %TP01 handle
        h3 = get(h{1}(3,3)); %TP02
        h4 = get(h{1}(4,4)); %TP06
        h5 = get(h{1}(5,5)); %TP10
        linesXData = NaN(45,4); linesYData = NaN(45,4); % create empty matrices
        index2 = find(~isnan(data{2})); % find where original data was
        index3 = find(~isnan(data{3}));
        index4 = find(~isnan(data{4}));
        index5 = find(~isnan(data{5}));
        linesXData(index2,1) = h2.XData; linesYData(index2,1) = h2.YData; % pull plot position of that data point
        linesXData(index3,2) = h3.XData; linesYData(index3,2) = h3.YData;
        linesXData(index4,3) = h4.XData; linesYData(index4,3) = h4.YData;
        linesXData(index5,4) = h5.XData; linesYData(index5,4) = h5.YData;
        for i = 1:45 % account for missing datapoints, still plot, just skill over them.
            % strategy: move the rightmost values left to cover up the NaNs
            if isnan(linesXData(i,3)) && ~isnan(linesXData(i,4))
                linesXData(i,3) = linesXData(i,4);
                linesYData(i,3) = linesYData(i,4);
                linesXData(i,4) = NaN; linesYData(i,4) = NaN;
            end
            if isnan(linesXData(i,2)) && ~isnan(linesXData(i,3))
                linesXData(i,2) = linesXData(i,3);
                linesYData(i,2) = linesYData(i,3);
                linesXData(i,3) = NaN; linesYData(i,3) = NaN;
            end
            if isnan(linesXData(i,1)) && ~isnan(linesXData(i,2))
                linesXData(i,1) = linesXData(i,2);
                linesYData(i,1) = linesYData(i,2);
                linesXData(i,2) = NaN; linesYData(i,2) = NaN;
            end
        end
        hold on;
        h_cl = plot(linesXData', linesYData','k'); % plot connecting lines
        hold off;
        title([(emg_type{j}) '  ' (leg{k})],'Interpreter','none');
        
        
        % save fig
%         fig = gcf; %tightfig(gcf);
%         fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 30 15];
%         filename = [walkDMC.trialType '_overTime_walkDMC_ALL_' (emg_type{j}) '_' leg{k}];
%         path_orig = pwd;
%         cd(plotfolder);
%         print(filename,'-dpng','-painters','-loose');
%         % print(filename,'-depsc','-painters','-loose'); % use this to export to illustrator, since it is in vector format
%         cd(path_orig);
%         disp(['Plot of walkDMC saved as: ' filename '.png']);
%         close(fig);
