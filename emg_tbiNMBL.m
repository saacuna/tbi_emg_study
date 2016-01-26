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
    %   subj1.plotGaitCycle(1)
    %   save('subj1.mat','subj1')
    %
    % note: protocol should be scripted like this in a driver file.
    
    properties(GetAccess = 'public', SetAccess = 'private')
        % public read access, but private write access.
        
        subjectID; % e.g. TBI-06
        subjectInitials; % e.g. SA
        subjectStatus; % e.g. completed, withdrawn, current
        subjectPoNS; % PoNS stimulation type. e.g. active, control, unknown (wont know until end of study)
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
                case 2; % tp02
                    obj.tp02 = emgcyc;
                case 6; % tp06
                    obj.tp06 = emgcyc;
                case 10; % tp10
                    obj.tp10 = emgcyc;
            end
            disp(['trial data loaded into slot for testpoint ' num2str(testPoint) '.']);
        end
        
        function plotGaitCycle(obj, testPoint)
            % this function plots the emg gait cycle data for 1 test Point
            % Plots right and left leg muscles, 6 muscles (mean +/- std)
            
            % select correct testPoint data
            if ~any(testPoint==[1 2 6 10])
                error('Specified test point is not valid. test point must be integer value of 1, 2, 6, or 10');
            end
            try
                switch testPoint
                    case 1; % tp01
                        emgcyc = obj.tp01.emg;
                        emgcycstd = obj.tp01.emgstd;
                        emgcyclabel = obj.tp01.emglabel;
                    case 2; % tp02
                        emgcyc = obj.tp02.emg;
                        emgcycstd = obj.tp02.emgstd;
                        emgcyclabel = obj.tp02.emglabel;
                    case 6; % tp06
                        emgcyc = obj.tp06.emg;
                        emgcycstd = obj.tp06.emgstd;
                        emgcyclabel = obj.tp06.emglabel;
                    case 10; % tp10
                        emgcyc = obj.tp10.emg;
                        emgcycstd = obj.tp10.emgstd;
                        emgcyclabel = obj.tp10.emglabel;
                end
            catch
                error(['test point ' num2str(testPoint) 'has no data in it. Load data into it using loadTestPoint'])
            end
            % construct plot
            figure()
            suptitle_name = [obj.subjectID ' : Test Point ' num2str(testPoint)];
            xAxisLabel = 'Percent of Gait Cycle';
            yAxisLimit = [0 3];
            for j=1:6 % RIGHT LEG
                subplot(6,2,2*j); % plots on right half of figure
                hold on
                shadedErrorBar([0:100]',emgcyc(:,j),emgcycstd(:,j),'b',1); % right leg
                plot([0:100]',emgcyc(:,j),'b');
                hold off
                title(emgcyclabel(j));
                ylim(yAxisLimit);
                %xlabel(xAxisLabel);
            end
            for j=1:6 % LEFT LEG
                subplot(6,2,2*j-1);
                hold on
                shadedErrorBar([0:100]',emgcyc(:,6+j),emgcycstd(:,6+j),'b',1); % left leg
                plot([0:100]',emgcyc(:,6+j),'b');
                hold off
                title(emgcyclabel(6+j));
                ylim(yAxisLimit);
                %xlabel(xAxisLabel);
            end
            suptitle(suptitle_name);
        end
            
    end
    methods ( Access = private )
    
    end         
end