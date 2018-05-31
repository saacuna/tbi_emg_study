%add scaled to unit variance


% clc; clear; close all;
% ID = '05'
% 
% inpath = [tbiStudy.constants.healthyFolder 'HYN' ID '/'];
% 
% infile{1} = ['hyn' ID '_tp00_overground_EMG'];
% infile{2} = ['hyn' ID '_tp00_treadmill22_EMG'];
% infile{3} = ['hyn' ID '_tp00_treadmill28_EMG'];
% infile{4} = ['hyn' ID '_tp00_treadmill34_EMG'];

%for i = 1:4
   % load([inpath infile{i}]);
    
    EMG_avg_scaledUnitVariance = zeros(size(tr.emgStrides{1},1),12);
    EMG_std_scaledUnitVariance = zeros(size(tr.emgStrides{1},1),12);
    
    for j = 1:12
        emgConcat_scaledUnitVariance{j} = tr(1).emgConcat{j}/std(tr(1).emgConcat{j}); % find scaled unit variance
        EMG_avg_scaledUnitVariance(:,j) = tr(1).emgData(:,j)/std(tr(1).emgConcat{j}); %scaled to EMG unit variance
        EMG_std_scaledUnitVariance(:,j) = tr(1).emgStd(:,j)/std(tr(1).emgConcat{j});
    end
    tr(1).emgConcat_scaledUnitVariance = emgConcat_scaledUnitVariance;
    tr(1).emgData_scaledUnitVariance = EMG_avg_scaledUnitVariance;
    tr(1).emgStd_scaledUnitVariance = EMG_std_scaledUnitVariance;
    
    
    
    % save data
%     save([inpath tr.filename], 'tr');
% disp(['EMG data saved as: ' tr.filename]);
% disp(['in folder: ' inpath]);
    
    % plot EMG data for average gait cycle and all strides overlaid
%     figure(1);
%     for j = 1:6
%         subplot(6,2,2*j)
%         shadedErrorBar([0:100]',tr.emgData(:,j),tr.emgStd(:,j));%,{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
%         hold on
%         for i = 1:tr.nStrides_right
%             plot([0:100]',tr.emgStrides{j}(:,i))
%         end
%         hold off
%         title(tr.emgLabel{j})
%         
%         subplot(6,2,2*j-1)
%         shadedErrorBar([0:100]',tr.emgData(:,6+j),tr.emgStd(:,6+j));%,{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
%         hold on
%         for i = 1:tr.nStrides_left
%             plot([0:100]',tr.emgStrides{6+j}(:,i))
%         end
%         hold off
%         title(tr.emgLabel{6+j})
%     end
%     
    fig = figure(2);
    % emg scaled to unit variance
    
    for j = 1:6
        subplot(6,2,2*j)
        shadedErrorBar([0:100]',tr.emgData_scaledUnitVariance(:,j),tr.emgStd_scaledUnitVariance(:,j));
        title(tr.emgLabel{j}); ylim([0 5]);
        
        subplot(6,2,2*j-1)
        shadedErrorBar([0:100]',tr.emgData_scaledUnitVariance(:,6+j),tr.emgStd_scaledUnitVariance(:,6+j));
        title(tr.emgLabel{6+j}); ylim([0 5]);
    end
    
    tightfig(fig);
    suptitle([tr.subject_type '-' sprintf('%02d',tr(1).subject_id) ' TP' sprintf('%02d',tr(1).testPoint) ' ' tr(1).trialType '  UNIT VARIANCE SCALING']);
    fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 25 30];
    filename = [tr.subject_type sprintf('%02d',tr(1).subject_id) '_tp' sprintf('%02d',tr(1).testPoint) '_' tr(1).trialType '_avg_unitVariance'];
%     path_orig = pwd;
%     cd(inpath);
    print(filename,'-dpng','-painters','-loose');
%     cd(path_orig);
    disp(['Plot of EMG over gait cycles saved as: ' filename '.png']);
    close all; 
%end
