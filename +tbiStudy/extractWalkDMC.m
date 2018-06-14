% Filename: extractWalkDMC.m
% Author:   Samuel Acuña
% Date:     13 Jun 2018
% Description: extract the walkDMC metric for specific conditions, then can
% run stats or generate plots


clear; close all; clc;

n = 1; % number of synergies chosen
trialType_healthy = {'overground','treadmill22','treadmill28','treadmill34'}; % for healthy subjects
trialType = {'baseline', 'overground','preferred'}; % for TBI subjects

% choose which trial types to compare
tth = 2; % index for trialType_healthy
tt = 1; % index for trialType

%% STEP 1: load healthy walkDMC data
sqlquery = ['select * from trials_healthy where trialType = "' trialType_healthy{tth} '" order by subject_id'];
disp(['query: ' sqlquery]);
querydata = tbiStudy.load(sqlquery);

[rows, ~] = size(querydata);
syn_temp = [];
dfl_temp = cell(rows,1);
for i = 1:rows %iteratively load queried trials into structure
    dataFileLocation = querydata{i,4}; % load relative file location
    dataFileLocation = [tbiStudy.constants.dataFolder dataFileLocation]; % create absolute file location
    filename = querydata{i,9}; % load SYNERGY data
    load([dataFileLocation filename]); % loads a variable called 'syn'
    syn_temp = [syn_temp; syn];
end
syn = syn_temp;
clear filename i querydata sqlquery syn_temp dfl_temp rows dataFileLocation

%% STEP 2: extract healthy walkDMC values
emg_type = {'avg_peak','avg_unitVar','concat_peak','concat_unitVar'};
leg = {'right','left','both'};

disp('Extracting walkDMC for the healthy subjects...');
for j = 1:length(emg_type) % cycle through EMG data types
    for k = 1:length(leg) % cycle through leg selection
        wDMC = [];
        for i = 1:length(syn)
            wDMC = [wDMC;  syn(i).(emg_type{j}).(leg{k}).walkDMC{n}]; % individual walkDMC scores
        end
        walkDMC.(emg_type{j}).(leg{k}).walkDMC_healthy = wDMC; % group walkDMC scores
    end
end
syn_healthy = syn;
clear wDMC i j k syn
disp('     done.');

%% STEP 3: load TBI walkDMC data
if tt == 3 % since 'preferred' uses (baseline at tp01) as preferred tp01
    sqlquery = ['select * from trials where trialType = "preferred" or (trialType = "baseline" and testPoint = 1) order by subject_id'];
else
    sqlquery = ['select * from trials where trialType = "' trialType{tt} '" order by subject_id'];
end

disp(['query: ' sqlquery]);
querydata = tbiStudy.load(sqlquery);

[rows, ~] = size(querydata);
syn_temp = [];
dfl_temp = cell(rows,1);
for i = 1:rows %iteratively load queried trials into structure
    dataFileLocation = querydata{i,4}; % load relative file location
    dataFileLocation = [tbiStudy.constants.dataFolder dataFileLocation]; % create absolute file location
    filename = querydata{i,9}; % load SYNERGY data
    load([dataFileLocation filename]); % loads a variable called 'syn'
    syn_temp = [syn_temp; syn];
end
syn = syn_temp; % use 'syn1' to store all the 'syn' variables
clear filename i querydata sqlquery syn_temp dfl_temp rows dataFileLocation

%% STEP 4: extract walkDMC for the TBI subjects
disp('Extracting walkDMC for the TBI subjects...');

% setup NaN matrix, to account for missing test points
nTestPoints = 4;
nSubjects = 45; % technically 44 subjects, but easier to match with subject_id
for j = 1:length(emg_type) % cycle through EMG data types
    for k = 1:length(leg) % cycle through leg selection
        walkDMC.(emg_type{j}).(leg{k}).walkDMC = NaN([nSubjects, nTestPoints]);
    end
end

% extract walkDMC and place in matrix [subject_id x nTestPoints] = [45 x 4]
for j = 1:length(emg_type) % cycle through EMG data types
    for k = 1:length(leg) % cycle through leg selection
        for i = 1:length(syn) % cycle through each trial
            wDMC = syn(i).(emg_type{j}).(leg{k}).walkDMC{n}; % individual walkDMC score
            subject_id = syn(i).subject_id;
            switch syn(i).testPoint
                case 1
                    testPoint = 1; % first column is testPoint 1
                case 2
                    testPoint = 2; % second column is testPoint 2
                case 6
                    testPoint = 3; % third column is testPoint 6
                case 10
                    testPoint = 4; % fourth column is testPoint 10
            end
            walkDMC.(emg_type{j}).(leg{k}).walkDMC(subject_id,testPoint) = wDMC; % insert into walkDMC matrix
        end
    end
end

% Average Right and Left Leg walkDMC scores
for j = 1:length(emg_type) % cycle through EMG data types
   
    wDMC_RIGHT_healthy = walkDMC.(emg_type{j}).right.walkDMC_healthy; % pull healthy walkDMC
    wDMC_LEFT_healthy = walkDMC.(emg_type{j}).left.walkDMC_healthy;
    wDMC_RIGHT = walkDMC.(emg_type{j}).right.walkDMC; % pull TBI walkDMC
    wDMC_LEFT = walkDMC.(emg_type{j}).left.walkDMC;
    
    walkDMC.(emg_type{j}).averageLeg.walkDMC_healthy = (wDMC_LEFT_healthy + wDMC_RIGHT_healthy)/2; % average walkDMC between legs
    walkDMC.(emg_type{j}).averageLeg.walkDMC = (wDMC_LEFT + wDMC_RIGHT)/2; 
end
clear i j k wDMC subject_id testPoint wDMC_RIGHT_healthy wDMC_LEFT_healthy wDMC_RIGHT wDMC_LEFT
disp('     done.');


%% STEP 5: save the variable 'walkDMC' to be used for further analysis (stats, plots, etc.)
% add some more info to the walkDMC structure
walkDMC.trialType = trialType{tt};
walkDMC.trialType_healthy = trialType_healthy{tth};