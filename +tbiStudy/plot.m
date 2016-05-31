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