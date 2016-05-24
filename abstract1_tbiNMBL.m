% abstract1_tbiNMBL.m

%%
subjects = {tbi01, tbi05, tbi07};


for i = 1:length(subjects)

x = subjects{i}.correlationAcrossTestPoints(1)
for j = 1:12
    y(j) = x{j}(1,2)
end
meany(i) = mean(y)
stdy(i) = std(y)
end

mean(meany)
std(stdy)
%%
close all

figure('Name','gastroc')
% subplot(3,2,1) % left gasttroc

for i = 1:3
    subplot(3,1,i)
hold on    
                shadedErrorBar([0:100]',subjects{i}.testPoints{1}.trials{1}.emgData(:,8),subjects{i}.testPoints{1}.trials{1}.emgStd(:,8),{'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{1}},tbiNMBL.constants_tbiNMBL.transparentErrorBars);
                 plot([0:100]',         subjects{i}.testPoints{1}.trials{1}.emgData(:,8),'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{1});
                 
                 shadedErrorBar([0:100]',subjects{i}.testPoints{2}.trials{1}.emgData(:,8),subjects{i}.testPoints{2}.trials{1}.emgStd(:,8),{'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{2}},tbiNMBL.constants_tbiNMBL.transparentErrorBars);
                 plot([0:100]',          subjects{i}.testPoints{2}.trials{1}.emgData(:,8),'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{2});
title(subjects{i}.testPoints{1}.trials{1}.emgLabel(8));
ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
                xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
                 hold off                 
end
set(gcf,'color','w');
figure('Name','soleus')

for i = 1:3
    subplot(3,1,i)
hold on    
                shadedErrorBar([0:100]',subjects{i}.testPoints{1}.trials{1}.emgData(:,9),subjects{i}.testPoints{1}.trials{1}.emgStd(:,9),{'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{1}},tbiNMBL.constants_tbiNMBL.transparentErrorBars);
                 plot([0:100]',         subjects{i}.testPoints{1}.trials{1}.emgData(:,9),'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{1});
                 
                 shadedErrorBar([0:100]',subjects{i}.testPoints{2}.trials{1}.emgData(:,9),subjects{i}.testPoints{2}.trials{1}.emgStd(:,9),{'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{2}},tbiNMBL.constants_tbiNMBL.transparentErrorBars);
                 plot([0:100]',          subjects{i}.testPoints{2}.trials{1}.emgData(:,9),'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{2});
title(subjects{i}.testPoints{1}.trials{1}.emgLabel(9));
ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
                xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
                 hold off                 
end

set(gcf,'color','w');
figure

for i = 1:3
    subplot(3,1,i)
hold on    
                
                 plot([0:100]',         subjects{i}.testPoints{1}.trials{1}.emgData(:,9),'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{1});
                 
                
                 plot([0:100]',          subjects{i}.testPoints{2}.trials{1}.emgData(:,9),'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{2});
%title(subjects{i}.testPoints{1}.trials{1}.emgLabel(9));
ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
                xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
                 hold off                 
end
legend('Pre','Post')
set(gcf,'color','w');

%%
% available subjects
subjects = {tbi01, tbi03, tbi04, tbi05, tbi07, tbi08, tbi09, tbi10, tbi11, tbi12, tbi13, tbi15, tbi16, tbi17, tbi18, tbi19};


%% find responders and non-responders

% compare tp1 to tp2

% responder has > 10% preferred speed after 2 weeks
responders = cell(0);
nonresponders = cell(0);
for i = 1: length(subjects) 
    disp(subjects{i}.ID);
    disp(['base: ' subjects{i}.testPoints{1}.walkingSpeed_baseline '  pref:' subjects{i}.testPoints{2}.walkingSpeed_preferred]);
    if str2num(subjects{i}.testPoints{2}.walkingSpeed_preferred) > 1.10*str2num(subjects{i}.testPoints{1}.walkingSpeed_baseline )
        responders{end+1} = subjects{i};
    else
        nonresponders{end+1} = subjects{i};
    end

end

% display responders
for i = 1:length(responders)
    disp(responders{i}.ID);
end

% TBI-01
% TBI-03
% TBI-04
% TBI-07
% TBI-17
% bring in tbi-05

%% plot tp1 to tp2
for i = 1:length(responders)

responders{i}.plotSubject([1 2],[1 1]) % compare baseline speeds
end

%%
for i = 1:length(responders)

responders{i}.plotSubject([1 2],[1 2]) % compare baseline to pref speeds
suptitle([responders{i}.ID ' : compare baseline1 to pref2']);
end

%% plot tp1 to tp3
for i = 2:length(responders)-1

responders{i}.plotSubject([1 2 3],[1 1 1]) % compare baseline speeds
end

%% plot tp1 to tp3
for i = 2:length(responders)-1

responders{i}.plotSubject([1 2 3],[1 2 2]) % compare baseline speeds
end
