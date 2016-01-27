classdef emg_tbiNMBL < handle
    % Filename: emg_tbi_nmbl.m
    % Author:   Samuel Acuna
    % Date:     25 Jan 2016
    % Description:
    % This class file is used to process collected EMG data from the TCNL
    % lab for their TBI study. This file will compare and analyze emg data
    % for only 1 subject, but 
    % across the average gait cycle for different trials, so before using
    % this class, each trial must be represented as a .mat file using the
    % class 'emgDataRaw_tbiNMBL'. 
    %
    % Example usage:
    %   subj1 = emg_tbiNMBL()
    %   subj1.loadTestPoint(1)
    %   subj1.loadTestPoint(2)
    %   subj1.plotGaitCycle()
    %   save('subj1.mat','subj1')
    %
    % note: protocol should be scripted like this in a driver file.
    
    properties(GetAccess = 'public', SetAccess = 'private')
        % public read access, but private write access.
        
        subjectID; % e.g. TBI-06
        subjectInitials; % e.g. SA
        subjectStatus; % e.g. completed, withdrawn, current
        subjectPoNS; % PoNS stimulation type. e.g. active, control, unknown (wont know until end of study)
        tpFlags; % array of which test points (tp01-tp06) have data in them e.g. [0 0 0 0] has no data, [1 0 0 0] has data only in tp01
        tp01; % trial data for test point 1
        tp02; % test point 2
        tp06; % test point 6
        tp10; % test point 10
        
        
    end
    methods ( Access = public )
        % constructor function
        function obj = emg_tbiNMBL()
            % constructor function, set up property values
            obj.subjectID = '';
            obj.subjectInitials = '';
            obj.subjectStatus = '';
            obj.subjectPoNS = '';
            obj.tpFlags = [0 0 0 0]; % no data loaded into test points yet
            updateSubjectGeneralData(obj); %setup general subject information 
        end
        function updateSubjectGeneralData(obj)
            % update general subject information
            
            % first, update subject identifier
            prompt1 = {'Subject ID:   (ex: "TBI-06")',...
                'Subject Initials:   (ex: "SA")'};
            prompt1_defaultAnswer = {obj.subjectID,obj.subjectInitials};
            prompt1_title = 'Subject Information';
            prompt1_answer = inputdlg(prompt1,prompt1_title,[1 60],prompt1_defaultAnswer);
            if isempty(prompt1_answer); return; end; % user canceled. bail out.
            % update subject info
            obj.subjectID = prompt1_answer{1};
            obj.subjectInitials = prompt1_answer{2};
            
            % second, update the status of the subject
            statuses = {'current','completed','withdrawn'};
            prompt2_defaultAnswer = find(strcmp(obj.subjectStatus,statuses)==1); % find default answer
            if isempty(prompt2_defaultAnswer); prompt2_defaultAnswer = 1; end; % if setting for first time
            prompt2_title = 'Specify TBI Subject Status:';
            prompt2_title2 = 'Subject Status';
            prompt2_answer = listdlg('PromptString',prompt2_title,'SelectionMode','single','Name',prompt2_title2,'ListString',statuses,'InitialValue',prompt2_defaultAnswer,'ListSize',[150 75]);
            if isempty(prompt2_answer); return; end; % user canceled. bail out.
            % update status
            obj.subjectStatus = statuses{prompt2_answer};
            
            % third, update PoNS stimulation type
            PoNS = {'unknown', 'active', 'control'};
            prompt3_defaultAnswer= find(strcmp(obj.subjectPoNS,PoNS)==1);
            if isempty(prompt3_defaultAnswer); prompt3_defaultAnswer = 1; end; % if setting for first time
            prompt3_title = 'Select PoNS stimulation type:';
            prompt3_title2 = 'PoNS type';
            prompt3_answer = listdlg('PromptString',prompt3_title,'SelectionMode','single','Name',prompt3_title2,'ListString',PoNS,'InitialValue',prompt3_defaultAnswer,'ListSize',[150 75]);
            if isempty(prompt3_answer); return; end; % user canceled. bail out.
            % update trial type
            obj.subjectPoNS = PoNS{prompt3_answer};
        end
        function loadTestPoint(obj,testPoint)
            % loads collection data into either tp01,tp02,tp06,tp10
            
            if ~any(testPoint==[1 2 6 10])
                error('Specified test point is not valid. test point must be integer value of 1, 2, 6, or 10');
            end
            
            [infile, inpath]=uigetfile('*.mat','Select input file');
            if infile == 0
                error('loadTestPoint canceled. No file selected');
            end
            
            
            load(infile); % loads a strucutre called emgcyc into workspace
            
            if ~exist('emgcyc','var')
                error('the .mat file you selected is not the appropriate file type. Use the class emgDataRaw_tbiNMBL to create this file type')
            end
            
            % check that subject IDs are the same
            tbiNum_index = regexp(obj.subjectID, '\d');
            tbiNum = str2num(obj.subjectID(tbiNum_index));
            emgcyc_tbiNum_index = regexp(emgcyc.subjectID, '\d');
            emgcyc_tbiNum = str2num(emgcyc.subjectID(emgcyc_tbiNum_index));
            if (emgcyc_tbiNum ~= tbiNum)
                warning([emgcyc.subjectID ' ~= ' obj.subjectID '. Subject number for this trial is not consistent with the general subject information.'])
            end
            
            % check that testpoints are consistent
            if (str2num(emgcyc.testPoint)~=testPoint)
                warning(['This collection is from test point ' emgcyc.testPoint '. But you are loading the data into the slot for testpoint ' num2str(testPoint) '.']);
            end
            
            % load collection data into testPoint data slot
            switch testPoint
                case 1; % tp01
                    obj.tp01 = emgcyc;
                    obj.tpFlags(1) = 1;
                case 2; % tp02
                    obj.tp02 = emgcyc;
                    obj.tpFlags(2) = 1;
                case 6; % tp06
                    obj.tp06 = emgcyc;
                    obj.tpFlags(3) = 1;
                case 10; % tp10
                    obj.tp10 = emgcyc;
                    obj.tpFlags(4) = 1;
            end
            disp(['trial data loaded into slot for testpoint ' num2str(testPoint) '.']);
        end
        function plotGaitCycle(obj, testPoints, checkEmgLabels)
            % this function plots the emg gait cycle data for array of test
            % Points
            % Plots right and left leg muscles, 6 muscles (mean +/- std)
            % e.g. sub1.plotGaitCycle() % plots all available testpoints
            % e.g. sub1.plotGaitCycle([1 2]) % plots selected testpoints
            % e.g. sub1.plotGaitCycle([1 2],1) % visually output all labels
            % to manually verify the emg labels are consistent
            
            % if no testPoints array specified, plots all available testpoints
            if nargin == 1
                plotFlags = obj.tpFlags;
                testPoints = flag2tp(obj.tpFlags);
            else % use user specified testPoints
                plotFlags = tp2flag(testPoints); % determines which test points to plot
                % select correct testPoint data for plotting
                for i = 1:4 % check that testpoint actually has data
                    if plotFlags(i) && ~obj.tpFlags(i)
                        warning(['test point ' num2str(testPoints(i)) 'has no data in it. Load data into it using loadTestPoint']);
                        plotFlags(i) = 0;
                    end
                end
                
            end
            
            if nargin == 3
            % check emg labels are consistent
            obj.checkConsistentEmgLabels(plotFlags);
            end
            
            
            % plotting parameters
            figure('Name','EMG over Gait Cycle')
            suptitle_name = [obj.subjectID ' : Test Point ' num2str(testPoints)];
            xAxisLabel = 'Percent of Gait Cycle';
            yAxisLimit = [0 3];
            plotColors = {'b' 'r' 'g' 'k'}; % the order of colors plotted, e.g. tp01 = blue
            
            % plot the testpoints as specified by plotFlags
            for i = 1:4
                if plotFlags(i)
                    
                    % pull emg data
                    switch i
                        case 1; % tp01
                            emgcyc = obj.tp01.emg;
                            emgcycstd = obj.tp01.emgstd;
                            emgcyclabel = obj.tp01.emglabel;  % these labels should be same for each trial
                        case 2; % tp02
                            emgcyc = obj.tp02.emg;
                            emgcycstd = obj.tp02.emgstd;
                            emgcyclabel = obj.tp02.emglabel;
                        case 3; % tp06
                            emgcyc = obj.tp06.emg;
                            emgcycstd = obj.tp06.emgstd;
                            emgcyclabel = obj.tp06.emglabel;
                        case 4; % tp10
                            emgcyc = obj.tp10.emg;
                            emgcycstd = obj.tp10.emgstd;
                            emgcyclabel = obj.tp10.emglabel;
                    end
                    
                    % plot emg data
                    for j=1:6;% RIGHT LEG
                        subplot(6,2,2*j); % plots on right half of figure
                        hold on
                        shadedErrorBar([0:100]',emgcyc(:,j),emgcycstd(:,j),plotColors{i},1); % right leg
                        handle(i) = plot([0:100]',emgcyc(:,j),plotColors{i});
                        hold off
                        title(emgcyclabel(j));
                        ylim(yAxisLimit);
                        %xlabel(xAxisLabel);
                    end
                    for j=1:6 % LEFT LEG
                        subplot(6,2,2*j-1);
                        hold on
                        shadedErrorBar([0:100]',emgcyc(:,6+j),emgcycstd(:,6+j),plotColors{i},1); % left leg
                        plot([0:100]',emgcyc(:,6+j),plotColors{i});
                        hold off
                        title(emgcyclabel(6+j));
                        ylim(yAxisLimit);
                        %xlabel(xAxisLabel);
                    end
                end
            end
            
            
            if exist('handle','var') % if cycles were plotted
                % create legend
                tp = flag2tp(plotFlags);
                tp_strings = strcat('TP',strread(num2str(tp),'%s'));
                
                handle = handle(find(plotFlags==1));
                h = legend(handle(:),tp_strings);
                set(h,'Position',[.4 .001 .2 .1]); % normalized to figure : left, bottom, width, height
                set(h,'Box','on','Orientation','horizontal','FontSize',12);
                
                % create title
                suptitle(suptitle_name);
            end
        end
    end
    methods ( Access = private )
        function checkConsistentEmgLabels(obj, checkFlags)
            % allows to visually output the emg data labels to check to see
            % if the emg data labels are consistent, and didnt get mixed up
            % when recording
            
            for i = 1:4
                if checkFlags(i)
                    % pull emg data labels
                    switch i
                        case 1; % tp01
                            disp('TestPoint 1 EMG Muscle Labels:')
                            disp(obj.tp01.emglabel');  % these labels should be same for each trial examined
                        case 2; % tp02
                            disp('TestPoint 2 EMG Muscle Labels:')
                            disp(obj.tp02.emglabel');
                        case 3; % tp06
                            disp('TestPoint 6 EMG Muscle Labels:')
                            disp(obj.tp06.emglabel');
                        case 4; % tp10
                            disp('TestPoint 10 EMG Muscle Labels:')
                            disp(obj.tp10.emglabel');
                    end
                end
            end
            
        end
    end         
end

function flags = tp2flag(testPoints)
% input: an array of testpoints e.g. [1 6 10]
% output: flags of those testpoints e.g. [1 0 1 1]
flags = [0 0 0 0];
for i = 1:length(testPoints)
    switch testPoints(i)
        case 1; % tp01
            flags(1) = 1;
        case 2; % tp02
            flags(2) = 1;
        case 6; % tp06
            flags(3) = 1;
        case 10; % tp10
            flags(4) = 1;
        otherwise
            disp(['Specified test point ' num2str(testPoints(i)) 'is not valid,']);
            disp(['and has been dropped from analysis. test point must be integer']);
            disp(['value of 1, 2, 6, or 10.    e.g. testPoints = [1 2 6 10]']);
    end
end
end

function tp = flag2tp(flags)
% input: flags of the testpoints e.g. [1 0 1 1]
% output: an array of testpoints e.g. [1 6 10]
tp = [];
tp_choices = [1 2 6 10];
for i = 1:4
    if flags(i)
        tp = [tp tp_choices(i)];
    end
end
end