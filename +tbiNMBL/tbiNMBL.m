classdef tbiNMBL < handle
    % Filename: tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     27 Jan 2016
    % Description:
    % This class is used for the PoNS tbi study at the TCNL. This class
    % houses the emg data for all subjects, testpoints, and trials allowing
    % for easy comparison within subjects and between subjects
    
    properties (GetAccess = 'public', SetAccess = 'private')
        subjects; % stores emg & info on each subject
    end
    
    methods (Access = public)
        % if using separate file, declare function signature
        % e.g. output = myFunc(obj,arg1,arg2)
        
        function obj = tbiNMBL()% constructor function
            obj.subjects = cell(0); %setup database of subjects
        end
        function addSubject(obj) % add new subject to database
            obj.subjects{length(obj.subjects)+1} = tbiNMBL.subject_tbiNMBL(); % creates a new instance of the subject class
            disp(['Subject ' obj.subjects{end}.ID ' has been added to the database.']);
            obj.listSubjects();
        end
        function removeSubject(obj,subjNum) % remove a subject from the database
            if (length(obj.subjects)<subjNum) % subject number must be valid
                disp(['Subject ' num2str(subjNum) ' is not in this database.']);
            else
                obj.subjects(subjNum) = []; % deletes that cell and resizes subject array
                disp(['Subject ' num2str(subjNum) ' removed from database.']);
                obj.listSubjects();
            end
        end
        function listSubjects(obj) % lists off all subjects in the database
            if isempty(obj.subjects) % dont display if empty
                disp('     None.');
            else % compile output display
                fprintf('%s\n\t%s\t%s\t%s\t%s\n' ,'Subjects in database:','Index','Subject','StimLvl','TestPts'); % list headers
                indexLength = length(obj.subjects); 
                for indexNumber = 1:indexLength % print out index number and subject ID number, etc
                    vals = {indexNumber, obj.subjects{indexNumber}.ID, obj.subjects{indexNumber}.stimLvl, obj.subjects{indexNumber}.numTestPoints};
                    fprintf('\t%d\t%s\t%s\t%d\n',vals{:});
                end
            end
        end
        
    end
    
end

