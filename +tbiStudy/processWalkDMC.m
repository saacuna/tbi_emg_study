% Filename: processWalkDMC.m
% Author:   Samuel Acuña
% Date:     13 Jun 2018
% Description: find walkDMC metric from synergy data. Resave it into the
% synergy file. Make sure you are comparing the correct healthy data to the
<<<<<<< HEAD
% TBI data (e.g. overground compares to overground)
%
% real change
%
clear; close all; clc;
ngth(emg_type) % cycle through EMG data types
    for k = 1:length(leg) % cycle through leg selection
        for n = nSynergiesRange % cycle through number of synergies
            tVAF = [];
            for i = 1:length(syn1)
                tVAF = [tVAF;  syn1(i).(emg_type{j}).(leg{k}).VAF{n}];
            end
            tVAF_healthy.(emg_type{j}).(leg{k}).avg(n) = mean(tVAF); % average healthy total variance accounted for
            tVAF_healthy.(emg_type{j}).(leg{k}).std(n) = std(tVAF); % standard deviation healthy total variance accounted for
        end
    end
end
clear i j k n tVAF
disp('     done.');


%% STEP 3: find walkDMC for the healthy subjects. Only need to process this once for each trialtype_healthy, because it saves it to file.
% disp('Finding walkDMC for the healthy subjects...');
% for i = 1:length(syn1) % cycle through subjects in this trialType_healthy
||||||| merged common ancestors
% TBI data (e.g. overground compares to overground)
%
%
%
clear; close all; clc;
ngth(emg_type) % cycle through EMG data types
    for k = 1:length(leg) % cycle through leg selection
        for n = nSynergiesRange % cycle through number of synergies
            tVAF = [];
            for i = 1:length(syn1)
                tVAF = [tVAF;  syn1(i).(emg_type{j}).(leg{k}).VAF{n}];
            end
            tVAF_healthy.(emg_type{j}).(leg{k}).avg(n) = mean(tVAF); % average healthy total variance accounted for
            tVAF_healthy.(emg_type{j}).(leg{k}).std(n) = std(tVAF); % standard deviation healthy total variance accounted for
        end
    end
end
clear i j k n tVAF
disp('     done.');


