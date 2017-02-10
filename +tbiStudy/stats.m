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
             [h,p,ci,stats] = ttest(DGI(:,1),DGI(:,2)) % test for signifcant difference
             % [h,p,ci,stats] = ttest(DGI(:,1),DGI(:,2),'Alpha',0.01) 
         end
         function [walkDMC,h,p] = ttestWalkDMCvHealthy()
             testPoint = 1;
             trialType = 'baseline';
             healthyTrialTypeNumber = 4;
             
             % calc walkDMC data
             walkDMC_TBI = tbiStudy.synergies.walkDMC(testPoint,trialType,healthyTrialTypeNumber);
             walkDMC_healthy = tbiStudy.synergies.walkDMC_healthy(healthyTrialTypeNumber);
             
             walkDMC_TBI_all = [walkDMC_TBI(:,1); walkDMC_TBI(:,2)];
             walkDMC_healthy_all = [walkDMC_healthy(:,1); walkDMC_healthy(:,2)];
             
             walkDMC_TBI_avg = mean(walkDMC_TBI');
             walkDMC_healthy_avg = mean(walkDMC_healthy');
             
             
             disp(['TBI data: testPoint=' num2str(testPoint) ' trialType=' trialType ' healthyTrialType=' tbiStudy.constants.trialType{healthyTrialTypeNumber}]);
             
             disp('mean walkDMC_healthy=');
             mean(walkDMC_healthy_all)
             mean(walkDMC_healthy)
             
             disp('mean walkDMC_TBI=');
             mean(walkDMC_TBI_all)
             mean(walkDMC_TBI)
             
             disp(['t-test of walkDMC_TBI vs walkDMC_healthy, Left and Right legs independent:']);
             [h,p,ci,stats] = ttest2(walkDMC_TBI_all,walkDMC_healthy_all) % test for signifcant difference
             
             disp(['t-test of walkDMC_TBI vs walkDMC_healthy, Left and Right legs Averaged:']);
             [h,p,ci,stats] = ttest2(walkDMC_TBI_avg,walkDMC_healthy_avg) % test for signifcant difference
             
             disp(['paired t-test of walkDMC_TBI left vs right:']);
             [h,p,ci,stats] = ttest(walkDMC_TBI(:,1), walkDMC_TBI(:,2)) % test for signifcant difference
             
             disp(['paired t-test of walkDMC_healthy left vs right:']);
             [h,p,ci,stats] = ttest(walkDMC_healthy(:,1), walkDMC_healthy(:,2)) % test for signifcant difference
             
         end
     end
    
end