function hy = compileEMGtrials()
% Filename: compileEMGtrials.m
% Author:   Samuel Acuna
% Date:     17 Dec 2016
% Description:
% This takes separate EMG trial files and compiles them into an average EMG trial
%
% Create a healthy EMG trial with:
%       tr = tbiStudy.processEMGtrial();
%

n = 20; % number of trials to combine
compileName = 'hyn_all_'; 

%%%%%%%%%%%%%%%%%%%%%%%%%
% setup combined trial structure
hy= struct(...
    'subject_id',[],...
    'testPoint',[],...
    'trialType',[],...
    'filename',[],...
    'emgData',{},...
    'emgStd',{},...
    'emgLabel',{},...
    'emgFreq',[]);

for i = 1:n
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % load EMG data txt file
    disp('Select .mat EMG trial file');
    [infile, inpath]=uigetfile('*.mat','Select EMG trial file',tbiStudy.constants.dataFolder);
    if infile == 0
        error('Canceled. No file selected');
    end
    disp(['Selected: ' infile ]);
    load([inpath infile])
    
    ch1(i,:) = tr.emgData(:,1)'; 
    ch2(i,:) = tr.emgData(:,2)'; 
    ch3(i,:) = tr.emgData(:,3)'; 
    ch4(i,:) = tr.emgData(:,4)'; 
    ch5(i,:) = tr.emgData(:,5)'; 
    ch6(i,:) = tr.emgData(:,6)'; 
    ch7(i,:) = tr.emgData(:,7)'; 
    ch8(i,:) = tr.emgData(:,8)'; 
    ch9(i,:) = tr.emgData(:,9)'; 
    ch10(i,:) = tr.emgData(:,10)'; 
    ch11(i,:) = tr.emgData(:,11)'; 
    ch12(i,:) = tr.emgData(:,12)'; 
end

hy(1).emgData = [mean(ch1)' mean(ch2)' mean(ch3)' mean(ch4)' mean(ch5)' mean(ch6)' mean(ch7)' mean(ch8)' mean(ch9)' mean(ch10)' mean(ch11)' mean(ch12)'];
hy(1).emgStd  = [std(ch1)' std(ch2)' std(ch3)' std(ch4)' std(ch5)' std(ch6)' std(ch7)' std(ch8)' std(ch9)' std(ch10)' std(ch11)' std(ch12)'];
hy(1).emgLabel = tr.emgLabel;
hy(1).emgFreq = tr.emgFreq;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% specify trial information
hy(1).subject_id= setSubjectID();
hy(1).testPoint = setTestPoint();
hy(1).trialType = setTrialType();



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save file 
hy(1).filename = [compileName sprintf('%02d',hy.subject_id) '_tp' sprintf('%02d',hy.testPoint) '_' hy.trialType];
%tr = hy(1);
save([hy(1).filename], 'hy');
disp(['Trial Data saved as: ' hy(1).filename]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot trial
tbiStudy.plot.single(hy);
end
function trialType = setTrialType()
selection = listdlg('Name','Trial Type','PromptString','Select Trial Type:','SelectionMode','single','ListString',tbiStudy.constants.trialType,'ListSize',[150 75]);
if isempty(selection); error('Must specify trial type'); end; % user canceled.
trialType = tbiStudy.constants.trialType{selection};
end
function testPoint = setTestPoint()
TPchoices = num2str(cell2mat(tbiStudy.constants.testPoint)');
selection = listdlg('Name','Test Point','PromptString','Select Test Point:','SelectionMode','single','ListString',TPchoices,'ListSize',[150 75]);
if isempty(selection); error('Must specify test point'); end; % user canceled.
testPoint = tbiStudy.constants.testPoint{selection};
end
function subject_id = setSubjectID()
ID = inputdlg('Subject ID Number:','Subject ID Number',[1 60],{'01'});
try
    ID = str2num(ID{1});
catch
    error('Must specify numeric subject ID');
end;
subject_id = ID;
end

