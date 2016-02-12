classdef subject_tbiNMBL < handle
    % Filename: subject_tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     27 Jan 2016
    % Description:
    % This class houses the emg data for one subject allowing
    % for easy comparison  within testpoints and between testPoints
    % e.g. subj1 = tbiNMBL.subject_tbiNMBL()
    %      subj1.addTestPoint()
    %      subj1.listTestPoints()
    %      subj1.addTrial(1); % add trial to testpoint 1
    %      subj1.listTrials(1); % list trial of selected testPoint 1
    %      subj1.plotTestPoint(1) % plot testPoint 1
    %      subj1.list % lists all data
    %      subj1.plotSubject()
    %      subj1.correlationOfTestPoint()
    
    properties (GetAccess = 'public', SetAccess = 'public')%SetAccess = 'private')
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
                % unfortunately it is a lot of work to load previously
                % saved testpoints into this class. I tried doing it once,
                % but I would have to implement a lot of saveobj and
                % loadobj methods, and I gave up.
        end
        function removeTestPoint(subj, testPointIndex) % remove testpoint data
            if subj.checkValidTestPointIndex(testPointIndex) % testpoint number must be valid                
                subj.testPoints(testPointIndex) = []; % deletes that cell and resizes testpoint array
                disp(['Test Point Index #' num2str(testPointIndex) ' removed from database. Database re-indexed.']);
                subj.listTestPoints();
            end
        end
        function listTestPoints(subj) % list off all testpoints for this subject
            if ~subj.numTestPoints % if no testpoint data stored yet
                disp('No testPoint data for this subject has been stored.');
            else % compile output display
                fprintf('\n\t%s%s%s\n','TESTPOINT INDEX, Subject ',subj.ID,':');
                subj.listTestPointsHeader % list header of testpoint data
                indexLength = subj.numTestPoints;
                for testPointIndex = 1:indexLength % print out index number and walkingspeed_preferred, etc
                    subj.listTestPointsMetadata(testPointIndex)
                end
            end
        end
        function plotTestPoint(subj, testPointIndex, checkEmgLabels)
            % this function plots the emg gait cycle data for array of
            % trials in specific test point.
            if nargin == 1 
                disp('No testPointIndex number specified, so this wont plot anything.');
                return
            end
            if nargin == 2 % if checkEmgLabels not specified, dont view labels
                checkEmgLabels = 0;
            end
            if length(testPointIndex) > 1; error('can only plot one trial with this method. Suggest using testPoint_tniNMBL.plotTestPoint() instead'); end;
            if ~subj.checkValidTestPointIndex(testPointIndex); return; end; % selected testPoint number must be in database
            
            % testPoint must have existing trials
            if ~subj.checkValidTrialsInTestPoint(testPointIndex,subj.testPoints{testPointIndex}.numTrials); return; end;
            
            % gather all trials in selected testPoint
            trialIndex = 1:subj.testPoints{testPointIndex}.numTrials;
            
            % plot all the trials in the testPoint
            figure('Name',['Test Point ' num2str(testPointIndex)]);
            subj.testPoints{testPointIndex}.plotTestPointEmg(trialIndex,checkEmgLabels);
            suptitle(['Subject ' subj.ID ' : Test Point ' num2str(testPointIndex)]); % create supertitle
            subj.testPoints{testPointIndex}.plotTestPointLegend(trialIndex); % create legend
        end
        function addTrial(subj,testPointIndex) % add trial to selected testPoint
            if ~subj.checkValidTestPointIndex(testPointIndex); return; end; % selected trial number must be in database
            subj.testPoints{testPointIndex}.addTrial
        end
        function removeTrial(subj,testPointIndex,trialIndexNumber) % careful! Removes a specific trial from a testpoint
            if subj.checkValidTestPointIndex(testPointIndex) % testpoint number must be valid                
                subj.testPoints{testPointIndex}.removeTrial(trialIndexNumber);
            end
        end
        function listTrials(subj,testPointIndex) % list trials of selected testPoint
            if ~subj.checkValidTestPointIndex(testPointIndex); return; end; % selected trial number must be in database
            fprintf('\n\t%s%s%s\n','::: Test Point Index ', num2str(testPointIndex),' ::::');
            subj.testPoints{testPointIndex}.listTrials
        end
        function list(subj) % lists all testpoints and trials for the subject
            if ~subj.numTestPoints % if no testpoint data stored yet
                fprintf('\n\t%s\n','No testPoint data for this subject has been stored.');
            else % compile output display
                fprintf('\n\t%s%s%s\n','### All Data for Subject ',subj.ID,' ###');
                subj.listSubjectMetaData
                fprintf('\n\t%s%s%s\n','TESTPOINT INDEX, Subject ',subj.ID,':');
                
                subj.listTestPointsHeader % list header of testpoint data
                indexLength = subj.numTestPoints;    
                for testPointIndex = 1:indexLength 
                    subj.listTestPointsMetadata(testPointIndex) % list testpoint index data
                end
                for testPointIndex = 1:indexLength 
                    subj.listTrials(testPointIndex)% list trial data for that testpoint index 
                end
            end
        end
        function plotSubject(subj,testPointIndex,trialIndex,checkEmgLabels)
            % this function plots the emg gait cycle data for array of
            % testpoints.
            % Plots right and left leg muscles, 6 muscles (mean +/- std)
            % e.g. subj.plotSubject() % plots all available testpoints
            % e.g. subj.plotSubject([1 3]) % plots first trials for selected testpoints
            % e.g. subj.plotSubject([1 3],[2,4]) % plots selected trials for selected testpoints
            % e.g. subj.plotSubject([1 3],[2,4],1) % visually output all labels
            % to manually verify the emg labels are consistent
            if nargin == 1 % if no testPoints specified, plot them all, dont view labels
                testPointIndex = 1:subj.numTestPoints;
                disp(['testPointIndex assumed to be all test points. testPointIndex = [' num2str(testPointIndex) '].']);
            end
            if nargin <= 2
                % check testPointIndex
                if ~subj.checkValidTestPointIndex(testPointIndex); return; end; % selected test Point number must be in database
                for i = 1:length(testPointIndex)
                    trialIndex(i) = 1; % if not specified, assume the first trialIndex in the testPoint
                end
                disp(['trialIndex assumed to be first in all test points. trialIndex = [' num2str(trialIndex) '].']);
            end
            if nargin <= 3
                % trial index must be same size and testPointindex
                if length(trialIndex) ~= length(testPointIndex); disp(['trialIndex and testPointIndex must be the same size!']);return; end;
                % selected trial must be in a selected testpoint
                for i = 1:length(testPointIndex);
                    if ~subj.checkValidTrialsInTestPoint(testPointIndex(i), trialIndex(i)); return; end;
                end
                checkEmgLabels = 0; % if checkEmgLabels not specified, dont view labels
            end
            
            % plot the testpoints for the subject, but only 1 trial per testpoint
            figure('Name',['Subject ' subj.ID]);
            for i = 1:length(testPointIndex) %testPointIndex % for all the selected testpoints
                subj.testPoints{testPointIndex(i)}.trials{trialIndex(i)}.plotTrialEmg(testPointIndex(i)) % plot only the selected trial in that testpoint
                
                % optionally diplay trial emg labels
                if checkEmgLabels; fprintf('\n%s%s%s%s%d%s', 'Subject ', subj.ID, ' : ', 'TestPoint ',subj.testPoints{testPointIndex(i)}.TP,' : '); end;
                subj.testPoints{testPointIndex(i)}.displayEmgTrials(checkEmgLabels, trialIndex(i)); 
            end
            suptitle_name = strcat('Subject',{' '}, subj.ID,'  :  Test Point',{'  '},num2str(cell2mat(tbiNMBL.constants_tbiNMBL.TP(testPointIndex))),'  : ',{'  '}, strrep(tbiNMBL.constants_tbiNMBL.trialType(trialIndex(1)),'_',' '));
            suptitle(suptitle_name); % create supertitle
            subj.plotSubjectLegend(testPointIndex); % create legend
        end
        function corrOfTP = correlationOfTestPoint(subj,testPointIndex)
            % Outputs correlation of muscle across trials in a single testPoint of same subject (preferred v baseline v overground)
            % Shows CONSISTENCY of gait in subject for that point in time
            if nargin == 1 
                disp('No testPointIndex number specified, so this wont correlate anything.');
                return
            end
            if length(testPointIndex) > 1; error('can only plot one trial with this method. Suggest using testPoint_tniNMBL.plotTestPoint() instead'); end;
            if ~subj.checkValidTestPointIndex(testPointIndex); return; end; % selected testPoint number must be in database
            
            % testPoint must have existing trials
            if ~subj.checkValidTrialsInTestPoint(testPointIndex,subj.testPoints{testPointIndex}.numTrials); return; end;
            
            corrOfTP = subj.testPoints{testPointIndex}.corrTestPoint(); % calc correlation across testPoint
            
            subj.listCorrelations(corrOfTP); % display calculated correlations
        end
        function corrAcTP = correlationAcrossTestPoints(subj,trialIndex)
            % Outputs correlation of muscle across same trialType across testPoints of same subject
            % Shows IMPROVEMENT of gait in subject overtime
            if nargin == 1
                trialIndex = 1; % if not specified, assume the first trialIndex in each testPoint
                disp(['Assume looking at first trial in test points.']);
            end
            
            % look at all testpoints
            testPointIndex = 1:subj.numTestPoints;
            disp(['Look at all ' num2str(subj.numTestPoints) ' testPoints for subject ' subj.ID]);
            
            % selected trial must be in a selected testpoint
            for i = 1:length(testPointIndex);
                if ~subj.checkValidTrialsInTestPoint(testPointIndex(i), trialIndex); return; end;
            end
            
            corrAcTP = cell(12,2); %  12 muscles x (data, name)
            for muscle = 1:12
                for i = 1:length(testPointIndex);
                    M(:,i) = subj.testPoints{testPointIndex(i)}.trials{trialIndex}.emgData(:,muscle); % assemble observation matrix for correlation
                end
                corrAcTP{muscle,1} = corrcoef(M(:,:)); % correlation of a muscle to itself across testPoints
                corrAcTP{muscle,2} = subj.testPoints{1}.trials{trialIndex}.emgLabel{muscle}; % muscle name
            end
            
            subj.listCorrelations(corrAcTP); % display calculated correlations
            
        end
        function corrSubj = correlationBetweenSubjects(subj1,subj2,testPointIndex1,testPointIndex2)
            if nargin == 2
                % look at first testpoints, if not specified
                testPointIndex1 = 1;
                testPointIndex2 = 1;
            end
            % correlation of two subjects
            fprintf('\n\t%s%s%s%s%s\n','Compare ', subj1.ID, ' with ', subj2.ID,' :' )
            fprintf('\t%s\n','Assume EMG labels are consistent between subjects');
            
            
            fprintf('\t%s%d%s%s%s\n','Look at testPoint ', testPointIndex1 ,' for subject ' ,subj1.ID ,'.')
            if ~subj1.checkValidTestPointIndex(testPointIndex1); return; end; % selected testPoint number must be in database
            fprintf('\t%s%d%s%s%s\n','Look at testPoint ', testPointIndex2 ,' for subject ' ,subj2.ID ,'.')
            if ~subj2.checkValidTestPointIndex(testPointIndex2); return; end; % selected testPoint number must be in database
            
            % assume the first trialIndex in each testPoint
            trialIndex = 1; 
            fprintf('\t%s%d%s\n','Assume looking at trial ', trialIndex, ' in both test points.')
            if ~subj1.checkValidTrialsInTestPoint(testPointIndex1,trialIndex); disp(['--> trialIndex is not valid for subject ' subj1.ID]); return; end;% testPoint must have existing trials
            if ~subj2.checkValidTrialsInTestPoint(testPointIndex2,trialIndex); disp(['--> trialIndex is not valid for subject ' subj2.ID]); return; end;% testPoint must have existing trials
            
            corrSubj = cell(12,2); %  12 muscles x (data, name)
            for muscle = 1:12    
                M(:,1) = subj1.testPoints{testPointIndex1}.trials{trialIndex}.emgData(:,muscle); % assemble observation matrix for correlation
                M(:,2) = subj2.testPoints{testPointIndex2}.trials{trialIndex}.emgData(:,muscle); % assemble observation matrix for correlation
                  
                corrSubj{muscle,1} = corrcoef(M(:,:)); % correlation matrix of a muscle between subjects, for 1 testpoint, 1 trial in that testpoint
                corrSubj{muscle,2} = subj1.testPoints{testPointIndex1}.trials{trialIndex}.emgLabel{muscle}; % muscle name
            end
            
            subj1.listCorrelations(corrSubj); % list the calculated correlations
        end
        function fixSensor1Data(subj,testPointIndex)% rearrange emg data for consistent order;
            % for some of the trials, sensor 1 was used in place of sensor
            % 8. This function rearranges the data from sensor 1 into the
            % slot for sensor 8 data. It just makes everything consistent.
            % Check out the order of the trials with displayEmgTrials method.
            %
            % inputs:
            % testPointIndex = required. Specify which single testPoint
            %              shuold have its data order fixed. all of its
            %              trials data will be affected.
            %
            % note: if you want to change specific trials, use the
            %   fixSensor1Data of the testPoint_tbiNMBL class using format:
            %   subj.testPoints{testPointIndex}.fixSensor1Data(trialIndex)
            
            if nargin == 1
                disp('No testPointIndex number specified, so this wont do anything.');
                return
            end
            if length(testPointIndex) > 1; error('can only fix one testPoint with method subject_tbiNMBL.fixSensor1Data'); end;
            if ~subj.checkValidTestPointIndex(testPointIndex); return; end; % selected testPoint number must be in database
            
            subj.testPoints{testPointIndex}.fixSensor1Data; % fix the testPoint data 
        end
    end
    methods (Access = private)
        function valid = checkValidTestPointIndex(subj,testPointIndex) % selected testPointmust be in database
            if (subj.numTestPoints < max(testPointIndex))
                disp(['testPointIndex is invalid. There are only ' num2str(subj.numTestPoints) ' testPoints for subject ' subj.ID '.']);
                valid = 0;
            elseif isempty(testPointIndex)
                disp(['There are no testpoints for subject ' subj.ID '.']);
                valid = 0;
            elseif testPointIndex == 0
                disp(['There are no testpoints for subject ' subj.ID '.']);
                valid = 0;
            else
                valid = 1;
            end
        end
        function valid = checkValidTrialsInTestPoint(subj, testPointIndex, trialIndex)
            if subj.checkValidTestPointIndex(testPointIndex) % must be valid testPointIndex
                if subj.testPoints{testPointIndex}.checkValidTrialIndex(trialIndex)% trialindex is in testpoint
                    valid = 1;
                else %trialindex is not in testpoint
                    disp(['--> No valid trials in testPointIndex ' num2str(testPointIndex)']);
                    valid = 0;
                end
            end
        end
        function listTestPointsMetadata(subj,testPointIndex) % lists line of metadata for a given testPoint
            vals = {testPointIndex,...
                        subj.testPoints{testPointIndex}.TP,...
                        subj.testPoints{testPointIndex}.numTrials,...
                        subj.testPoints{testPointIndex}.walkingSpeed_preferred,...
                        subj.testPoints{testPointIndex}.walkingSpeed_baseline,...
                        subj.testPoints{testPointIndex}.noteFlag,...
                        subj.testPoints{testPointIndex}.dataCollectedBy,...
                        subj.testPoints{testPointIndex}.dateCollected};
                    fprintf('\t%d\t%d\t%d\t%s\t%s\t%d\t%s\t%s\n',vals{:});
        end
        function listTestPointsHeader(subj) % list headers
            fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','Index','TestPt','nTrials', 'PrefSpd', 'BaseSpd', 'Notes', 'Admin.','Date'); % list headers
            fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' ,'-------','-------','-------','-------','-------','-------','-------','-------');
        end
        function listSubjectMetaData(subj)
            fprintf('\t%s\t%s\t%s\t%s\t%s\n','SubjID','Init.','TestPts','StimLvl','Status'); % list headers
            fprintf('\t%s\t%s\t%s\t%s\t%s\n' ,'-------','-------','-------','-------','-------');
            vals = {...
                subj.ID,...
                subj.initials,...
                subj.numTestPoints,...
                subj.stimLvl,...
                subj.status};
            fprintf('\t%s\t%s\t%d\t%s\t%s\n',vals{:});
        end
        function listCorrelations(subj,corrCoefs)
            % display correlation coefficients to the screen
            % corrCoefs will always be 12x2 cell. first column is the
            % correlation matrices, 2nd column is the muscle name
            
            if isequal(size(corrCoefs{1}),[2 2]) % 2x2 correlation matrix
                fprintf('\n\t%s\t%s\n\t%s\t%s\n','CorCoef','Muscle','-------','-------'); % list headers
                for muscle = 1:12 % list correlation coeff
                    fprintf('\t%1.2f\t%s\n',corrCoefs{muscle,1}(1,2),corrCoefs{muscle,2});
                end
                return
            end
            
            tpTitles = {'tp01','tp02','tp06','tp10'};
            fprintf('\n\t%s%s%s\n','Correlation Matrices, subject ',subj.ID,':'); % list main header
            for muscle = 1:12 % matrix for each muscle
                fprintf('\n\t%s%s\n','Muscle: ',corrCoefs{muscle,2}); % print muscle header
                if isequal(size(corrCoefs{1}),[3 3]) % 3x3 correlation matrix         
                    fprintf('\t\t%s\t%s\n',tpTitles{2},tpTitles{3})
                    fprintf('\t%s\t%1.2f\t%1.2f\n',tpTitles{1},corrCoefs{muscle,1}(1,2),corrCoefs{muscle,1}(1,3));
                    fprintf('\t%s\t%s\t%1.2f\n',tpTitles{2},'-',corrCoefs{muscle,1}(2,3));
                end
                if isequal(size(corrCoefs{1}),[4 4]) % 4x4 correlation matrix
                    fprintf('\t\t%s\t%s\t%s\n',tpTitles{2},tpTitles{3},tpTitles{4})
                    fprintf('\t%s\t%1.2f\t%1.2f\t%1.2f\n',tpTitles{1},corrCoefs{muscle,1}(1,2),corrCoefs{muscle,1}(1,3),corrCoefs{muscle,1}(1,4));
                    fprintf('\t%s\t%s\t%1.2f\t%1.2f\n',tpTitles{2},'-',corrCoefs{muscle,1}(2,3),corrCoefs{muscle,1}(2,4));
                    fprintf('\t%s\t%s\t%s\t%1.2f\n',tpTitles{3},'-','-',corrCoefs{muscle,1}(3,4));
                end
            end            
        end
        function plotSubjectLegend(subj,testPointIndex)
            % create workaround custom legend, not the cleanest, but easier than
            % moving around handles from different classes
            hold on
            for i = testPointIndex
                handle(i) = plot(NaN,NaN,'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{i});
            end
            hold off
            testPoint_strings = strcat('TestPt ',num2str(cell2mat(tbiNMBL.constants_tbiNMBL.TP(testPointIndex)')));
            set(handle(:),'linewidth',5);
            h = legend(handle(:),testPoint_strings);
            set(h,'Position',tbiNMBL.constants_tbiNMBL.legendPosition);
            set(h,'Box','on','Orientation','horizontal','FontSize',12);
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