%% STEP 3: find walkDMC for the healthy subjects. Only need to process this once for each trialtype_healthy, because it saves it to file.
% disp('Finding walkDMC for the healthy subjects...');
% for i = 1:length(syn1) % cycle through subjects in this trialType_healthy
=======
% TBI data (e.g. overground compares  subjects in this trialType_healthy
>>>>>>> test
%     for j = 1:length(emg_type) % cycle through EMG data types
%         for k = 1:length(leg) % cycle thSD?lkfnsd
f; s
df, 
;lsdmfl ksdl;
fj ;lsdjf 
;lsd
;lf j
;ksdj f;s
rough leg selection
%             for n = nSynergiesRange % cycle through number of synergies
%                 tVAF_healthy_avg = tVAF_healthy.(emg_type{j}).(leg{k}).avg(n); % average healthy total variance accounted for
%                 tVAF_healthy_std = tVAF_healthy.(emg_type{j}).(leg{k}).std(n); % standard deviation healthy total variance accounted for
%                 tVAF_subject = syn1(i).(emg_type{j}).(leg{k}).VAF{n}; % subject total variance accounted for
%                 walkDMC_subject = 100 + 10*((tVAF_healthy_avg - tVAF_subject)/(tVAF_healthy_std)); % walkDMC metric as defined by Shuman 2018 (this is difference than Steele 2015)
%                 syn1(i).(emg_type{j}).(leg{k}).walkDMC{n} = walkDMC_subject;
%             end
%         end
%     end
%     
%     % save synergies back into file
%     syn = syn1(i); % put back into 'syn' variable for saving
%     save([dataFileLocation{i} syn.filename],'syn');
%     disp(['Synergy data saved as: ' syn.filename]);
%     disp(['in folder: ' dataFileLocation{i}]);
%     clear syn;
% end
% syn_healthy = syn1; % reassign syn variable in preparation for TBI subject data
% dataFileLocation_healthy = dataFileLocation; 
% clear i j k n tVAF_healthy_avg tVAF_healthy_std tVAF_subject walkDMC_subject syn1
% disp('     done.');

 
%% STEP 4: load TBI subjects
sqlquery = ['select * from trials where trialType = "' trialType{tt} '" order by subject_id'];
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
    dfl_temp{i} = dataFileLocation;
end
syn1 = syn_temp; % use 'syn1' to store all the 'syn' variables
dataFileLocation = dfl_temp;
clear filename i querydata sqlquery syn_temp dfl_temp rows syn

 
%% STEP 5: find walkDMC for the TBI subjects
disp('Finding walkDMC for the TBI subjects...');
% for j = 1:length(emg_type) % cycle through EMG data types
%     for k = 1:length(leg) % cycle through leg selection
%         for n = nSynergiesRange % cycle through number of synergies
%             wDMC = [];
%             for i = 1:length(walkDMC.(emg_type{j}).(leg{k}).tVAF_healthy{n}) % cycle through subjects
%                 VAF_healthy_avg = walkDMC.(emg_type{j}).(leg{k}).tVAF_healthy_avg(n); % average healthy total variance accounted for 
%                 VAF_healthy_std = walkDMC.(emg_type{j}).(leg{k}).tVAF_healthy_std(n); % standard deviation healthy total variance accounted for
%                 VAF_subject = walkDMC.(emg_type{j}).(leg{k}).tVAF_healthy{n}(i); % subject total variance accounted for
%                 walkDMC_subject = 100 + 10*((VAF_healthy_avg - VAF_subject)/(VAF_healthy_std)); % walkDMC metric as defined by Shuman 2018 (this is difference than Steele 2015)
%                 wDMC = [wDMC;  walkDMC_subject];
%             end
%             walkDMC.(emg_type{j}).(leg{k}).walkDMC{n} = wDMC;
%         end
%     end
% end
% syn_healthy = syn; % reassign syn variable in preparation for TBI subject data
% dataFileLocation_healthy = dataFileLocation; 
% clear i j k n VAF_healthy_avg VAF_healthy_std VAF_subject walkDMC_subject wDMC syn

for i = 1:length(syn1) % cycle through subjects in this trialType
    for j = 1:length(emg_type) % cycle through EMG data types
        for k = 1:length(leg) % cycle through leg selection
            for n = nSynergiesRange % cycle through number of synergies
                tVAF_healthy_avg = tVAF_healthy.(emg_type{j}).(leg{k}).avg(n); % average healthy total variance accounted for
                tVAF_healthy_std = tVAF_healthy.(emg_type{j}).(leg{k}).std(n); % standard deviation healthy total variance accounted for
                tVAF_subject = syn1(i).(emg_type{j}).(leg{k}).VAF{n}; % subject total variance accounted for
                walkDMC_subject = 100 + 10*((tVAF_healthy_avg - tVAF_subject)/(tVAF_healthy_std)); % walkDMC metric as defined by Shuman 2018 (this is difference than Steele 2015)
                syn1(i).(emg_type{j}).(leg{k}).walkDMC{n} = walkDMC_subject;
            end
        end
    end
    
    % save synergies back into file
%     syn = syn1(i); % put back into 'syn' variable for saving
%     save([dataFileLocation{i} syn.filename],'syn');
%     disp(['Synergy data saved as: ' syn.filename]);
%     disp(['in folder: ' dataFileLocation{i}]);
%     clear syn;
end
syn_tbi = syn1; 
dataFileLocation_tbi = dataFileLocation; 
clear i j k n tVAF_healthy_avg tVAF_healthy_std tVAF_subject walkDMC_subject syn1 dataFileLocation
disp('     done.');
