classdef plot
    % Filename: plot.m
    % Author:   Samuel Acuna
    % Date:     24 May 2016
    % Description:
    % This class holds static functions that plot trials
    % The trials must already in the workspace.
    %
    % Example Usage:
    %       tbiStudy.plot.trial(tr(1))    %plots one trial
    
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
        function trial(tr,plotColorIndex)
            
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
    end
end