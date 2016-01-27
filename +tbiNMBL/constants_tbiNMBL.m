classdef constants_tbiNMBL
    % this is just a file listing important constants used throughout all
    % the classes
   properties (Constant, Access = 'public')
      trialType = {'treadmill_preferredSpeed', 'treadmill_baselineSpeed', 'overground', 'relaxed_standing', 'relaxed_laying_down', 'check_muscles'};
      subjectStatus = {'completed','current','withdrawn'}; 
      stimLvl = {'unknown', 'active', 'control'};
       
       
   end
end