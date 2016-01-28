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
    properties (Dependent)
        numSubjects; % how many subjects have been stored in database
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
        function removeSubject(obj,subjectIndexNumber) % remove a subject from the database
            if (obj.numSubjects < subjectIndexNumber) % subject number must be valid
                disp(['Subject Index #' num2str(subjectIndexNumber) ' is not in this database.']);
            else
                obj.subjects(subjectIndexNumber) = []; % deletes that cell and resizes subject array
                disp(['Subject Index #' num2str(subjectIndexNumber) ' removed from database. Database re-indexed.']);
                obj.listSubjects();
            end
        end
        function listSubjects(obj) % lists off all subjects in the database
            if ~obj.numSubjects % dont display if empty database
                disp('No subjects in database.');
            else % compile output display
                fprintf('%s\n\t%s\t%s\t%s\t%s\n' ,'Subjects in database:','Index','Subject','StimLvl','TestPts'); % list headers
                for indexNumber = 1:obj.numSubjects % print out index number and subject ID number, etc
                    vals = {indexNumber, obj.subjects{indexNumber}.ID, obj.subjects{indexNumber}.stimLvl, obj.subjects{indexNumber}.numTestPoints};
                    fprintf('\t%d\t%s\t%s\t%d\n',vals{:});
                end
            end
        end
        
    end
    methods % used for set and get methods
        function numSubj = get.numSubjects(obj) % calculate the number of test points stored
            numSubj = length(obj.subjects);
        end
        function set.numSubjects(obj,~) % cant set dependent number of test points
            fprintf('%s%d\n','numSubjects is: ',obj.numSubjects)
            error('You cannot set the numSubjects property');
        end
    end
    
end

