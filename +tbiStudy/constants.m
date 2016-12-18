classdef constants
    % lists constants used in tbiStudy functions
   properties (Constant, Access = 'public')
      % database properties
      testPoint = {[01] [02] [06] [10] [00]};
      trialType = {'baseline', 'overground','preferred','treadmill22','treadmill28','treadmill34'}; % 'relaxedStanding', 'relaxedLying', 'checkMuscles'};
      status = {'completed','current','withdrawn'};  % possible statuses of each subject we bring in
      stimulation_level = {'unknown', 'active', 'control','N/A'}; % level on the PoNS devices, wont know until after completion of study collections (n/a for people who dont use the pons)
      muscles = {'tibialisAnterior','gastrocnemius','soleus','vastusLateralis','rectusFemoris','semitendinosus'};
      
      % data files properties
      dataFolder = '/Users/samuelacuna_mini/Documents/_Local Data/data tbi_emg_study/';
      healthy =  '/Users/samuelacuna_mini/Documents/_Local Data/data tbi_emg_study/Healthy Controls/HYN_all/hyn_all_01_tp00_treadmill28.mat';
            
      % database connection properties
      dbURL = 'jdbc:sqlite:/Users/samuelacuna_mini/Documents/_Local Data/data tbi_emg_study/emg_tbi_database.db';
      trials_columnNames = {'subject_id','testPoint','trialType','dataFileLocation', 'filename', 'trialProcessingNotes'};
      tbi_subjects_columnNames = {'subject_id','initials','stimulation_level','status'};
      testPoints_columnNames = {'subject_id','testPoint','dateCollected','dataCollectedBy','walkingSpeed_time1','walkingSpeed_1','walkingSpeed_time2','walkingSpeed_2','walkingSpeed_preferred','treadmillSpeed_preferred','treadmillSpeed_baseline','notes'};
   end
end