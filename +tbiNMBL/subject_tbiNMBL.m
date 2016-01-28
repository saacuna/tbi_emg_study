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
            prompt_defaultAnswer = find(strcmp(subj.status,statuses)==1); % find default answer
            if isempty(prompt_defaultAnswer); prompt_defaultAnswer = 1; end; % if setting for first time
            prompt_title = 'Specify TBI Subject Status:';
            prompt_title2 = 'Subject Status';
            prompt_answer = listdlg('PromptString',prompt_title,'SelectionMode','single','Name',prompt_title2,'ListString',statuses,'InitialValue',prompt_defaultAnswer,'ListSize',[150 75]);
            if isempty(prompt_answer); return; end; % user canceled. bail out.
            % update status
            subj.status = statuses{prompt_answer};
        end
        function setStimLvl(subj) % update PoNS stimulation type
            PoNSLevel = tbiNMBL.constants_tbiNMBL.stimLvl;
            prompt_defaultAnswer= find(strcmp(subj.stimLvl,PoNSLevel)==1);
            if isempty(prompt_defaultAnswer); prompt_defaultAnswer = 1; end; % if setting for first time
            prompt_title = 'Select PoNS stimulation type:';
            prompt_title2 = 'PoNS type';
            prompt_answer = listdlg('PromptString',prompt_title,'SelectionMode','single','Name',prompt_title2,'ListString',PoNSLevel,'InitialValue',prompt_defaultAnswer,'ListSize',[150 75]);
            if isempty(prompt_answer); return; end; % user canceled. bail out.
            % update stimulation level
            subj.stimLvl = PoNSLevel{prompt_answer};
        end
        function setSubjectID(subj) % update subject identifiers
            prompt = {'Subject ID:   (ex: "TBI-06")',...
                'Subject Initials:   (ex: "SA")'};
            prompt_defaultAnswer = {subj.ID,subj.initials};
            prompt_title = 'Subject Information';
            prompt_answer = inputdlg(prompt,prompt_title,[1 60],prompt_defaultAnswer);
            if isempty(prompt_answer); return; end; % user canceled. bail out.
            % update subject info
            subj.ID = prompt_answer{1};
            subj.initials = prompt_answer{2};
        end
        function addTestPoint(subj) % add emg data from a testpoint 
            subj.testPoints{subj.numTestPoints+1} = tbiNMBL.testPoint_tbiNMBL(); % creates a new instance of the testPoint class
            disp(['Test point ' num2str(subj.testPoints{end}.TP) ' has been added to ' subj.ID '.']);
            subj.listTestPoints();
        end
        function removeTestPoint(subj, testPointIndexNumber) % remove testpoint data
            if (subj.numTestPoints < testPointIndexNumber) % testpoint number must be valid
                disp(['Test Point Index #' num2str(testPointIndexNumber) ' is not in this database for subject' subj.ID '.']);
            else
                subj.testPoints(testPointIndexNumber) = []; % deletes that cell and resizes testpoint array
                disp(['Test Point Index #' num2str(testPointIndexNumber) ' removed from database. Database re-indexed.']);
                subj.listTestPoints();
            end
        end
        function listTestPoints(subj) % list off all testpoints for this subject
            if ~subj.numTestPoints % if no testpoint data stored yet
                disp('No testPoint data for this subject has been stored.');
            else % compile output display
                fprintf('\t%s%s%s\n','Test Points for Subject ',subj.ID,':'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','Index','TestPt','nTrials', 'PrefSpd', 'BaseSpd', 'Notes', 'Admin.','Date'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' ,'-------','-------','-------','-------','-------','-------','-------','-------'); 
                indexLength = subj.numTestPoints;
                for indexNumber = 1:indexLength % print out index number and walkingspeed_preferred, etc
                    vals = {indexNumber,...
                        subj.testPoints{indexNumber}.TP,...
                        subj.testPoints{indexNumber}.numTrials,...
                        subj.testPoints{indexNumber}.walkingSpeed_preferred,...
                        subj.testPoints{indexNumber}.walkingSpeed_baseline,...
                        subj.testPoints{indexNumber}.noteFlag,...
                        subj.testPoints{indexNumber}.dataCollectedBy,...
                        subj.testPoints{indexNumber}.dateCollected};
                    fprintf('\t%d\t%d\t%d\t%s\t%s\t%d\t%s\t%s\n',vals{:});
                end
            end
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

