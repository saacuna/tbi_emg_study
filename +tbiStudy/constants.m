classdef constants
    % lists constants used in tbiStudy functions
    properties (Constant, Access = 'public')
        % database properties
        testPoint = {[01] [02] [06] [10] [00]};
        trialType = {'baseline', 'overground','preferred','treadmill22','treadmill28','treadmill34'}; % 'relaxedStanding', 'relaxedLying', 'checkMuscles'};
        status = {'completed','current','withdrawn'};  % possible statuses of each subject we bring in
        stimulation_level = {'unknown', 'active', 'control','N/A'}; % level on the PoNS devices, wont know until after completion of study collections (n/a for people who dont use the pons)
        muscles = {'tibialisAnterior','gastrocnemius','soleus','vastusLateralis','rectusFemoris','semitendinosus'};
        col = struct('rTA',1,'rMG',2,'rSL',3,'rVL',4,'rRF',5,'rMH',6,'lTA',7,'lMG',8,'lSL',9,'lVL',10,'lRF',11,'lMH',12); % columns of EMG data, for reference
        
        % data files properties
        dataFolder = '/Users/samuelacuna/Box Sync/_RESEARCH/_Project Files/tcnl_TBI_EMG_study/_data/';
        
        % healthy control properties
        nHealthy = 20; %number of healthy controls
        
        % database connection properties
        trials_columnNames = {'subject_id','testPoint','trialType','dataFileLocation', 'filename', 'trialProcessingNotes'};
        tbi_subjects_columnNames = {'subject_id','initials','stimulation_level','status'};
        testPoints_columnNames = {'subject_id','testPoint','dateCollected','dataCollectedBy','walkingSpeed_time1','walkingSpeed_1','walkingSpeed_time2','walkingSpeed_2','walkingSpeed_preferred','treadmillSpeed_preferred','treadmillSpeed_baseline','notes'};
    end
    methods (Static = true)
        function db = dbURL() % get database connection 
            db = ['jdbc:sqlite:' tbiStudy.constants.dataFolder 'emg_tbi_database.db'];
        end
        function h = healthy(type) % get average healthy controls for comparison
            if nargin == 0; type = 'treadmill22'; end
            h = [tbiStudy.constants.dataFolder 'Healthy Controls/HYN_all/'];
            switch type
                case 'treadmill22'
                    h = [h 'hyn_all_01_tp00_treadmill22.mat']; % walking at 2.2 mph
                case 'treadmill28'
                    h = [h 'hyn_all_01_tp00_treadmill28.mat']; % walking at 2.8 mph
                case 'treadmill34'
                    h = [h 'hyn_all_01_tp00_treadmill34.mat']; % walking at 3.4 mph
                case 'overground'
                    h = [h 'hyn_all_01_tp00_overground.mat']; % walking overground at preferred speed
                otherwise
                    error('Not a valid healthy file type');
            end
        end
        function h = healthyFolder() % get average healthy controls folder
            h = [tbiStudy.constants.dataFolder 'Healthy Controls/'];
        end
    end
end