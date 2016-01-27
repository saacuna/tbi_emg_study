classdef subject_tbiNMBL < handle
    % Filename: subject_tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     27 Jan 2016
    % Description:
    % This class houses the emg data for one subject allowing
    % for easy comparison  within testpoints and between testPoints
    
    properties (GetAccess = 'public', SetAccess = 'private')
        ID; % e.g. TBI-06
        initials; % e.g. SA
        status; % e.g. completed, withdrawn, current
        stimLvl; % PoNS stimulation type. e.g. active, control, unknown (wont know until end of study)
        testPoints; % emg collection data of all the testpoints
    end
    properties (Dependent)
        numTestPoints; % how many test points have been stored
    end
    
    methods (Access = public)
        function subj = subject_tbiNMBL() % constructor function
            subj.ID = '';
            subj.initials = '';
            subj.status = '';
            subj.stimLvl = '';
            subj.testPoints = cell(0); % no data loaded into test points yet
            subj.updateSubjectInfo(); % setup general subject information 
        end
        function updateSubjectInfo(subj) % update general subject information
            subj.setSubjectID(); % first, update subject identifier
            subj.setStatus(); % second, update the status of the subject
            subj.setStimLvl(); % third, update PoNS stimulation type
        end
        function setStatus(subj) % update the status of the subject
            statuses = tbiNMBL.constants_tbiNMBL.subjectStatus;
            prompt2_defaultAnswer = find(strcmp(subj.status,statuses)==1); % find default answer
            if isempty(prompt2_defaultAnswer); prompt2_defaultAnswer = 1; end; % if setting for first time
            prompt2_title = 'Specify TBI Subject Status:';
            prompt2_title2 = 'Subject Status';
            prompt2_answer = listdlg('PromptString',prompt2_title,'SelectionMode','single','Name',prompt2_title2,'ListString',statuses,'InitialValue',prompt2_defaultAnswer,'ListSize',[150 75]);
            if isempty(prompt2_answer); return; end; % user canceled. bail out.
            % update status
            subj.status = statuses{prompt2_answer};
        end
        function setStimLvl(subj) % update PoNS stimulation type
            PoNSLevel = tbiNMBL.constants_tbiNMBL.stimLvl;
            prompt3_defaultAnswer= find(strcmp(subj.stimLvl,PoNSLevel)==1);
            if isempty(prompt3_defaultAnswer); prompt3_defaultAnswer = 1; end; % if setting for first time
            prompt3_title = 'Select PoNS stimulation type:';
            prompt3_title2 = 'PoNS type';
            prompt3_answer = listdlg('PromptString',prompt3_title,'SelectionMode','single','Name',prompt3_title2,'ListString',PoNSLevel,'InitialValue',prompt3_defaultAnswer,'ListSize',[150 75]);
            if isempty(prompt3_answer); return; end; % user canceled. bail out.
            % update stimulation level
            subj.stimLvl = PoNSLevel{prompt3_answer};
        end
        function setSubjectID(subj) % update subject identifiers
            prompt1 = {'Subject ID:   (ex: "TBI-06")',...
                'Subject Initials:   (ex: "SA")'};
            prompt1_defaultAnswer = {subj.ID,subj.initials};
            prompt1_title = 'Subject Information';
            prompt1_answer = inputdlg(prompt1,prompt1_title,[1 60],prompt1_defaultAnswer);
            if isempty(prompt1_answer); return; end; % user canceled. bail out.
            % update subject info
            subj.ID = prompt1_answer{1};
            subj.initials = prompt1_answer{2};
        end
        function addTestPoint()
            
        end
    end
    methods % used for set and get methods
        function numTP = get.numTestPoints(subj) % calculate the number of test points stored
            numTP = length(subj.testPoints);
        end
        function set.numTestPoints(subj,~) % cant set dependent number of test points
            fprintf('%s%d\n','numTestPoints is: ',subj.numTestPoints)
            error('You cannot set the numTestPoints property');
        end
    end
    
end

