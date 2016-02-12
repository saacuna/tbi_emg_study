classdef testPoint_tbiNMBL < handle
    % Filename: testPoint_tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     27 Jan 2016
    % Description:
    % This class houses the emg data for one testpoint allowing
    % for easy comparison  within different trials during that testpoint
    %
    % Example usage:
    %   tp = tbiNMBL.testPoint_tbiNMBL() % create a testpoint to store trials of emg data
    %   tp.setTestPointMetaData() % update test point metadata
    %   tp.addTrial() % creates instance of the trial class in the database
    %   tp.readNotes() % read notes associated with the testpoint
    %   tp.editNotes() % edit notes associated with the testpoint
    %   tp.addTrial() % add second trial
    %   tp.listTrials() % display list of all trials in the testpoint database
    %   tp.plotTrial(2); % plots trial 2 only
    %   tp.plotTestPoint([1 2]) % plot first and second trial only
    %   tp.plotTestPoint() % plots all trials in testpoint
    %   tp.removeTrial(2) % remove the second trial from the testpoint database
    
    properties (GetAccess = 'public', SetAccess = 'public')%SetAccess = 'private')
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
        function setTestPointMetaData(tp) % update test point metadata
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
            disp(['Trial ' num2str(tp.trials{end}.trialType) ' has been added to Test Point ' num2str(tp.TP) '.']);
            tp.listTrials();
        end
        function removeTrial(tp, trialIndexNumber) % remove collection trial to test point
            if tp.checkValidTrialIndex(trialIndexNumber); % selected trial number must be in database
                tp.trials(trialIndexNumber) = []; % deletes that cell and resizes subject array
                disp(['Trial Index #' num2str(trialIndexNumber) ' removed from database. Database re-indexed.']);
                tp.listTrials();
            end
        end
        function listTrials(tp) % list collection trials to test point
            if ~tp.numTrials % if no trial data stored yet
                fprintf('\n\t\t%s\n','No trial data for this testpoint has been stored.');
            else % compile output display
                % fprintf('\n\t%s%s%s\n\n','Trial Data for testPoint ',num2str(tp.TP),':'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\n','Index','Trial Type','emgFreq','emgData','emgStd','emgLabl'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\n' ,'-------','--------------','-------','-------','-------','-------');
                indexLength = tp.numTrials;
                for indexNumber = 1:indexLength % print out index number and trial type, etc
                    vals = {indexNumber,...
                        tp.trials{indexNumber}.trialType,...
                        tp.trials{indexNumber}.emgFreq,...
                        tp.trials{indexNumber}.emgDataSize,...
                        tp.trials{indexNumber}.emgStdSize,...
                        tp.trials{indexNumber}.emgLabelSize};
                    fprintf('\t%d\t%s\t%d\t%s\t%s\t%s\n',vals{:});
                end
            end
        end
        function plotTrial(tp,trialIndex,checkEmgLabels)
            % plots the trials specified by trialIndexNumber
            % Plots right and left leg muscles, 6 muscles (mean +/- std)
            % e.g. tp1.plotTestPoint(2,1) % plot trial2, visually output all labels
            % to manually verify the emg labels are consistent
            % input:
            % trialIndexNumber = trial of interest e.g. 2
            % optional input:
            % checkEmgLabels = 0 (default) or 1, whether to print out the emg labels
            if nargin == 1
                disp('No trialIndex number specified, so this wont plot anything.');
                return
            elseif nargin == 2 % if not specified, dont view labels
                checkEmgLabels = 0;
            end
            if length(trialIndex) > 1; error('can only plot one trial with this method. Suggest using testPoint_tniNMBL.plotTestPoint() instead'); end;
            if ~tp.checkValidTrialIndex(trialIndex); return; end; % selected trial number must be in database

            % plot the trial
            figure('Name',['Trial ' num2str(trialIndex) ' EMG']);
            tp.trials{trialIndex}.plotTrialEmg(1);
            suptitle(['Trial ' num2str(trialIndex) ' EMG']);
            
            % optionally diplay trial emg labels
            tp.displayEmgTrials(checkEmgLabels, trialIndex);
        end
        function plotTestPoint(tp,trialIndex, checkEmgLabels)
            % this function plots the emg gait cycle data for array of
            % trials in test point.
            % Plots right and left leg muscles, 6 muscles (mean +/- std)
            % e.g. tp1.plotTestPoint() % plots all available trials
            % e.g. tp1.plotTestPoint([1 3]) % plots selected trials
            % e.g. tp1.plotTestPoint([1 3],1) % visually output all labels
            % to manually verify the emg labels are consistent
            % optional inputs:
            % trialIndexNumbers = array of the trials of interest, e.g. [1 3]
            % checkEmgLabels = 0 (default) or 1, whether to print out the emg labels
            if nargin == 1 % if no trials specified, plot them all, dont view labels
                trialIndex = 1:tp.numTrials;
                checkEmgLabels = 0;
            elseif nargin == 2 % if checkEmgLabels not specified, dont view labels
                checkEmgLabels = 0;
            end
            if ~tp.checkValidTrialIndex(trialIndex); return; end; % selected trial number must be in database
            
            % plot the trials for the testpoint
            figure('Name',['Test Point ' num2str(tp.TP) ' trials']);
            tp.plotTestPointEmg(trialIndex,checkEmgLabels) % wrapper to plots

            %create super title
            suptitle(['Test Point ' num2str(tp.TP) ' : Trials ' num2str(trialIndex)]);
            
            % create legend
            tp.plotTestPointLegend(trialIndex);
        end
        function s = corrTestPoint(tp) % correlation coefficient between all trials in a testpoint
            if (tp.numTrials == 0); disp('Need at least one trial in this testPoint.'); return; end;            
            % look at each muscle across testpoint and find correlation

            s = cell(12,2); %  12 muscles x (data, name)
            for muscle = 1:12
                for i = 1:tp.numTrials
                    M(:,i) = tp.trials{i}.emgData(:,muscle); % assemble observation matrix for correlation
                end
                s{muscle,1} = corrcoef(M(:,:)); % correlation of a muscle to itself across trials within a testpoint
                s{muscle,2} = tp.trials{1}.emgLabel{muscle}; % muscle name
            end
        end
        function fixSensor1Data(tp,trialIndex) % rearrange emg data for consistent order;
            % for some of the trials, sensor 1 was used in place of sensor
            % 8. This function rearranges the data from sensor 1 into the
            % slot for sensor 8 data. It just makes everything consistent.
            % Check out the order of the trials with displayEmgTrials method.
            %
            % inputs:
            % none =  this rearranges the data for ALL TRIALS in the given
            %         testPoint. If you add another trial in later, and need to fix just that one, DONT use this
            %         version of the method
            % trialIndex = rearranges the data for only the specificed
            %          trials in the given testpoint 
            %          e.g. trialIndex = [2 3]
            if nargin == 1 % if no trials specified, rearrange them all
                trialIndex = 1:tp.numTrials;
            end
            if ~tp.checkValidTrialIndex(trialIndex); return; end; % selected trial number must be in database
            
            disp(['Fixing sensor 1 data for Test Point' num2str(tp.TP) '.']);
            for i = trialIndex
                disp(['Trial Index #' num2str(i)]);
                tp.trials{i}.fixSensor1Data;
            end
            
            
            
        end
    end
    methods (Access = {?tbiNMBL.subject_tbiNMBL})
        function plotTestPointEmg(tp,trialIndex, checkEmgLabels)
            % this function is wrapped into. plots the emg gait cycle data for array of
            % trials in test point. see plotTestPoint for implementation
            % comments
            
            % actual plotting: 
            for i = trialIndex
                tp.trials{i}.plotTrialEmg(i); % plots
                tp.displayEmgTrials(checkEmgLabels, i); % optionally diplay trial emg labels
            end
        end
        function plotTestPointLegend(tp,trialIndex)
            % create workaround custom legend, not the cleanest, but easier than
            % moving around handles from different classes
            hold on
            for i = trialIndex
                handle(i) = plot(NaN,NaN,'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{i});
            end
            hold off
            trial_strings = strcat('Trial ',strread(num2str(trialIndex),'%s'));
            set(handle(:),'linewidth',5);
            h = legend(handle(:),trial_strings);
            set(h,'Position',tbiNMBL.constants_tbiNMBL.legendPosition);
            set(h,'Box','on','Orientation','horizontal','FontSize',12);
        end
        function valid = checkValidTrialIndex(tp,trialIndex) % selected trial number must be in database
            if (tp.numTrials < max(trialIndex)) 
                disp(['trialIndex is invalid. There are only ' num2str(tp.numTrials) ' trials in testpoint ' num2str(tp.TP) '.']);
                valid = 0;
            elseif isempty(trialIndex)
                disp(['There are no trials in testpoint ' num2str(tp.TP) '.']);
                valid = 0;
            elseif trialIndex == 0
                disp(['There are no trials in testpoint ' num2str(tp.TP) '.']);
                valid = 0;
            else
                valid = 1;
            end
        end
        function displayEmgTrials(tp,checkEmgLabels, trialIndex) % display trial emg labels
            if checkEmgLabels == 1
                disp(['Trial ' num2str(trialIndex) ' EMG Muscle Labels:'])
                tp.trials{trialIndex}.checkEmgLabels()
            elseif checkEmgLabels ~= 0
                warning('the argument checkEmgLabels must be 1, 0, or omitted');
            end
        end
    end
    methods % used for set,get, and saveobj methods
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

