classdef coactivation
    % Filename: coactivation.m
    % Author:   Samuel Acuna
    % Date:     10 Jul 2017
    % Description:
    % This class holds static coactivation analysis functions
    % The trials must already in the workspace.
    %
    % Example Usage:
    %       tbiStudy.coactivation.winter(tr, interval) %returns winter's coactivation index
    %
    % ABBREVIATIONS:
    % ci = coactivation index
       
    % MUSCLE PAIRS:
    % VLMH = medial hamstring, vastus lateralis
    % RFMH = rectus femoris, vastus lateralis
    % MGTA = medial gastroc, tibialis anterior
    % SLTA = soleus, tibialis anterior

    methods (Static)
        function ci = winter(tr,interval)
            % WINTER'S CO-CONTRACTION INDEX
            % (see Winter's Biomechanics Book, eq 6.13)
            
            col = tbiStudy.constants.col; % get column values, just makes it easier to keep track

            if nargin < 2
                interval = 'stride'; % default interval
            end
            assert(length(tr.emgData)==101,'The EMG vector is not 101 data points long, this function must be updated to match');
            
            % INTERVAL
            switch interval
                case 'stride'        
                    t = 1:101;  % 0-100 % of the gait cycle
                case 'stance'
                    t = 1:61;   % 0-60 % of the gait cycle
                case 'swing'
                    t = 61:101; % 60-100 % of the gait cycle
                otherwise
                    error('unknown interval specified. use stride, stance, or swing');
            end
            emg = tr.emgData(t,:); % only look at data in the interval
            
            % MINIMUM BETWEEN CURVES
            lVLMH_min = min([emg(:,col.lVL) emg(:,col.lMH)],[],2); %left leg
            rVLMH_min = min([emg(:,col.rVL) emg(:,col.rMH)],[],2); %right leg
            lRFMH_min = min([emg(:,col.lRF) emg(:,col.lMH)],[],2);
            rRFMH_min = min([emg(:,col.rRF) emg(:,col.rMH)],[],2);
            lMGTA_min = min([emg(:,col.lMG) emg(:,col.lTA)],[],2);
            rMGTA_min = min([emg(:,col.rMG) emg(:,col.rTA)],[],2);
            lSLTA_min = min([emg(:,col.lSL) emg(:,col.lTA)],[],2);
            rSLTA_min = min([emg(:,col.rSL) emg(:,col.rTA)],[],2);
                        
            % AREA OF INTERSECTING OVERLAP (the minimums)
            lVLMH_areaOverlap = trapz(t,lVLMH_min);
            rVLMH_areaOverlap = trapz(t,rVLMH_min);
            lRFMH_areaOverlap = trapz(t,lRFMH_min);
            rRFMH_areaOverlap = trapz(t,rRFMH_min);
            lMGTA_areaOverlap = trapz(t,lMGTA_min);
            rMGTA_areaOverlap = trapz(t,rMGTA_min);
            lSLTA_areaOverlap = trapz(t,lSLTA_min);
            rSLTA_areaOverlap = trapz(t,rSLTA_min);
                        
            % AREA OF ADDITIVE OVERLAP (area A + area B) 
            lVLMH_areaAdditive = trapz(t,emg(:,col.lVL)) + trapz(t,emg(:,col.lMH));
            rVLMH_areaAdditive = trapz(t,emg(:,col.rVL)) + trapz(t,emg(:,col.rMH));
            lRFMH_areaAdditive = trapz(t,emg(:,col.lRF)) + trapz(t,emg(:,col.lMH));
            rRFMH_areaAdditive = trapz(t,emg(:,col.rRF)) + trapz(t,emg(:,col.rMH));
            lMGTA_areaAdditive = trapz(t,emg(:,col.lMG)) + trapz(t,emg(:,col.lTA));
            rMGTA_areaAdditive = trapz(t,emg(:,col.rMG)) + trapz(t,emg(:,col.rTA));
            lSLTA_areaAdditive = trapz(t,emg(:,col.lSL)) + trapz(t,emg(:,col.lTA));
            rSLTA_areaAdditive = trapz(t,emg(:,col.rSL)) + trapz(t,emg(:,col.rTA));
            
            
            % WINTER'S INDEX
            % cocon = 2 * (Common area A & B)/(Area A + Area B) * 100%
            ci.lVLMH_winter = 2 * lVLMH_areaOverlap / lVLMH_areaAdditive * 100;
            ci.rVLMH_winter = 2 * rVLMH_areaOverlap / rVLMH_areaAdditive * 100;
            ci.lRFMH_winter = 2 * lRFMH_areaOverlap / lRFMH_areaAdditive * 100;
            ci.rRFMH_winter = 2 * rRFMH_areaOverlap / rRFMH_areaAdditive * 100;
            ci.lMGTA_winter = 2 * lMGTA_areaOverlap / lMGTA_areaAdditive * 100;
            ci.rMGTA_winter = 2 * rMGTA_areaOverlap / rMGTA_areaAdditive * 100;
            ci.lSLTA_winter = 2 * lSLTA_areaOverlap / lSLTA_areaAdditive * 100;
            ci.rSLTA_winter = 2 * rSLTA_areaOverlap / rSLTA_areaAdditive * 100;
            
            
            % COMBINE [left leg, right leg]
            ci.VLMH_winter = mean([ci.lVLMH_winter ci.rVLMH_winter]);
            ci.RFMH_winter = mean([ci.lRFMH_winter ci.rRFMH_winter]);
            ci.MGTA_winter = mean([ci.lMGTA_winter ci.rMGTA_winter]);
            ci.SLTA_winter = mean([ci.lSLTA_winter ci.rSLTA_winter]);
            
        end
        function ci = rudolph(tr,interval)
            % RUDOLPH'S CO-CONTRACTION INDEX
            % (Schmitt, L.C., Rudolph, K.S., 2008. Muscle stabilization
            % strategies in people with medial knee osteoarthritis: The effect
            % of instability. J. Orthop. Res. 26, 1180?1185. doi:10.1002/jor.20619)
            %
            % CI = average of curve: [ EMG_min / EMG_max * (EMG A + EMG B) ]
            
            col = tbiStudy.constants.col; % get column values, just makes it easier to keep track

            if nargin < 2
                interval = 'stride'; % default interval
            end
            assert(length(tr.emgData)==101,'The EMG vector is not 101 data points long, this function must be updated to match');
            
            % INTERVAL
            switch interval
                case 'stride'        
                    t = 1:101;  % 0-100 % of the gait cycle
                case 'stance'
                    t = 1:61;   % 0-60 % of the gait cycle
                case 'swing'
                    t = 61:101; % 60-100 % of the gait cycle
                otherwise
                    error('unknown interval specified. use stride, stance, or swing');
            end
            emg = tr.emgData(t,:); % only look at data in the interval
            
            % MINIMUM BETWEEN CURVES
            lVLMH_min = min([emg(:,col.lVL) emg(:,col.lMH)],[],2); %left leg
            rVLMH_min = min([emg(:,col.rVL) emg(:,col.rMH)],[],2); %right leg
            lRFMH_min = min([emg(:,col.lRF) emg(:,col.lMH)],[],2);
            rRFMH_min = min([emg(:,col.rRF) emg(:,col.rMH)],[],2);
            lMGTA_min = min([emg(:,col.lMG) emg(:,col.lTA)],[],2);
            rMGTA_min = min([emg(:,col.rMG) emg(:,col.rTA)],[],2);
            lSLTA_min = min([emg(:,col.lSL) emg(:,col.lTA)],[],2);
            rSLTA_min = min([emg(:,col.rSL) emg(:,col.rTA)],[],2);
            
            % MAXIMUM BETWEEN CURVES
            lVLMH_max = max([emg(:,col.lVL) emg(:,col.lMH)],[],2);
            rVLMH_max = max([emg(:,col.rVL) emg(:,col.rMH)],[],2);
            lRFMH_max = max([emg(:,col.lRF) emg(:,col.lMH)],[],2);
            rRFMH_max = max([emg(:,col.rRF) emg(:,col.rMH)],[],2);
            lMGTA_max = max([emg(:,col.lMG) emg(:,col.lTA)],[],2);
            rMGTA_max = max([emg(:,col.rMG) emg(:,col.rTA)],[],2);
            lSLTA_max = max([emg(:,col.lSL) emg(:,col.lTA)],[],2);
            rSLTA_max = max([emg(:,col.rSL) emg(:,col.rTA)],[],2);
            
            % SUM BETWEEN CURVES
            lVLMH_sum = emg(:,col.lVL) + emg(:,col.lMH); 
            rVLMH_sum = emg(:,col.rVL) + emg(:,col.rMH); 
            lRFMH_sum = emg(:,col.lRF) + emg(:,col.lMH); 
            rRFMH_sum = emg(:,col.rRF) + emg(:,col.rMH); 
            lMGTA_sum = emg(:,col.lMG) + emg(:,col.lTA); 
            rMGTA_sum = emg(:,col.rMG) + emg(:,col.rTA); 
            lSLTA_sum = emg(:,col.lSL) + emg(:,col.lTA); 
            rSLTA_sum = emg(:,col.rSL) + emg(:,col.rTA); 
            
            % RUDOLPH'S CO-CONTRACTION INDEX
            % CI = average of curve: [ EMG_min / EMG_max * (EMG A + EMG B) ]
            curve = lVLMH_min ./ lVLMH_max .* lVLMH_sum; ci.lVLMH_rudolph = mean(curve);
            curve = rVLMH_min ./ rVLMH_max .* rVLMH_sum; ci.rVLMH_rudolph = mean(curve);
            curve = lRFMH_min ./ lRFMH_max .* lRFMH_sum; ci.lRFMH_rudolph = mean(curve);
            curve = rRFMH_min ./ rRFMH_max .* rRFMH_sum; ci.rRFMH_rudolph = mean(curve);
            curve = lMGTA_min ./ lMGTA_max .* lMGTA_sum; ci.lMGTA_rudolph = mean(curve);
            curve = rMGTA_min ./ rMGTA_max .* rMGTA_sum; ci.rMGTA_rudolph = mean(curve);
            curve = lSLTA_min ./ lSLTA_max .* lSLTA_sum; ci.lSLTA_rudolph = mean(curve);
            curve = rSLTA_min ./ rSLTA_max .* rSLTA_sum; ci.rSLTA_rudolph = mean(curve);
            
            % COMBINE [left leg, right leg]
            ci.VLMH_rudolph = mean([ci.lVLMH_rudolph ci.rVLMH_rudolph]);
            ci.RFMH_rudolph = mean([ci.lRFMH_rudolph ci.rRFMH_rudolph]);
            ci.MGTA_rudolph = mean([ci.lMGTA_rudolph ci.rMGTA_rudolph]);
            ci.SLTA_rudolph = mean([ci.lSLTA_rudolph ci.rSLTA_rudolph]);
        end
        function [ci_winter ci_rudolph ci_winter_healthy ci_rudolph_healthy] = baseline(interval)
            if nargin < 1
                interval = 'stride';
            end
            
            % 1. retrieve emg trials from database, using default values
            sqlquery = ['select trials.* from trials, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and trialType = "baseline" '... % default trialType
                'and (testPoint = 1)']; % default Pre/Post window
            tr = tbiStudy.load.trials(sqlquery);
            [rows ~] = size(tr); % total rows
            
            % 2. find coactivation for each subject
            for i = 1:rows
                ci_winter(i) = tbiStudy.coactivation.winter(tr(i),interval);
                ci_rudolph(i) = tbiStudy.coactivation.rudolph(tr(i),interval);
            end
            
            % 3. compare to healthy coactivation
            sqlquery = ['select trials_healthy.* from trials_healthy '...
                'where trialType = "treadmill22" ']; % default trialType
            hy = tbiStudy.load.trials(sqlquery);
            [rows ~] = size(hy); % total rows
            
            for i = 1:rows
                ci_winter_healthy(i) = tbiStudy.coactivation.winter(hy(i),interval);
                ci_rudolph_healthy(i) = tbiStudy.coactivation.rudolph(hy(i),interval);
            end            
        end
        function plot
            % run baseline function first for now
            %% winter
            figure
            edges = [0:5:100]; ylimit = 15;
            subplot(2,4,1)
            histogram([ci_winter(:).VLMH_winter], edges); title('VLMH winter');ylim([0 ylimit]);
            subplot(2,4,2)
            histogram([ci_winter(:).RFMH_winter], edges); title('RFMH winter');ylim([0 ylimit]);
            subplot(2,4,3)
            histogram([ci_winter(:).MGTA_winter], edges); title('MGTA winter');ylim([0 ylimit]);
            subplot(2,4,4)
            histogram([ci_winter(:).SLTA_winter], edges); title('SLTA winter');ylim([0 ylimit]);
            
            subplot(2,4,5)
            histogram([ci_winter_healthy(:).VLMH_winter], edges); title('VLMH winter healthy');ylim([0 ylimit]);
            subplot(2,4,6)
            histogram([ci_winter_healthy(:).RFMH_winter], edges); title('RFMH winter healthy');ylim([0 ylimit]);
            subplot(2,4,7)
            histogram([ci_winter_healthy(:).MGTA_winter], edges); title('MGTA winter healthy');ylim([0 ylimit]);
            subplot(2,4,8)
            histogram([ci_winter_healthy(:).SLTA_winter], edges); title('SLTA winter healthy');ylim([0 ylimit]);
            
            %%
            figure
            edges = [0:5:100]; ylimit = 100;
            subplot(2,4,1)
            boxplot([ci_winter(:).VLMH_winter]); title('VLMH winter');ylim([0 ylimit]);
            subplot(2,4,2)
            boxplot([ci_winter(:).RFMH_winter]); title('RFMH winter');ylim([0 ylimit]);
            subplot(2,4,3)
            boxplot([ci_winter(:).MGTA_winter]); title('MGTA winter');ylim([0 ylimit]);
            subplot(2,4,4)
            boxplot([ci_winter(:).SLTA_winter]); title('SLTA winter');ylim([0 ylimit]);
            
            subplot(2,4,5)
            boxplot([ci_winter_healthy(:).VLMH_winter]); title('VLMH winter healthy');ylim([0 ylimit]);
            subplot(2,4,6)
            boxplot([ci_winter_healthy(:).RFMH_winter]); title('RFMH winter healthy');ylim([0 ylimit]);
            subplot(2,4,7)
            boxplot([ci_winter_healthy(:).MGTA_winter]); title('MGTA winter healthy');ylim([0 ylimit]);
            subplot(2,4,8)
            boxplot([ci_winter_healthy(:).SLTA_winter]); title('SLTA winter healthy');ylim([0 ylimit]);
            
            %% rudolph
            figure
            edges = [0:.2:2]; ylimit = 20;
            subplot(2,4,1)
            histogram([ci_rudolph(:).VLMH_rudolph], edges); title('VLMH rudolph');ylim([0 ylimit]);
            subplot(2,4,2)
            histogram([ci_rudolph(:).RFMH_rudolph], edges); title('RFMH rudolph');ylim([0 ylimit]);
            subplot(2,4,3)
            histogram([ci_rudolph(:).MGTA_rudolph], edges); title('MGTA rudolph');ylim([0 ylimit]);
            subplot(2,4,4)
            histogram([ci_rudolph(:).SLTA_rudolph], edges); title('SLTA rudolph');ylim([0 ylimit]);
            
            subplot(2,4,5)
            histogram([ci_rudolph_healthy(:).VLMH_rudolph], edges); title('VLMH rudolph healthy');ylim([0 ylimit]);
            subplot(2,4,6)
            histogram([ci_rudolph_healthy(:).RFMH_rudolph], edges); title('RFMH rudolph healthy');ylim([0 ylimit]);
            subplot(2,4,7)
            histogram([ci_rudolph_healthy(:).MGTA_rudolph], edges); title('MGTA rudolph healthy');ylim([0 ylimit]);
            subplot(2,4,8)
            histogram([ci_rudolph_healthy(:).SLTA_rudolph], edges); title('SLTA rudolph healthy');ylim([0 ylimit]);
            
            %%
            figure
            ylimit = 2;
            subplot(2,4,1)
            boxplot([ci_rudolph(:).VLMH_rudolph]); title('VLMH rudolph');ylim([0 ylimit]);
            subplot(2,4,2)
            boxplot([ci_rudolph(:).RFMH_rudolph]); title('RFMH rudolph');ylim([0 ylimit]);
            subplot(2,4,3)
            boxplot([ci_rudolph(:).MGTA_rudolph]); title('MGTA rudolph');ylim([0 ylimit]);
            subplot(2,4,4)
            boxplot([ci_rudolph(:).SLTA_rudolph]); title('SLTA rudolph');ylim([0 ylimit]);
            
            subplot(2,4,5)
            boxplot([ci_rudolph_healthy(:).VLMH_rudolph]); title('VLMH rudolph healthy');ylim([0 ylimit]);
            subplot(2,4,6)
            boxplot([ci_rudolph_healthy(:).RFMH_rudolph]); title('RFMH rudolph healthy');ylim([0 ylimit]);
            subplot(2,4,7)
            boxplot([ci_rudolph_healthy(:).MGTA_rudolph]); title('MGTA rudolph healthy');ylim([0 ylimit]);
            subplot(2,4,8)
            boxplot([ci_rudolph_healthy(:).SLTA_rudolph]); title('SLTA rudolph healthy');ylim([0 ylimit]);
            
            
            %% end
        end
    end
end