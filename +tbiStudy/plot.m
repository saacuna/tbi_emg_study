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
        emgPlotColors = {rgb('Blue') rgb('Red') rgb('ForestGreen') rgb('Yellow') rgb('Tomato')}; % the order of colors plotted, using rgb (Author: Kristján Jónasson, Dept. of Computer Science, University of Iceland (jonasson@hi.is). June 2009.
        emgAreaColors = {rgb('Gray') };
        legendPosition = [.4 .001 .2 .1] ; % normalized to figure : left, bottom, width, height
        transparentErrorBars = [1]; % 1 = transparent, 0 = opaque
        showErrorBars = [1]; % 1 = show them, 0 = hide
        dgiPlotYAxisLimits = [0,1];
        dgiPlotXAxisLimits = [0,25];
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
            tr = tbiStudy.loadSelectTrials(sqlquery);
            
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
            tr = tbiStudy.loadSelectTrials(sqlquery);
            
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
            tr = tbiStudy.loadSelectTrials(sqlquery);
            
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
        function comparehealthy(subject_id,testPoint,trialType) % single trial plot vs healthy emg
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
            tr = tbiStudy.loadSelectTrials(sqlquery);
            
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
        function DGIvsHealthyCor() % plots DGI vs healthy Correlation for specified trials
            
            % retrieve from database, using default values
            sqlquery = ['select trials.* from trials, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (totalNumTestPoints > 1) '...
                'and trialType = "baseline" '... % default trialType
                'and (testPoint = 1 or testPoint = 2)']; % default Pre/Post window
            tr = tbiStudy.loadSelectTrials(sqlquery);
            
            % observe that all the odd rows are PRE and all the even rows
            % are POST
            [rows ~] = size(tr); % total rows
            
            % find healthy correlation for each trial
            healthyCor =  zeros(rows,12); % 12 mucles
            for i = 1:rows
                cor = tbiStudy.correlation.healthy(tr(i)); % calc correlation matrices for each muscle
                for muscle = 1:12 
                    healthyCor(i,muscle) = cor{muscle,1}(1,2); % pull corr coeff for each muscle
                end
            end
            
            % muscle labels
            for i = 1:12
            labels{i} = cor{i,2};
            end
            
            % find DGI that corresponds to each trial
            sqlquery = ['select DGI.* from DGI, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = DGI.subject_id) '...
                'and (totalNumTestPoints > 1) '...
                'and (testPoint = 1 or testPoint = 2)']; % default Pre/Post window
            conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
            exec(conn,'PRAGMA foreign_keys=ON');
            curs = exec(conn, sqlquery);
            curs = fetch(curs);
            DGI = curs.Data;
            DGI = cell2mat(DGI(:,3));
            close(curs);
            close(conn);
            % observe that all the odd rows are PRE and all the even rows
            % are POST, and they match with the pre/post trials above

            % assemble data for plotting
            % DGIplot = [pre post]
            DGIplot = zeros(2,rows/2);
            DGIplot(1,:) = DGI(1:2:rows);
            DGIplot(2,:) = DGI(2:2:rows);
            
            % assemble data for plotting
            % healthyCorPlot = [pre post], each with 12 muscles
            healthyCorPlot = zeros(2,rows/2,12);
            healthyCorPlot(1,:,:) = healthyCor(1:2:rows,:);
            healthyCorPlot(2,:,:) = healthyCor(2:2:rows,:);
            
            % create figure
            figure('Name','DGI vs Correlation')
            set(gcf,'color','w');
             
                 for j = 1:6 % right leg
                     subplot(6,2,2*j);
                     hold on
                     % first plot the straight line
                     plot(DGIplot,healthyCorPlot(:,:,j),'LineStyle','-','Color','k');
                     % Then plot an invisible line, with circles as endpoints
                     h = plot(DGIplot(1,:),healthyCorPlot(1,:,j),'o',DGIplot(2,:),healthyCorPlot(2,:,j),'o'); % filled and open circle
                     % set first circle as filled
                     set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
                     % set second circle as empty
                     set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
                     hold off
                     title(labels(j))
                     ylim(tbiStudy.plot.dgiPlotYAxisLimits);
                     xlim(tbiStudy.plot.dgiPlotXAxisLimits);
                 end
                 for j = 1:6 % left leg
                     subplot(6,2,2*j-1);
                     hold on
                     plot(DGIplot,healthyCorPlot(:,:,6+j),'LineStyle','-','Color','k');
                     h = plot(DGIplot(1,:),healthyCorPlot(1,:,6+j),'o',DGIplot(2,:),healthyCorPlot(2,:,6+j),'o');
                     set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
                     set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
                     hold off
                     title(labels(6+j))
                     ylim(tbiStudy.plot.dgiPlotYAxisLimits);
                     xlim(tbiStudy.plot.dgiPlotXAxisLimits);
                 end
                 
                 % create legend
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
                 
                 % create title that goes over all the subplots
                 suptitle(['DGI vs Healthy Correlation']);

        end
        function DGIvsHealthyCor_muscle(muscleNumber)
            %%%%%%%%% write me next!
            
            
            %                      hh = plot(DGIplot,healthyCorPlot(:,:,j),'LineStyle','-','Color','k');
            %                      % requires label toolbox. http://www.mathworks.com/matlabcentral/fileexchange/47421-label/content/label_documentation/html/label_documentation.html
            %                      for k = 1:length(DGIplot)
            %                      label(hh(k),num2str(tr(2*k).subject_id),'location','center');
            %                      end
            
            
            
            
            
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
    end

end