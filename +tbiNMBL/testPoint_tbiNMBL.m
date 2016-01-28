classdef testPoint_tbiNMBL < handle
    % Filename: testPoint_tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     27 Jan 2016
    % Description:
    % This class houses the emg data for one testpoint allowing
    % for easy comparison  within different trials during that testpoint
    properties (GetAccess = 'public', SetAccess = 'private')
        TP; % which test point it is, i.e. 1, 2, 6, 10
        trials; % stores emg collection data for every trial in the testpoint
    end
    properties (Dependent)
        numTrials; % how many trials have been stored in this test point
    end
    methods (Access = public)
        function tp = testPoint_tbiNMBL() % constructor function
            tp.setTP();
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
        function addTrial(tp) % add collection trial to test point
            
        end
        function removeTrial(tp, trNum) % remove collection trial to test point
            
        end
        function listTrials(tp) % list collection trials to test point
            
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
    end
    
end

