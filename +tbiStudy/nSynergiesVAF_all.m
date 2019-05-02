% nSynergiesVAF_all.m
% check all test points

clc; clear; close all;


%% load baseline synergy data
sqlquery = ['select * from trials where trialType = "baseline" order by subject_id']
%sqlquery = ['select * from trials where trialType = "preferred" order by subject_id']
%sqlquery = ['select * from trials where trialType = "overground" order by subject_id']
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
clearvars -except syn nSyn

%% find number of synergies for xx% VAF

thresholdVAF = 0.90;%0.90;
emg_type = 'concat_peak';
leg = {'left','right'};
testPointCol = [1 2 0 0 0 3 0 0 0 4];
nSyn = zeros(90,4); % initialize to zero
tvaf = cell(90,4); % initialize to zero
%nSyn = zeros(40,1); % initialize to zero
%tvaf = cell(40,1); % initialize to zero

for iSN = 1:length(syn) % cycle through subjects in query
    
    % right leg
    VAF = [syn(iSN).(emg_type).right.VAF{:}]'; % find VAF for all synergies calculated
    n = find(VAF>=thresholdVAF,1);
    if isempty(n)
        iSN
        error('no VAF');
    else
        col = testPointCol(syn(iSN).testPoint);
        %col = 1;
        nSyn(syn(iSN).subject_id,col) = n;
        tvaf(syn(iSN).subject_id,col) = {VAF};
    end
    
    % left leg
    VAF = [syn(iSN).(emg_type).left.VAF{:}]'; % find VAF for all synergies calculated
    n = find(VAF>=thresholdVAF,1);
    if isempty(n)
        iSN
        error('no VAF');
    else
        col = testPointCol(syn(iSN).testPoint);
        nSyn(syn(iSN).subject_id+45,col) = n;
        tvaf(syn(iSN).subject_id+45,col) = {VAF};
        %col = 1;
        %nSyn(syn(iSN).subject_id+20,col) = n;
        %tvaf(syn(iSN).subject_id+20,col) = {VAF};
    end
    
end

