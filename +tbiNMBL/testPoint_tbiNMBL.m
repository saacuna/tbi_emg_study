classdef testPoint_tbiNMBL < handle
    % Filename: testPoint_tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     27 Jan 2016
    % Description:
    % This class houses the emg data for one testpoint allowing
    % for easy comparison  within different trials during that testpoint
    properties (GetAccess = 'public', SetAccess = 'private')
        TP; % which test point it is, i.e. 1, 2, 6, 10
        dateCollected; % when test point collection was done, e.g. 2015-12-25
        dataCollectedBy; % initials of who collected the testpoint data
        walkingSpeed_preferred; % e.g.  2.0 mph. for testPoint 1, this is the same as the baseline.
        walkingSpeed_baseline; % e.g.  1.6 mph
        notes; % optional. anything worth mentioning for this testpoint (e.g. hands on treadmill)
        trials; % stores emg collection data for every trial in the testpoint
    end
    properties (Dependent)
        numTrials; % how many trials have been stored in this test point
        noteFlag; % is there anything in the notes? 1 = yes. 0 = no.
    end
    methods (Access = public)
        function tp = testPoint_tbiNMBL() % constructor function
            tp.setTP();
            tp.dateCollected = '';
            tp.dataCollectedBy = '';
            tp.walkingSpeed_preferred = '';
            tp.walkingSpeed_baseline = '';
            tp.notes = '';
            tp.setTestPointMetaData();
            tp.trials = cell(0); % no data loaded into trials yet for this testpoint
        end
        function setTP(tp) % update test point identifier
            TPchoices = num2str(cell2mat(tbiNMBL.constants_tbiNMBL.TP)');
            prompt_defaultAnswer= find(strcmp(tp.TP,TPchoices)==1);
            if isempty(prompt_defaultAnswer); prompt_defaultAnswer = 1; end; % if setting for first time
            prompt_title = 'Select Test Point:';
            prompt_title2 = 'Test Point:';
            prompt_answer = listdlg('PromptString',prompt_title,'SelectionMode','single','Name',prompt_title2,'ListString',TPchoices,'InitialValue',prompt_defaultAnswer,'ListSize',[150 75]);
            if isempty(prompt_answer); return; end; % user canceled. bail out.
            tp.TP = tbiNMBL.constants_tbiNMBL.TP{prompt_answer}; % update TP
        end
        function setTestPointMetaData(tp) % update test point collection date
            prompt = {'Date Test Point Collected:   (yyyy-MM-dd)',...
                'Data Collected by:   (ex: "SA")',...
                'Preferred walking speed:   (ex: "2.1 mph")',...
                'Baseline walking speed:   (ex: "2.0 mph")',...
                'TestPoint Notes:   (ex: "hands on treadmill")'};
            prompt_defaultAnswer = {tp.dateCollected,tp.dataCollectedBy, tp.walkingSpeed_preferred, tp.walkingSpeed_baseline, tp.notes};
            prompt_title = 'Test Point metadata';
            prompt_answer = inputdlg(prompt,prompt_title,[1 60],prompt_defaultAnswer);
            if isempty(prompt_answer); return; end; % user canceled. bail out.
            % update testpoint metadata info
            tp.dateCollected = prompt_answer{1};
            tp.dataCollectedBy = prompt_answer{2};
            tp.walkingSpeed_preferred = prompt_answer{3};
            tp.walkingSpeed_baseline = prompt_answer{4};
            tp.notes = prompt_answer{5};
        end
        function readNotes(tp)
            if tp.noteFlag
                fprintf('\n%s%d%s\n','Notes for TestPoint ', tp.TP, ':');
                disp(tp.notes);
                fprintf('\n');
            else
                disp('No Notes to display. Use editNotes() to write something in.');
            end
        end
        function editNotes(tp) % update any additional notes for the testpoint
            prompt = {'TestPoint Notes:   (ex: "hands on treadmill")'};
            prompt_defaultAnswer = {tp.notes};
            prompt_title = 'TestPoint notes';
            prompt_answer = inputdlg(prompt,prompt_title,[5 50],prompt_defaultAnswer);
            if isempty(prompt_answer); return; end; % user canceled. bail out.
            % update additional notes
            tp.notes = prompt_answer{1};
        end
        function addTrial(tp) % add collection trial to test point
            tp.trials{tp.numTrials+1} = tbiNMBL.trial_tbiNMBL(); % creates a new instance of the trial class
            disp(['Trial ' num2str(tp.trials{end}.trialType) ' has been added to Test Point ' tp.TP '.']);
            tp.listTrials();
        end
        function removeTrial(tp, trialIndexNumber) % remove collection trial to test point
            if (tp.numTrials < trialIndexNumber) % trial number must be valid
                disp(['Trial Index #' num2str(trialIndexNumber) ' is not in this database for test point ' num2str(tp.TP) '.']);
            else
                tp.trials(trialIndexNumber) = []; % deletes that cell and resizes subject array
                disp(['Trial Index #' num2str(trialIndexNumber) ' removed from database. Database re-indexed.']);
                tp.listTrials();
            end
        end
        function listTrials(tp) % list collection trials to test point
            if ~tp.numTrials % if no trial data stored yet
                disp('No trial data for this testpoint has been stored.');
            else % compile output display
                fprintf('\t%s%s%s\n','Trial Data for testPoint ',tp.TP,':'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\n','Index','Trial Type','emgFreq','emgData','emgStd','emgLabl'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\n' ,'-------','--------------','-------','-------','-------','-------');
                indexLength = tp.numTrials;
                for indexNumber = 1:indexLength % print out index number and trial type, etc
                    vals = {indexNumber,...
                        tp.trials{indexNumber}.trialType,...
                        tp.trials{indexNumber}.emgFreq,...
                        tp.trials{indexNumber}.emgData,...
                        tp.trials{indexNumber}.emgStd,...
                        tp.trials{indexNumber}.emgLabel};
                    fprintf('\t%d\t%s\t%d\t%s\t%s\t%s\n',vals{:});
                end
            end
        end
    end
    methods % used for set and get methods
        function numTr = get.numTrials(tp) % calculate the number of test points stored
            numTr = length(tp.trials);
        end
        function set.numTrials(tp,~) % cant set dependent number of test points
            fprintf('%s%d\n','numTrials is: ',tp.numTrials)
            error('You cannot set the numTrials property');
        end
        function noteFl = get.noteFlag(tp) % set noteFlag if non-whitespace notes
            if isempty(tp.notes) 
                noteFl = 0;
            elseif isempty(strtrim(tp.notes))
                noteFl = 0;
            else
                noteFl = 1;
            end
        end
        function set.noteFlag(tp,~) % cant set note flag
            fprintf('%s%d\n','noteFlag is: ',tp.noteFlag)
            error('You cannot set the noteFlag property');
        end
    end
    
end

