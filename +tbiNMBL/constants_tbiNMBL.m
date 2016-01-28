classdef constants_tbiNMBL
    % this is just a file listing important constants used throughout all
    % the tbi_NMBL classes
   properties (Constant, Access = 'public')
      trialType = {'treadmill_preferredSpeed', 'treadmill_baselineSpeed', 'overground', 'relaxed_standing', 'relaxed_laying_down', 'check_muscles'}; % different types of collection trials we record
      subjectStatus = {'completed','current','withdrawn'};  % possible statuses of each subject we bring in
      stimLvl = {'unknown', 'active', 'control'}; % level on the PoNS devices, wont know until after completion of study collections
      TP = {[01] [02] [06] [10]}; % different testpoints we are collecting data at
       
   end
end