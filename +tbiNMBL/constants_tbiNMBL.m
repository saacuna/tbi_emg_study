classdef constants_tbiNMBL
    % this is just a file listing important constants used throughout all
    % the tbi_NMBL classes
   properties (Constant, Access = 'public')
      trialType = {'tmill_pref', 'tmill_base', 'overground', 'relax_stnd', 'relax_lyng', 'check_musc'}; % different types of collection trials we record
      subjectStatus = {'completed','current','withdrawn'};  % possible statuses of each subject we bring in
      stimLvl = {'unknown', 'active', 'control'}; % level on the PoNS devices, wont know until after completion of study collections
      TP = {[01] [02] [06] [10]}; % different testpoints we are collecting data at
      
      % plotting parameters
      emgPlotYAxisLimits = [0, 3]; 
      emgPlotXAxisLabel = '' % 'Percent of Gait Cycle';
      emgPlotColors = {'b' 'r' 'g' 'k'}; % the order of colors plotted
   end
end