classdef plot
    % Filename: plot.m
    % Author:   Samuel Acuna
    % Date:     27 May 2016
    % Description:
    % This class holds static functions that plot trials
    % 
    %
    % Example Usage:
    %       tbiStudy.plot.single(tr(1))           % plots one trial from workspace
    %       tbiStudy.plot.trial(1,1,'baseline')   % plot trial: subj 1, testpoint 1, baseline trial 
    %       tbiStudy.plot.testPoint(1,1)          % plot all trials in subj 1, testpoint 1
    %       tbiStudy.plot.trialType(1,'baseline') % plot baseline trials for subj 1, all testPoints
    
    properties (Constant, Access = 'public')
        % plotting parameters
        emgPlotYAxisLimits = [0, 4];
        emgPlotXAxisLabel = '' % 'Percent of Gait Cycle';
        emgPlotColors = {rgb('Blue') rgb('Red') rgb('ForestGreen') rgb('Yellow') rgb('Tomato')}; % the order of colors plotted, using rgb (Author: Kristj�n J�nasson, Dept. of Computer Science, University of Iceland (jonasson@hi.is). June 2009.
        emgAreaColors = {rgb('Gray') };
        legendPosition = [.4 .001 .2 .1] ; % normalized to figure : left, bottom, width, height
        transparentErrorBars = [1]; % 1 = transparent, 0 = opaque
        showErrorBars = [1]; % 1 = show them, 0 = hide
        dgiPlotYAxisLimits = [0, 1]; %[-.2,1];
        dgiPlotXAxisLimits = [0,25];
        sotPlotYAxisLimits = [0, 1]; %[-.2,1];
        sotPlotXAxisLimits = [0, 100];
        sixmwtPlotYAxisLimits = [0, 1]; %[-.2,1];
        sixmwtPlotXAxisLimits = [100, 550]; % THIS MIGHT CHANGE
        activationPlotLimits = [0 100 0 2]; % THIS MIGHT CHANGE
        figureSize = {[5 5 20 10]} % units are centimeters, make sure figure handle knows that
    end
    
    methods (Static)
        function single(tr,plotColorIndex) % base function: plot a single emg collection, all muscles
            assert(nargin >= 1, 'Must input a trial structure.');
            assert(all(size(tr) == [1 1]), 'Must only provide one trial structure at a time. size(tr) must be [1 1];');
            if nargin == 1
                plotColorIndex = 1;
            end
            
            for j=1:6 % RIGHT LEG
                subplot(6,2,2*j); % plots on right half of figure
                hold on
                if tbiStudy.plot.showErrorBars
                    shadedErrorBar([0:100]',tr.emgData(:,j),tr.emgStd(:,j),{'color',tbiStudy.plot.emgPlotColors{plotColorIndex}},tbiStudy.plot.transparentErrorBars);
                end
                plot([0:100]',tr.emgData(:,j),'color',tbiStudy.plot.emgPlotColors{plotColorIndex});
                hold off
                title(tr.emgLabel(j));
                ylim(tbiStudy.plot.emgPlotYAxisLimits);
                xlabel(tbiStudy.plot.emgPlotXAxisLabel);
            end
            for j=1:6 % LEFT LEG
                subplot(6,2,2*j-1); % plots on left half of figure
                hold on
                if tbiStudy.plot.showErrorBars
                    shadedErrorBar([0:100]',tr.emgData(:,6+j),tr.emgStd(:,6+j),{'color',tbiStudy.plot.emgPlotColors{plotColorIndex}},tbiStudy.plot.transparentErrorBars);
                end
                plot([0:100]',tr.emgData(:,6+j),'color',tbiStudy.plot.emgPlotColors{plotColorIndex});
                hold off
                title(tr.emgLabel(6+j));
                ylim(tbiStudy.plot.emgPlotYAxisLimits);
                xlabel(tbiStudy.plot.emgPlotXAxisLabel);
            end
        end
        function multiple(tr) % plot multiple trials together
            % example: tbiStudy.plot.multiple(tr(1:2)), where tr is a trial
            % structure in the matlab workspace
            assert(nargin == 1, 'Must input a vector of trial structure.');
            [l w] = size(tr);
            assert((w == 1), 'Must provide vector of trial structure. size(tr) must be [n 1], where n >= 1');
            assert((l <= 5), 'Limited to plot only 5 instances on 1 plot.');
            for i = 1:l  % wrap to single plot function
                tbiStudy.plot.single(tr(i),i); % new color for each plot
            end
        end
        function trial(subject_id,testPoint,trialType) % plot a specified trial
            % example: tbiStudy.plot.trial(1,1,'baseline')
            
            % retrieve from database
            sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and testPoint = ' num2str(testPoint) ' and trialType = "' trialType '"'];
            tr = tbiStudy.load.trials(sqlquery);
            
            % create figure
            titleName = ['TBI-' num2str(subject_id) ', TestPoint ' num2str(testPoint) ', ' trialType];
            figure('Name',titleName);
            suptitle(titleName);
            
            % wrapper to single plot
            tbiStudy.plot.single(tr);
        end
        function testPoint(subject_id,testPoint) % plot all trials in a testPoint
            % this function plots the emg gait cycle data for array of
            % trials in test point.
            % example: tbiStudy.plot.testPoint(1,1)
            
            % retrieve from database
            sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and testPoint = ' num2str(testPoint)];
            tr = tbiStudy.load.trials(sqlquery);
            
            % create figure
            titleName = ['TBI-' num2str(subject_id) ', TestPoint ' num2str(testPoint) ];
            figure('Name',titleName);
            suptitle(titleName);
            
            % wrapper to multiple plot
            tbiStudy.plot.multiple(tr);
            
            % create legend
            tbiStudy.plot.legend({tr(:).trialType});
        end
        function trialType(subject_id,trialType) % plot across testPoints, same trialType
            % example: tbiStudy.plot.trialType(1,'baseline')
            
            % retrieve from database
            sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and trialType = "' trialType '"'];
            if strcmp(trialType,'preferred'); 
                sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and (trialType = "preferred" or (testPoint = 1 and trialType = "baseline"))'];
            end
            tr = tbiStudy.load.trials(sqlquery);
            
            % create figure
            titleName = ['TBI-' num2str(subject_id) ', testPoints ' num2str([tr(:).testPoint]) ', ' trialType];
            figure('Name',titleName);
            suptitle(titleName);
            
            % wrapper to multiple plot
            tbiStudy.plot.multiple(tr);
            
            % create legend
            labels = strcat('TP ', cellstr(num2str([tr(:).testPoint]')));
            tbiStudy.plot.legend(labels);
        end
        function compareHealthy(subject_id,testPoint,trialType) % single trial plot vs healthy emg
            % FOR NOW, USeS  AN AGGREGATE HEALTHY TRIAL  AS SPECIFIED IN
            % tbiStudy.constants.healthy, BUT IN FUTURE, WILL HAVE A
            % DATABASE OF HEALTHY SUBJECTS, SO THIS WILL BE UPDATED TO
            % REFLECT THAT
            
            % specify defaults
            if nargin < 3
                trialType = 'baseline';
            end
            if nargin < 2
                testPoint = 1;
            end
            
            % retrieve one trial from database
            if strcmp(trialType,'preferred') && (testPoint == 1); trialType = 'baseline'; end
            sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and testPoint = ' num2str(testPoint) ' and trialType = "' trialType '"'];
            tr = tbiStudy.load.trials(sqlquery);
            
            assert(length(tr) == 1, 'Should only be specifying one specific trial');
            
            % append healthy subject to working trial
            load(tbiStudy.constants.healthy); % healthy subject has the workspace variable 'hy'
            tr = [tr; hy];
            
            % create figure
            titleName = ['TBI-' num2str(subject_id) ', testPoint ' num2str(testPoint) ', ' trialType ' VS Healthy'];
            figure('Name',titleName);
            suptitle(titleName);
            
            % wrapper to multiple plot
            tbiStudy.plot.multiple(tr);
            
            % create legend
            labels{1} = ['tbi' num2str(tr(1).subject_id)];
            labels{2} = 'healthy';
            tbiStudy.plot.legend(labels);
        end
        function compareHealthyPrePost(subject_id) % plots pre/post emg, and healthy
            % retrieve from database, using default values
            sqlquery = ['select trials.* from trials, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (totalNumTestPoints > 1) '...
                'and (trials.subject_id = ' num2str(subject_id) ') '...
                'and trialType = "baseline" '... % default trialType
                'and (testPoint = 1 or testPoint = 2)']; % default Pre/Post window
            tr = tbiStudy.load.trials(sqlquery);
            % observe that the first row is PRE and the second row is POST
           
            % append healthy subject to working trial
            load(tbiStudy.constants.healthy); % healthy subject has the workspace variable 'hy'
            tr = [tr; hy];
            
            
            % create figure
            figure('Name','Compare Healthy Pre-Post')
            set(gcf,'color','w');
            
            for j=1:6 % RIGHT LEG
                subplot(6,2,2*j); % plots on right half of figure
                hold on
                %area([0:100]',tr(3).emgData(:,j),'LineStyle','none','FaceColor', tbiStudy.plot.emgAreaColors{1}); % healthy
                shadedErrorBar([0:100]',tr(3).emgData(:,j),tr(3).emgStd(:,j),{'color',tbiStudy.plot.emgAreaColors{1}},tbiStudy.plot.transparentErrorBars); % healthy
                plot([0:100]',tr(1).emgData(:,j),'LineStyle','--','color','k','LineWidth',1); % pre
                plot([0:100]',tr(2).emgData(:,j),'color','k','LineWidth',1); % post
                hold off
                title(tr(3).emgLabel(j));
                ylim(tbiStudy.plot.emgPlotYAxisLimits);
                xlabel(tbiStudy.plot.emgPlotXAxisLabel);
            end
            for j=1:6 % LEFT LEG
                subplot(6,2,2*j-1); % plots on left half of figure
                hold on
                %area([0:100]',tr(3).emgData(:,6+j),'LineStyle','none','FaceColor',tbiStudy.plot.emgAreaColors{1});
                shadedErrorBar([0:100]',tr(3).emgData(:,6+j),tr(3).emgStd(:,6+j),{'color',tbiStudy.plot.emgAreaColors{1}},tbiStudy.plot.transparentErrorBars); % healthy
                plot([0:100]',tr(1).emgData(:,6+j),'LineStyle','--','color','k','LineWidth',1);
                plot([0:100]',tr(2).emgData(:,6+j),'color','k','LineWidth',1);
                hold off
                title(tr(3).emgLabel(6+j));
                ylim(tbiStudy.plot.emgPlotYAxisLimits);
                xlabel(tbiStudy.plot.emgPlotXAxisLabel);
            end 
            
            % create legend
            tbiStudy.plot.legend_prepost(1);
            
            % title 
            suptitle([' Pre-Post TBI-' num2str(subject_id) '. Compared to Healthy ']);
        end
        function compareHealthyPrePost_muscle(subject_id,muscleNumber) % plots pre/post emg, and healthy, for just one muscle
            
            if (nargin == 1)
                muscleNumber = 2; % left gastroc
            end
            
            % retrieve from database, using default values
            sqlquery = ['select trials.* from trials, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (totalNumTestPoints > 1) '...
                'and (trials.subject_id = ' num2str(subject_id) ') '...
                'and trialType = "baseline" '... % default trialType
                'and (testPoint = 1 or testPoint = 2)']; % default Pre/Post window
            tr = tbiStudy.load.trials(sqlquery);
            % observe that the first row is PRE and the second row is POST
           
            % append healthy subject to working trial
            load(tbiStudy.constants.healthy); % healthy subject has the workspace variable 'hy'
            tr = [tr; hy];
            
            % label 
            muscleName = tr(3).emgLabel{muscleNumber};
                        
            % create figure
            figHandle = figure('Name',muscleName);
            set(figHandle,'color','w','units','centimeters','Position',tbiStudy.plot.figureSize{1});
            
            hold on
            shadedErrorBar([0:100]',tr(3).emgData(:,muscleNumber),tr(3).emgStd(:,muscleNumber),{'color',tbiStudy.plot.emgAreaColors{1}},tbiStudy.plot.transparentErrorBars); % healthy
            plot([0:100]',tr(1).emgData(:,muscleNumber),'LineStyle','--','color','k','LineWidth',2); % pre
            plot([0:100]',tr(2).emgData(:,muscleNumber),'color','k','LineWidth',2); % post
            hold off
            title(muscleName);
            ylim(tbiStudy.plot.emgPlotYAxisLimits);
            xlabel(tbiStudy.plot.emgPlotXAxisLabel);
            
            % create legend
            tbiStudy.plot.legend_prepost(2);
        end
        function DGIvsHealthy() % plots DGI vs healthy Correlation, pre/post
            
            % calculate correlation, DGI, muscle labels
            [DGI,healthyCor,labels] = tbiStudy.correlation.DGIvsHealthy();
            
            % transpose for plotting
            DGI = DGI';
            healthyCor = permute(healthyCor,[2,1,3]); 
            
            % create figure
            figure('Name','DGI vs Correlation')
            set(gcf,'color','w');
            
            
            active = [1
2
1
2
2
1
2
1
1
1
2
2
1
2
2
1
1
2
2
1
1
2
2
1
1]
            
            for j = 1:6 % right leg
                subplot(6,2,2*j);
                hold on
                % first plot the straight line
                plot(DGI,healthyCor(:,:,j),'LineStyle','-','Color','k');
                % Then plot an invisible line, with circles as endpoints
                h = plot(DGI(1,:),healthyCor(1,:,j),'o',DGI(2,:),healthyCor(2,:,j),'o'); % filled and open circle
                % set first circle as filled
                set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
                % set second circle as empty
                set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
                
                title(labels(j))
                ylim(tbiStudy.plot.dgiPlotYAxisLimits);
                xlim(tbiStudy.plot.dgiPlotXAxisLimits);
                
%                 for q = 1:25
%                     if active(q)==1; COLOR = 'r';
%                     else COLOR = 'k';
%                     end
%                 plot(DGI,healthyCor(:,q,j),'LineStyle','-','Color',COLOR);
%                 end
                hold off
                
            end
            
            
            for j = 1:6 % left leg
                subplot(6,2,2*j-1);
                hold on
                plot(DGI,healthyCor(:,:,6+j),'LineStyle','-','Color','k');
                h = plot(DGI(1,:),healthyCor(1,:,6+j),'o',DGI(2,:),healthyCor(2,:,6+j),'o');
                set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
                set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
                hold off
                title(labels(6+j))
                ylim(tbiStudy.plot.dgiPlotYAxisLimits);
                xlim(tbiStudy.plot.dgiPlotXAxisLimits);
            end
            
            % 7. create custom legend
            tbiStudy.plot.legend_prepost(3);
            
            % create title that goes over all the subplots
            suptitle(['DGI vs Healthy Correlation']);

        end
        function DGIvsHealthy_muscle(muscleNumber,labelSubjectNumber) % plots DGI vs healthy Correlation, pre/post, one muscle group
            % inputs:
            % muscleNumber = one value of [1:6], referring to leg muscles
            % labelSubjectNumber = optional. If you want to label the lines with subject number set this value to 1
            if nargin == 1
            labelSubjectNumber = 0;
            end

            % calcululate DGI and healthy correlation data
            %
            % NOTE: Since looking at just a single muscle, need to specify
            % whether looking at right leg, left leg, or average of both.
            % For most cases, use the average of both, but for some trials
            % one of the signals might be bad data. So we neglect those.
            %
            % This is done by referencing the database table
            % trial_useDataFromLeg, where each muscle is specified for
            %           1 = use right leg data
            %           0 = use average leg data
            %          -1 = use left leg data
            [DGI, healthyCor,subject_id] = tbiStudy.correlation.DGIvsHealthy_muscle(muscleNumber);
            
            % transpose data for plotting
            DGI = DGI';
            healthyCor = healthyCor';
            
            % muscle name
            muscleName = tbiStudy.constants.muscles{muscleNumber}; 
            
            % create figure
            figHandle  = figure('Name',['DGI vs Correlation: ' muscleName]);
            set(figHandle,'color','w','units','centimeters','Position',tbiStudy.plot.figureSize{1});
            
            hold on
            % first plot the straight line
            hh = plot(DGI,healthyCor,'LineStyle','-','Color','k');
            % optionally display the subject number next to the name
            % requires label toolbox. http://www.mathworks.com/matlabcentral/fileexchange/47421-label/content/label_documentation/html/label_documentation.html
            if labelSubjectNumber == 1
                for k = 1:length(DGI)
                    label(hh(k),num2str(subject_id(k)),'location','left');
                end
            end
            
            % Then plot an invisible line, with circles as endpoints
            h = plot(DGI(1,:),healthyCor(1,:),'o',DGI(2,:),healthyCor(2,:),'o'); % filled and open circle
            % set first circle as filled
            set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
            % set second circle as empty
            set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
            hold off
            % title(muscleName)
            ylim(tbiStudy.plot.dgiPlotYAxisLimits);
            xlim(tbiStudy.plot.dgiPlotXAxisLimits);
            
            % axis labels
            ylabel('Correlation Coefficient (R)','FontSize',14);
            xlabel('DGI Score','FontSize',14);

            % 8. create custom legend
            tbiStudy.plot.legend_prepost(4);
            
            % create title that goes over all the subplots
            % suptitle([muscleName ': DGI vs Healthy Correlation']);
            
        end
        function baseline_DGIvsHealthy() % plots DGI vs healthy Correlation, baseline
            
            % calculate correlation, DGI, muscle labels
            [DGI,healthyCor,labels] = tbiStudy.correlation.baseline_DGIvsHealthy();

            % create figure
            figure('Name','DGI vs Baseline Correlation')
            set(gcf,'color','w');
            
            for j = 1:6 % right leg
                subplot(6,2,2*j);
                hold on
                plot(DGI,healthyCor(:,j),'ko');
                lsline; % least squares line
                hold off
                title(labels(j))
                ylim(tbiStudy.plot.dgiPlotYAxisLimits);
                xlim(tbiStudy.plot.dgiPlotXAxisLimits);
            end
            for j = 1:6 % left leg
                subplot(6,2,2*j-1);
                hold on
                plot(DGI,healthyCor(:,6+j),'ko');
                lsline; % least squares line
                hold off
                title(labels(6+j))
                ylim(tbiStudy.plot.dgiPlotYAxisLimits);
                xlim(tbiStudy.plot.dgiPlotXAxisLimits);
            end
            
            % 7. create custom legend
            %tbiStudy.plot.legend_prepost(3);
            
            % create title that goes over all the subplots
            suptitle(['DGI vs Healthy Baseline Correlation']);
        end
        function baseline_SOTvsHealthy() % plots DGI vs healthy Correlation, baseline
            
            % calculate correlation, DGI, muscle labels
            [SOT,healthyCor,labels] = tbiStudy.correlation.baseline_SOTvsHealthy();

            % create figure
            figure('Name','SOT vs Baseline Correlation')
            set(gcf,'color','w');
            
            for j = 1:6 % right leg
                subplot(6,2,2*j);
                hold on
                plot(SOT,healthyCor(:,j),'ko');
                lsline; % least squares line
                hold off
                title(labels(j))
                ylim(tbiStudy.plot.sotPlotYAxisLimits);
                xlim(tbiStudy.plot.sotPlotXAxisLimits);
            end
            for j = 1:6 % left leg
                subplot(6,2,2*j-1);
                hold on
                plot(SOT,healthyCor(:,6+j),'ko');
                lsline; % least squares line
                hold off
                title(labels(6+j))
                ylim(tbiStudy.plot.sotPlotYAxisLimits);
                xlim(tbiStudy.plot.sotPlotXAxisLimits);
            end
            
            % 7. create custom legend
            %tbiStudy.plot.legend_prepost(3);
            
            % create title that goes over all the subplots
            suptitle(['SOT vs Healthy Baseline Correlation']);
        end
        function baseline_sixMWTvsHealthy() % plots DGI vs healthy Correlation, baseline
            
            % calculate correlation, DGI, muscle labels
            [sixMWT,healthyCor,labels] = tbiStudy.correlation.baseline_sixMWTvsHealthy();

            % create figure
            figure('Name','6MWT vs Baseline Correlation')
            set(gcf,'color','w');
            
            for j = 1:6 % right leg
                subplot(6,2,2*j);
                hold on
                plot(sixMWT,healthyCor(:,j),'ko');
                lsline; % least squares line
                hold off
                title(labels(j))
                ylim(tbiStudy.plot.sixmwtPlotYAxisLimits);
                xlim(tbiStudy.plot.sixmwtPlotXAxisLimits);
            end
            for j = 1:6 % left leg
                subplot(6,2,2*j-1);
                hold on
                plot(sixMWT,healthyCor(:,6+j),'ko');
                lsline; % least squares line
                hold off
                title(labels(6+j))
                ylim(tbiStudy.plot.sixmwtPlotYAxisLimits);
                xlim(tbiStudy.plot.sixmwtPlotXAxisLimits);
            end
            
            % 7. create custom legend
            %tbiStudy.plot.legend_prepost(3);
            
            % create title that goes over all the subplots
            suptitle(['6MWT vs Healthy Baseline Correlation']);
        end
        function baseline_vsHealthy() % plots metrics vs average healthy Correlation, baseline
            fSize = 14;
            
            % calculate correlations
            [DGI, SOT, sixMWT, cor, DGIcor, SOTcor, sixMWTcor, labels] = tbiStudy.correlation.baseline_vsHealthy();
    
            % DGI vs Average Healthy Baseline Correlation
            figure('Name','DGI vs Average Healthy Baseline  Correlation')
            set(gcf,'color','w');
            plot(DGI,cor,'ko');
            lsline; % least squares line
            ylim(tbiStudy.plot.dgiPlotYAxisLimits);
            xlim(tbiStudy.plot.dgiPlotXAxisLimits);
            [x, y] = tbiStudy.plot.textCoords(tbiStudy.plot.dgiPlotXAxisLimits, tbiStudy.plot.dgiPlotYAxisLimits,0.1,0.9);
            text(x,y,['R = ' num2str(round(DGIcor,2))],'FontSize',fSize);
            %title(['DGI vs Average Healthy Baseline Correlation']);
            title(['DGI vs EMG Correlation'],'FontSize',fSize);
            ylabel('Avg. EMG Correlation (R)','FontSize',fSize);
            xlabel('DGI Score','FontSize',fSize);
            set(gca,'FontSize',fSize,'FontWeight','normal')
            
            % SOT vs Average Healthy Baseline Correlation
            figure('Name','SOT vs Average Healthy Baseline  Correlation')
            set(gcf,'color','w');
            plot(SOT,cor,'ko');
            lsline; % least squares line
            ylim(tbiStudy.plot.sotPlotYAxisLimits);
            xlim(tbiStudy.plot.sotPlotXAxisLimits);
            [x, y] = tbiStudy.plot.textCoords(tbiStudy.plot.sotPlotXAxisLimits, tbiStudy.plot.sotPlotYAxisLimits,0.1,0.9);
            text(x,y,['R = ' num2str(round(SOTcor,2))],'FontSize',fSize);
            %title(['SOT vs Average Healthy Baseline Correlation']);
            title(['SOT vs EMG Correlation'],'FontSize',fSize);
            ylabel('Avg. EMG Correlation (R)','FontSize',fSize);
            xlabel('SOT Score','FontSize',fSize);
            set(gca,'FontSize',fSize,'FontWeight','normal')
            
            % sixMWT vs Average Healthy Baseline Correlation
            figure('Name','6MWT vs Average Healthy Baseline  Correlation')
            set(gcf,'color','w');
            plot(sixMWT,cor,'ko');
            lsline; % least squares line
            ylim(tbiStudy.plot.sixmwtPlotYAxisLimits);
            xlim(tbiStudy.plot.sixmwtPlotXAxisLimits);
            [x, y] = tbiStudy.plot.textCoords(tbiStudy.plot.sixmwtPlotXAxisLimits, tbiStudy.plot.sixmwtPlotYAxisLimits,0.1,0.9);
            text(x,y,['R = ' num2str(round(sixMWTcor,2))],'FontSize',fSize);
            %title(['6MWT vs Average Healthy Baseline Correlation']);
            title(['6MWT vs EMG Correlation'],'FontSize',fSize);
            ylabel('Avg. EMG Correlation (R)','FontSize',fSize);
            xlabel('Distance (ft)','FontSize',fSize);
            set(gca,'FontSize',fSize,'FontWeight','normal')
            
        end
        function legend(labels) % append legend to EMG plots
            % create workaround custom legend, not the cleanest, but easier than
            % moving around handles from different classes
            % 
            % after having plotted something here, can create a legend by
            % just supplying the string of labels that accompany the
            % plotting order
            hold on
            for i = 1:length(labels);
                handle(i) = plot(NaN,NaN,'color',tbiStudy.plot.emgPlotColors{i});
            end
            hold off
            set(handle(:),'linewidth',5);
            h = legend(handle(:),labels);
            set(h,'Position',tbiStudy.plot.legendPosition);
            set(h,'Box','on','Orientation','horizontal','FontSize',12);
        end
        function [x, y] = textCoords(xLimits, yLimits,percentX,percentY)
            % find spot to place text on the plot
            x = percentX*(xLimits(2)-xLimits(1)) + xLimits(1);
            y = percentY*(yLimits(2)-yLimits(1)) + yLimits(1);
        end
        function h = legend_prepost(legendNum) % eppend legend to pre-post plots
            
            switch legendNum
                case 1 % pre-post emg legend
                    hold on
                    handle(1) = plot(NaN,NaN,'color',tbiStudy.plot.emgAreaColors{1});
                    handle(2) = plot(NaN,NaN,'LineStyle','--','color','k','LineWidth',1);
                    handle(3) = plot(NaN,NaN,'LineStyle','-','color','k','LineWidth',1);
                    hold off
                    testPoint_strings = {'Healthy','Pre','Post'};
                    set(handle(:),'linewidth',2);
                    h = legend(handle(:),testPoint_strings);
                    set(h,'Position',tbiStudy.plot.legendPosition);
                    set(h,'Box','on','Orientation','horizontal','FontSize',12);
                case 2 % same as 1, but vertical orientation
                    h = tbiStudy.plot.legend_prepost(1);
                    set(h,'Orientation','vertical');
                case 3 % pre-post closed-open circles
                    hold on
                    % plot a fake point, otherwise its a hassle trying to keep track of all the plots looped on top of each other when forming a legend
                    h(1) = plot(NaN,NaN,'o');
                    h(2) = plot(NaN,NaN,'o');
                    hold off
                    set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
                    set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
                    testPoint_strings = {'Pre','Post'};
                    %set(h(:),'linewidth',2);
                    h = legend(h(:),testPoint_strings);
                    set(h,'Position',tbiStudy.plot.legendPosition);
                    set(h,'Box','on','Orientation','horizontal','FontSize',12);
                case 4
                    h = tbiStudy.plot.legend_prepost(3);
                    set(h,'Orientation','vertical');
            
            end
        end
        function ttestMuscle(muscleNumber) % plots aggregate pre-post correlation to healthy
            [cor,h,p] = tbiStudy.stats.ttestMuscle(muscleNumber);
            muscleName = tbiStudy.constants.muscles{muscleNumber};
            
            % create figure
            figure('Name',[muscleName ' Healthy Correlation'])
            set(gcf,'color','w');
            
            bar(mean(cor),'EdgeColor',rgb('Black'),'FaceColor',rgb('Gainsboro'))
            hold on
            errorbar(1:2,mean(cor),std(cor),'LineStyle','none')
            hold off
            xlim([0 3])
            ylim([0 1.2])
            if h == 1 % draw star, if significant difference
                sigstar([1,2])
            end
            Labels = {'Pre', 'Post'};
            set(gca, 'XTick', 1:2, 'XTickLabel', Labels,'fontsize',12);
            title([muscleName ' Healthy Correlation'])
        end
        function ttestDGI() % plots aggregate pre-post correlation to healthy
            [DGI,h,p] = tbiStudy.stats.ttestDGI();

            % create figure
            figure('Name','Pre-Post DGI')
            set(gcf,'color','w');
            
            bar(mean(DGI),'EdgeColor',rgb('Black'),'FaceColor',rgb('Gainsboro'))
            hold on
            errorbar(1:2,mean(DGI),std(DGI),'LineStyle','none')
            hold off
            xlim([0 3])
            ylim([0 24])
            if h == 1 % draw star, if significant difference
                sigstar([1,2])
            end
            Labels = {'Pre', 'Post'};
            set(gca, 'XTick', 1:2, 'XTickLabel', Labels,'fontsize',12);
            title('DGI Scores')
        end
        
        
        function synergy(syn) % plots the W and C of a given synergy analysis
            % INPUT:
            %   syn = a synergy structure generated by tbiStudy.synergies.calcSynergies()
            
            figure('Name','Synergy Weights and Activation')
            n = syn.n;
            nPlots = n+1;
                
            if ~isfield(syn,'rightLeg')
                % plot synergy weights (W)
                subplot(nPlots,1,1); bar(syn.W); xlabel('Muscle Number'); ylabel('W (Synergy Weight)');
                
                % plot activations (C)
                for i = 1:n
                    subplot(nPlots,1,i+1); plot([0:100],syn.C(i,:)); xlabel('Gait Cycle'); ylabel(['C' num2str(i) ' (activation)']);
                end
                
            elseif isfield(syn,'rightLeg')
                % plot synergy weights (W)
                subplot(nPlots,2,1); bar(syn.leftLeg.W); xlabel('Muscle Number'); ylabel('W (Synergy Weight)'); 
                title('Left Leg')
                subplot(nPlots,2,2); bar(syn.rightLeg.W); xlabel('Muscle Number'); ylabel('W (Synergy Weight)');
                title('Right Leg')
                
                % plot activations (C)
                for i = 1:n
                    subplot(nPlots,2,2+2*i-1); plot([0:100],syn.leftLeg.C(i,:)); xlabel('Gait Cycle'); ylabel(['C' num2str(i) ' (activation)']); axis(tbiStudy.plot.activationPlotLimits);
                    subplot(nPlots,2,2+2*i);   plot([0:100],syn.rightLeg.C(i,:)); xlabel('Gait Cycle'); ylabel(['C' num2str(i) ' (activation)']); axis(tbiStudy.plot.activationPlotLimits);
                end
            else
                error('Unknown input for ploting synergies')
            end
        end
        function synergy_recon(syn) % plots the data reconstruction from synergy analysis
            % INPUT:
            %   syn = a synergy structure generated by tbiStudy.synergies.calcSynergies()
            
            figure('Name','Reconstructed Data from NNMF Synergy')
            [m,~] = size(syn.rightLeg.W); % number of muscles
            for i = 1:m
                % left leg
                subplot(m,2,2*i-1);
                plot([0:100],syn.leftLeg.RECON(i,:),'r'); axis(tbiStudy.plot.activationPlotLimits);
                
                % right leg
                subplot(m,2,2*i);
                plot([0:100],syn.rightLeg.RECON(i,:),'r'); axis(tbiStudy.plot.activationPlotLimits);
            end
            
            % titles
            subplot(m,2,1); title('Left Leg')
            subplot(m,2,2); title('Right Leg')
        end
        function synergy_compareRecon(syn) % compares synergy data reconstruction to original data
            % INPUT:
            %   syn = a synergy structure generated by tbiStudy.synergies.calcSynergies()
            
            figure('Name','Compare Reconstructed Data from NNMF Synergy')
            [m,~] = size(syn.rightLeg.W); % number of muscles
            for i = 1:m
                % left leg
                subplot(m,2,2*i-1);
                %plot([0:100],syn.leftLeg.A(i,:),'b');
                shadedErrorBar([0:100],syn.leftLeg.A(i,:),syn.leftLeg.AStd(i,:),{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
                hold on
                plot([0:100],syn.leftLeg.RECON(i,:),'r');
                hold off
                ylim(tbiStudy.plot.emgPlotYAxisLimits);
                
                % right leg
                subplot(m,2,2*i);
                %plot([0:100],syn.rightLeg.A(i,:),'b');
                shadedErrorBar([0:100],syn.rightLeg.A(i,:),syn.rightLeg.AStd(i,:),{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
                hold on
                plot([0:100],syn.rightLeg.RECON(i,:),'r');
                hold off
                ylim(tbiStudy.plot.emgPlotYAxisLimits);
            end
            h = findobj(gca,'Type','line');
            legend([h(2) h(1)],{'Original','Reconstructed'});

            % titles
            subplot(m,2,1); title('Left Leg')
            subplot(m,2,2); title('Right Leg')
        end
        function walkDMC_baseline() % walkDMC metric, compares healthy to TBI subjects
            
            
            walkDMC_TBI = tbiStudy.synergies.walkDMC();
            walkDMC_healthy = tbiStudy.synergies.walkDMC_healthy();
            
            figure
            markerSize = 12;
            % PLOT TBIs
            plot(walkDMC_TBI(:,1),'bO','MarkerSize',markerSize); % TBI, left leg
            hold on
            plot(walkDMC_TBI(:,2),'b^','MarkerSize',markerSize); % TBI, right leg
            
            
            % PLOT HEALTHYs
            % to eliminate clutter, plot healthy subject numbers as a
            % negative number
            hSubjNum = -1:-1:-length(walkDMC_healthy);
            plot(hSubjNum, walkDMC_healthy(:,1),'rO','MarkerSize',markerSize); % healthy, left leg
            plot(hSubjNum, walkDMC_healthy(:,2),'r^','MarkerSize',markerSize); % healthy, right leg
            
            % connect the right and left with a line
            for i = 1:length(walkDMC_TBI) 
                plot([i;i],[walkDMC_TBI(i,1); walkDMC_TBI(i,2)],'b')
            end
            for i = 1:length(walkDMC_healthy) 
                plot([-i;-i],[walkDMC_healthy(i,1); walkDMC_healthy(i,2)],'r')
            end
            
            plot(xlim,[100 100], '--k'); % average healthy
            plot(xlim,[110 110], ':k'); % +1 std healthy
            plot(xlim,[90 90], ':k'); % -1 std healthy
            hold off
            text(35,101,'AVG Healthy')
            text(35,111,'+1 STD Healthy')
            text(35,91,'-1 STD Healthy')
            title('walk-DMC')
            xlabel('Subject Number')
            ylabel('walk-DMC');
            legend('TBI left leg', 'TBI right leg','healthy Control left leg', 'healthy Control right leg')
            
        end
        function walkDMC_baseline2(testPoint) % walkDMC metric, compares healthy to TBI subjects
            
            
            if nargin < 1
                testPoint = 1;
            end
            
            walkDMC_TBI = tbiStudy.synergies.walkDMC(testPoint);
            walkDMC_healthy = tbiStudy.synergies.walkDMC_healthy();
            
            %%
            wdmcH = mean(walkDMC_healthy,2)
            wdmc = mean(walkDMC_TBI,2)
            %%
            figure
            ms = 8;
            plot(ones(length(wdmcH)),wdmcH,'ko','MarkerSize',ms)
            hold on
            plot(2*ones(length(wdmc)),wdmc,'ko','MarkerSize',ms)
            
            sigstar({[1,2]})
            
            xticks(1:2)
            xticklabels({'Healthy Controls','TBI'})
            xlim([0.5,2.5])
            ylim([60, 120])
            %%
            w = [walkDMC_healthy(:,1); walkDMC_healthy(:,2)]; % am I used both left and right legs here? seems sketchy
            
            walkDMC = [w; mean(walkDMC_TBI,2)];
            walkDMC_grouping = [zeros(length(w),1); ones(length(walkDMC_TBI),1)];
            
            figure
            markerSize = 12;
            % PLOT TBIs
            
            boxplot(walkDMC,walkDMC_grouping,'Labels',{'Healthy Controls','TBI'});
            
            title('walk-DMC')
            ylabel('walk-DMC');
            
            
        end
        function walkDMC_WCBabstract() % TEMPORARY AND SHITTY FUNCTION JUST TO FINISH MY DAMN ABSTRACT
            
            
            [walkDMC_TBI_TP1 walkDMC_TBI_TP2] = tbiStudy.plot.walkDMC_WCBabstract_syn()
            walkDMC_healthy = tbiStudy.synergies.walkDMC_healthy();
            
            %%
            wdmcH = mean(walkDMC_healthy,2)
            
            %%
           
            
            walkDMC = [wdmcH; walkDMC_TBI_TP1;walkDMC_TBI_TP2];
            walkDMC_grouping = [ones(length(wdmcH),1); 2*ones(length(walkDMC_TBI_TP1),1);3*ones(length(walkDMC_TBI_TP2),1)];
            
            figure
            %%
            
            data = {wdmcH, walkDMC_TBI_TP1,walkDMC_TBI_TP2};
            catIdx = walkDMC_grouping;
            plotSpread(data,'categoryIdx',catIdx,'categoryMarkers',{'o','s','s'},'categoryColors',{'r','b','b'},'spreadWidth',2)
            
            legend('Healthy Controls','TBI Subjects')
            ylabel('Walk-DMC')
            title('Walk-DMC')
            
            hold on
            % remember, the middle line on the box plot is the median!
            boxplot(walkDMC,walkDMC_grouping,'Labels',{'Healthy Controls','Before Treatment','After Treatment'});
            hold off

            hold on
            x = [2;3];
            y = [walkDMC_TBI_TP1, walkDMC_TBI_TP2]';
            for i = 1:length(walkDMC_TBI_TP1)
                plot(x,y(:,i));
            end

            hold off
            %xticks([1,2,3])
            %xticklabels({'Healthy Controls','Before Treatment','After Treatment'})

            
        end
        function [walkDMC_TBI_TP1 walkDMC_TBI_TP2] = walkDMC_WCBabstract_syn() % TEMP AND SHITTY TO GET ABSRTACT DONE IN TIME
            % TP 1 and 2 for only those who I've processed data for by now
            
            n = 1; % solve for one synergy
            
                trialType = 'overground';
                healthyTrialTypeNumber = 2; % for overground = 2, treadmill 22 = 4
            
            % display parameters
            disp(['Using TBI trialType: ' trialType ', and healthy control trialType: ' tbiStudy.constants.trialType{healthyTrialTypeNumber}]);
            disp(['and looking at TestPoint 1 and 2']);
            
            % 1. find walk DMC TP1
            
            sqlquery = ['select * from trials where (testPoint = 1) and trialType = "overground" and subject_id < 29 and subject_id != 6 and subject_id != 14'];
            tr = tbiStudy.load.trials(sqlquery);
            syn = tbiStudy.synergies.calcSynergies_multiple(tr,n);
            disp(['TBI synergies calculated: ' num2str(length(syn)) ' (' num2str(2*length(syn)) ' total)']);
            [~, ~, VnotAF1_avg, VnotAF1_std] = tbiStudy.synergies.VAF_healthy(n,healthyTrialTypeNumber);
            walkDMC = zeros(length(syn),2); % [left, right]
            for i = 1:length(syn)
                % left leg
                walkDMC(i,1) = 100 + 10*((syn(i).leftLeg.VnotAF - VnotAF1_avg)/(VnotAF1_std)); % Steele 2015
                [syn(i).leftLeg.walkDMC] = walkDMC(i,1);
                
                % right leg
                walkDMC(i,2) = 100 + 10*((syn(i).rightLeg.VnotAF - VnotAF1_avg)/(VnotAF1_std)); % Steele 2015
                [syn(i).rightLeg.walkDMC] = walkDMC(i,2);
            end
            walkDMC_TBI_TP1 = mean(walkDMC,2);
            walkDMC_TP1 = walkDMC
            
            % 2. find walk DMC TP2
            
            sqlquery = ['select * from trials where (testPoint = 2) and trialType = "overground" and subject_id < 29 and subject_id != 6 and subject_id != 14'];
            tr = tbiStudy.load.trials(sqlquery);
            syn = tbiStudy.synergies.calcSynergies_multiple(tr,n);
            disp(['TBI synergies calculated: ' num2str(length(syn)) ' (' num2str(2*length(syn)) ' total)']);
            [~, ~, VnotAF1_avg, VnotAF1_std] = tbiStudy.synergies.VAF_healthy(n,healthyTrialTypeNumber);
            walkDMC = zeros(length(syn),2); % [left, right]
            for i = 1:length(syn)
                % left leg
                walkDMC(i,1) = 100 + 10*((syn(i).leftLeg.VnotAF - VnotAF1_avg)/(VnotAF1_std)); % Steele 2015
                [syn(i).leftLeg.walkDMC] = walkDMC(i,1);
                
                % right leg
                walkDMC(i,2) = 100 + 10*((syn(i).rightLeg.VnotAF - VnotAF1_avg)/(VnotAF1_std)); % Steele 2015
                [syn(i).rightLeg.walkDMC] = walkDMC(i,2);
            end
            walkDMC_TBI_TP2 = mean(walkDMC,2);
            walkDMC_TP2 = walkDMC
            
        end
        function walkDMC_DGI() % plots walkDMC vs DGI
            fSize = 14;
            
            testPoint = 1;
             trialType = 'baseline';
             healthyTrialTypeNumber = 4;
             
             % calc walkDMC data
             walkDMC_TBI = tbiStudy.synergies.walkDMC(testPoint,trialType,healthyTrialTypeNumber);
            
             wdmc = mean(walkDMC_TBI,2);
             
             % calculate correlations
            [DGI, SOT, sixMWT, cor, DGIcor, SOTcor, sixMWTcor, labels] = tbiStudy.correlation.baseline_vsHealthy();
            
            
            
            % DGI vs Average Healthy Baseline Correlation
            figure('Name','DGI vs walkDMC')
            set(gcf,'color','w');
            scatter(DGI,wdmc,'ko');
            lsline; % least squares line
            cor = corrcoef(DGI,wdmc);
            text(8,90,['R = ' num2str(cor(1,2))]);
            
            xlim(tbiStudy.plot.dgiPlotXAxisLimits);

            %title(['DGI vs walk-DMC'],'FontSize',fSize);
            ylabel('walk-DMC','FontSize',fSize);
            xlabel('DGI Score','FontSize',fSize);
            set(gca,'FontSize',fSize,'FontWeight','normal')
            
            % SOT vs Average Healthy Baseline Correlation
            figure('Name','SOT vs Average Healthy Baseline  Correlation')
            set(gcf,'color','w');
            scatter(SOT,walkDMC_TBI,'ko');
            lsline; % least squares line
            cor = corrcoef(SOT,walkDMC_TBI);
            text(20,90,['R = ' num2str(cor(1,2))]);
            xlim(tbiStudy.plot.sotPlotXAxisLimits);
            title(['SOT vs walk-DMC'],'FontSize',fSize);
            ylabel('walk-DMC','FontSize',fSize);
            xlabel('SOT Score','FontSize',fSize);
            set(gca,'FontSize',fSize,'FontWeight','normal')
            
            % sixMWT vs Average Healthy Baseline Correlation
            figure('Name','6MWT vs walk-DMC')
            set(gcf,'color','w');
            scatter(sixMWT,walkDMC_TBI,'ko');
            lsline; % least squares line
            cor = corrcoef(sixMWT,walkDMC_TBI);
            text(300,90,['R = ' num2str(cor(1,2))]);
            xlim(tbiStudy.plot.sixmwtPlotXAxisLimits);
            title(['6MWT vs walk-DMC'],'FontSize',fSize);
            ylabel('walk-DMC','FontSize',fSize);
            xlabel('Distance (ft)','FontSize',fSize);
            set(gca,'FontSize',fSize,'FontWeight','normal')
            
        end
        function synergy_VAF_varied(testPoint,trialType,healthyTrialTypeNumber)
            % by default, baseline...
            if nargin < 2
                trialType = 'baseline';
                healthyTrialTypeNumber = 4;
            end
            if nargin < 1
                testPoint = 1;
            end
            
            % 1. Calculate variance accounted for (VAF) for varying synergies (n)
            [VAF_avg, VAF_std, VAF_avg_healthy, VAF_std_healthy, n, synergies, synergies_healthy] = tbiStudy.synergies.VAF_varied(testPoint,trialType,healthyTrialTypeNumber);
            
            % 2. plot
            figure('Name','tVAF vs numSynergies')
            errorbar(n,VAF_avg,VAF_std,'-ko');
            hold on
            errorbar(n,VAF_avg_healthy,VAF_std_healthy,'--ko');
            hold off
            title('total VAF by increasing synergies')
            legend('TBI','Controls');
            xlabel('Number of Synergies');
            ylabel('Total Variance Accounted For');
            
            
            % 3. tests for significant differences
            disp(['t-test of VAF_tbi vs VAF_healthy, Left and Right legs independent:']);
            for i = n
                disp(['For n = ' num2str(i) ',']);
                [h,p,ci,stats] = ttest2([synergies{i}.VAF],[synergies_healthy{i}.VAF]) % test for signifcant difference
            end
        end
        function synergy_healthy_averages(synergies_healthy)
            labelMuscleAbbrev = {'TA','GAS','SOL','VL','RF','HAM'};
            
            %% healthy weightings
            observations = length(synergies_healthy{1}); % number of rows of legs used
            n = length(synergies_healthy); % max number of synergies
            %W_syn = cell(5,1);
            for i = 2 % :n % iterate through total number of synergies
                
                % pull all weightings
                W = [synergies_healthy{i}.W]'; 
                % e.g. for n = 2, W = [syn1a; syn1b; syn2a; syn2b; ...
                
                % k means clustered analysis, of the weightings, grouped
                % into i clusters
                [idx,C_kmeans] = kmeans(W,i);
                
                % check that clusters are divided equally
                disp(['n = ' num2str(i) ', k means indices... (check for no repeats)'])
                reshape(idx,i,observations)
                
                % index synergies weights 1 and 2
                index1 = find(idx==1);
                index2 = find(idx==2);
                
                % pull clustered weights
                W1 = W(index1,:);
                W2 = W(index2,:);
                
                % pull clustered observations
                C = vertcat(synergies_healthy{i}.C);
                C1 = C(index1,:);
                C2 = C(index2,:);
            end
            
            %% healthy activations
%             C_syn = cell(5,1);
%             for i = 1:n % iterate through total number of synergies
%                 C = cell(i,1);
%                 for j = 1:i % iterate through rows of activations (number of synergies)
%                     c = zeros(observations,101);
%                     for k = 1:observations % iterate through rows of legs
%                         c(k,:) = synergies_healthy{i}(k).C(j,:); % pull weighting for that column and leg
%                     end
%                     C{j} = c;   % Combine to create cell array of synergy activation
%                     % for example, if total synergy is 2:
%                     % C{2} = [legRowsx101], all activations of 2nd synergy for all legs
%                     % C{1} is the activations for the first synergy, 
%                 end
%                 C_syn{i} = C; % C_syn is a cell array for the activations of varying number of synergies (1-5)
%             end
            
            
            % THE ABOVE SHOULD BE MOVED TO THE SYNERGIES CLASS...
            
            %% PLOT ALL SYNERGIES, OVERLAID
            
            figure
            subplot(2,2,1)
            plot([1:6],W1,'o')
                    title(['Healthy Weightings, n = ' num2str(i)]); xlabel('Muscles'); ylabel(['W (weight)']);
                    ylim([0 1])
                    xticks([1:6])
                    xticklabels(labelMuscleAbbrev)
                    
            subplot(2,2,2)
            plot([0:100],C1)
                    title('Healthy Activation'); xlabel('Gait Cycle'); ylabel(['C (activation)']);
                    axis(tbiStudy.plot.activationPlotLimits);
                    
            subplot(2,2,3)
            plot([1:6],W2,'o')
                    title(['Healthy Weightings, n = ' num2str(i)]); xlabel('Muscles'); ylabel(['W (weight)']);
                    ylim([0 1])
                    xticks([1:6])
                    xticklabels(labelMuscleAbbrev)
            
            subplot(2,2,4)
            plot([0:100],C2)
                    title('Healthy Activation'); xlabel('Gait Cycle'); ylabel(['C (activation)']);
                    axis(tbiStudy.plot.activationPlotLimits);
            
            %%
            
            %for i = 1:n % iterate through total number of synergies
                figure % plot all
                for j = 1:i % iterate  
                    subplot(i,2,2*j-1)
                    plot([1:6],W1,'o')
                    title(['Healthy Weightings, n = ' num2str(i)]); xlabel('Muscles'); ylabel(['W (weight)']);
                    ylim([0 1])
                    xticks([1:6])
                    xticklabels(labelMuscleAbbrev)
                    
                    subplot(i,2,2*j)
                    plot([0:100],C_syn{i}{j})
                    title('Healthy Activation'); xlabel('Gait Cycle'); ylabel(['C (activation)']);
                    axis(tbiStudy.plot.activationPlotLimits);
                end
                suptitle(['Weights and Activations, n = ' num2str(i)])
            %end
            
            %% PLOT AVERAGE SYNERGIES
            for i = 1:n % iterate through total number of synergies
                figure % plot all
                for j = 1:i % iterate  
                    subplot(i,2,2*j-1)
                    boxplot(W_syn{i}{j}','Labels',labelMuscleAbbrev)
                    %old: bar([1:6],mean(W))
                    %old: errorbar([1:6],mean(W),std(W),'.')
                    title(['Healthy Weightings, n = ' num2str(i)]); xlabel('Muscles'); ylabel(['W (weight)']);
                    ylim([0 1])
                    
                    subplot(i,2,2*j)
                    shadedErrorBar([0:100],mean(C_syn{i}{j}),std(C_syn{i}{j}),{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
                    title('Healthy Activation'); xlabel('Gait Cycle'); ylabel(['C (activation)']);
                    axis(tbiStudy.plot.activationPlotLimits);
                end
                suptitle(['Weights and Activations, n = ' num2str(i)])
            end
            
            %% healthy activations
            i = 1;
            C = [synergies_healthy{i}.C];
            C = reshape(C,101,[])';
            
            figure % all 
            plot([0:100],C)
            
            figure % averaged
            shadedErrorBar([0:100],mean(C),std(C),{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
            title('Healthy Activation'); xlabel('Gait Cycle'); ylabel(['C (activation)']);
            axis(tbiStudy.plot.activationPlotLimits);
            
        end
    end

end