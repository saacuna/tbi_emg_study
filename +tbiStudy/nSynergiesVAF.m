% Filename: nSynergiesVAF.m
% Author:   Samuel Acuña
% Date:    11 Sep 2018
% Description: How many synergies required to hit 90% Variance Accounted
% for (VAF)?


clear; close all; clc;

%% load baseline synergy data
%sqlquery = ['select * from trials where trialType = "baseline" and testPoint = 1 order by subject_id']
sqlquery = ['select * from trials where trialType = "overground" and testPoint = 1 order by subject_id']
%sqlquery = ['select * from trials_healthy where trialType = "treadmill22" order by subject_id']
%sqlquery = ['select * from trials_healthy where trialType = "treadmill28" order by subject_id']
%sqlquery = ['select * from trials_healthy where trialType = "treadmill34" order by subject_id']
%sqlquery = ['select * from trials_healthy where trialType = "overground" order by subject_id']
queryData = tbiStudy.load(sqlquery);

[rows, ~] = size(queryData);
syn_temp = [];
for i = 1:rows %iteratively load queried trials into structure
    dataFileLocation = queryData{i,4}; % load relative file location
    dataFileLocation = [tbiStudy.constants.dataFolder dataFileLocation]; % create absolute file location
    filename = queryData{i,9}; % load synergy data
    load([dataFileLocation filename]);
    syn_temp = [syn_temp; syn];
end
syn = syn_temp;
clearvars -except syn

%% find number of synergies for xx% VAF

thresholdVAF = 0.90;%0.90;
emg_type = 'concat_peak';
leg = {'left','right'};

nSyn = 6*ones(length(syn),length(leg)); % default is that no synergies account for VAF (n = 6 = # of muscles/leg)

for iSN = 1:length(syn) % cycle through subjects in query
    for iL = 1:length(leg) % cycle through legs
        VAF = [syn(iSN).(emg_type).(leg{iL}).VAF{:}]'; % find VAF for all synergies calculated
        n = find(VAF>=thresholdVAF,1);
        if isempty(n)
            continue
        else
         nSyn(iSN,iL) = n;
        end
    end
end