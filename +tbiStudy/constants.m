classdef constants
    % this is just a file listing important constants used throughout all
    % the tbi_NMBL classes
   properties (Constant, Access = 'public')
      testPoint = {[01] [02] [06] [10]}; 
      trialType = {'baseline', 'overground','preferred','relaxedStanding', 'relaxedLying', 'checkMuscles'};

      subjectStatus = {'completed','current','withdrawn'};  % possible statuses of each subject we bring in
      stimLvl = {'unknown', 'active', 'control','N/A'}; % level on the PoNS devices, wont know until after completion of study collections (n/a for people who dont use the pons)

      
      % plotting parameters
      emgPlotYAxisLimits = [0, 4]; 
      emgPlotXAxisLabel = '' % 'Percent of Gait Cycle';
      emgPlotColors = {rgb('Blue') rgb('Red') rgb('ForestGreen') rgb('Yellow') rgb('Tomato')}; % the order of colors plotted, using rgb (Author: Kristján Jónasson, Dept. of Computer Science, University of Iceland (jonasson@hi.is). June 2009.
      emgAreaColors = {rgb('Gray') };
      legendPosition = [.4 .001 .2 .1] ; % normalized to figure : left, bottom, width, height
      transparentErrorBars = [1]; % 1 = transparent, 0 = opaque
      showErrorBars = [1]; % 1 = show them, 0 = hide
      dgiPlotYAxisLimits = [0,1];
      dgiPlotXAxisLimits = [0,25];
   end
end