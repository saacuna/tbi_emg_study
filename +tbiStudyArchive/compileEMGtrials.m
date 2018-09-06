% Filename: compileEMGtrials.m
% Author:   Samuel Acuna
% Date:     17 May 2018
% Description:
% This takes separate healthy EMG trial files and compiles them into an average healthy EMG trial
%
% THIS CODE MAY BE OUT OF DATE AND NOT COMPATIBLE WITH CURRENT CODE AND
% DATA FORMATTING
%
clc; clear; close all;

n = 20; % number of healthy subjects
saveFolder = [tbiStudy.constants.healthyFolder 'HYN_all/'];

% trial types
trialTypes = {'treadmill22','treadmill28','treadmill34','overground'};


for i = 1:length(trialTypes) % cycle through each trial type

    % setup combined trial structure
    tr_all = struct(...
        'subject_type','hyn',...
        'subject_id',0,...
        'testPoint',0,...
        'trialType',trialTypes{i},...
        'filename',['hyn00_tp00_' trialTypes{i}],...
        'emgLabel',[],...
        'emgFreq',[],...
        'nStrides_left_avg',[],...
        'nStrides_left_std',[],...
        'nStrides_right_avg',[],...
        'nStrides_right_std',[],...
        'emgData',[],...
        'emgStd',[],...
        'emgStd2',[]);
    
    % load healthy subject files for this trial type
    tr_temp = [];
    for j = 1:n 
        dataFolder = [tbiStudy.constants.healthyFolder 'HYN' sprintf('%02d',j) '/'];
        dataFilename = ['hyn' sprintf('%02d',j) '_tp00_' trialTypes{i} '_EMG'];
        load([dataFolder dataFilename]);
        tr_temp = [tr_temp; tr];
    end
    tr = tr_temp;
    
    % get average data
    tr_all.emgLabel = tr(1).emgLabel;
    tr_all.emgFreq = tr(1).emgFreq;
    
    tr_all.nStrides_left_avg = mean([tr.nStrides_left]);
    tr_all.nStrides_left_std = std([tr.nStrides_left]);
    tr_all.nStrides_right_avg = mean([tr.nStrides_right]);
    tr_all.nStrides_right_std = std([tr.nStrides_right]);
    
    for j = 1:12
        for k = 1:n
            emg_data(:,k) = tr(k).emgData(:,j); % pull subject average EMG 
            emg_std2(:,k) = tr(k).emgStd(:,j); % pull subject std EMG
        end
        
        tr_all.emgData(:,j) = mean(emg_data,2); % average subject avg EMG data 
        tr_all.emgStd(:,j) = std(emg_data,0,2); % std subject avg EMG data 
        tr_all.emgStd2(:,j) = mean(emg_std2,2); % average subject std EMG data 
        
        
    end
    
    % plot EMG
    fig = figure();
    for j = 1:6
        subplot(6,2,2*j)
        shadedErrorBar([0:100]',tr_all.emgData(:,j),tr_all.emgStd(:,j));
        title(tr_all.emgLabel{j});
        ylim([0 1]);
        
        subplot(6,2,2*j-1)
        shadedErrorBar([0:100]',tr_all.emgData(:,6+j),tr_all.emgStd(:,6+j));
        title(tr_all.emgLabel{6+j});
        ylim([0 1]);
    end
    
    % save figure
    tightfig(fig);
    suptitle(['hyn ALL:  ' tr_all.trialType]);
    fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 25 30];
    filename = [tr_all.filename '_avg'];
    path_orig = pwd;
    cd(saveFolder);
    print(filename,'-dpng','-painters','-loose');
    disp(['Plot of average EMG gait cycles saved as: ' filename '.png']);
    
    % save file
    save(tr_all.filename,'tr_all');
    disp(['Average data saved as: ' tr_all.filename]);
    cd(path_orig);
end




