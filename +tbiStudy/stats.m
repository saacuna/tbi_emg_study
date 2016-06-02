classdef stats
    % Filename: stats.m
    % Author:   Samuel Acuna
    % Date:     24 May 2016
    % Description:
    % This class holds static statistic functions for the tbi data;
    
    % future tests to look at:
    % how has variability changed?
    % how consistent across time?
    % compare speeds (10% increase?)
    
     methods (Static)
         function [cor,h,p] = ttestMuscle(muscleNumber)
             muscleName = tbiStudy.constants.muscles{muscleNumber};
             [~, cor] = tbiStudy.correlation.DGIvsHealthy_muscle(muscleNumber);
             disp(['average correlation for ' muscleName ':']);
             disp('[mean pre, mean post] = ');
             mean(cor)
             disp(['t-test of ' muscleName ':']);
             [h,p,ci,stats] = ttest(cor(:,1),cor(:,2)) % test for signifcant change in correlation
         end
         function [DGI,h,p] = ttestDGI()
             [DGI] = tbiStudy.correlation.DGIvsHealthy_muscle(1);
             disp(['average DGI:']);
             disp('[mean pre, mean post] = ');
             mean(DGI)
             disp(['t-test of DGI:']);
             [h,p,ci,stats] = ttest(DGI(:,1),DGI(:,2)) % test for signifcant change in correlation
             % [h,p,ci,stats] = ttest(DGI(:,1),DGI(:,2),'Alpha',0.01) 
         end
         
     end
    
end