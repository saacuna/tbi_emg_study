% Filename: synergyStructures.m
% Author:   Samuel Acuña
% Date:     18 Sep 2018
% Description: examines the underlying structure of the synergy weights and
% activations


clear; close all; clc;

%% step 1: load synergy data
%sqlquery = ['select * from trials where trialType = "baseline" and testPoint = 1 order by subject_id']
%sqlquery = ['select * from trials where trialType = "overground" and testPoint = 1 order by subject_id']
%sqlquery = ['select * from trials_healthy where trialType = "treadmill22" order by subject_id']
sqlquery = ['select * from trials_healthy where trialType = "treadmill28" order by subject_id']
%sqlquery = ['select * from trials_healthy where trialType = "treadmill34" order by subject_id']
%sqlquery = ['select * from trials_healthy where trialType = "overground" order by subject_id']
queryData = tbiStudy.load(sqlquery);

[rows, ~] = size(queryData);
syn_temp = [];
for i = 1:rows %iteratively load queried trials into structure
    dataFileLocation = queryData{i,4}; % load relative file location
    dataFileLocation = [tbiStudy.constants.dataFolder dataFileLocation]; % create absolute file location
    filename = queryData{i,9}; % load synergy data
    load([dataFileLocation filename]);
    syn_temp = [syn_temp; syn];
end
syn = syn_temp;
clearvars -except syn

%% step 2: k means cluster analysis
% for now, treat each synergy weight vector as independent (not accurate,
% since they are related by each subject. perhaps use permutations?)

nSubjects = length(syn);
nMuscles = 6;
emg_type = 'concat_peak';
leg = {'left','right'};



for iL = 1:length(leg) % cycle through legs
    % preallocate structure
    W.(leg{iL}) = cell(nMuscles,nMuscles);
    C.(leg{iL}) = cell(nMuscles,nMuscles);
    
    for N = 1:5 % cycle through number of synergies examined
        %preallocate
        W_original = zeros(nMuscles,nSubjects*N);
        C_original = cell(nSubjects*N,1);
        
        
        for iSUB = 1:nSubjects  % cycle through subjects in query
            for iSYN = 1:N % cycle through vectors of the given synergy
                W_original(:,iSUB*N-N+iSYN) = syn(iSUB).concat_peak.(leg{iL}).W{N}(:,iSYN); %pull W for each subject, concatentate them all horizontally
                C_original{iSUB*N-N+iSYN} = syn(iSUB).concat_peak.(leg{iL}).C{N}(iSYN,:); %pull C for each subject, concatentate them all vertically
            end
        end
        
        % cluster analysis
        % randomize teh order of the data, run it multiple times?
        
        % k means clustered analysis, of the weightings, grouped into i clusters
        W_original_transpose = W_original';
        [idx,C_kmeans] = kmeans(W_original_transpose,N,'Replicates',100,'Display','off'); %display: {'final','off'}
        
        % check that clusters are divided equally
        disp(['n = ' num2str(N) ', k means indices... (check for no repeats)'])
        reshape(idx,N,nSubjects)'
        for i = 1:N
            disp(['nSynergy#' num2str(i) ':  ' num2str(sum(idx==i))])
        end
        
        % assign reorganized synergy weights and activations
        for i = 1:N
            idx_loc{i} = find(idx==i);
            W.(leg{iL}){N,i} = W_original_transpose(idx_loc{i},:); %synergy weights. cell = [row: nSynergies examined , col: synergy number of the given synergy] each element being [row: subjects, col: muscles]
            C.(leg{iL}){N,i} = C_original(idx_loc{i}); % activations. cell = [row: nSynergies examined, col: synergy number of the given synergy]. each element being [row: subjects, col: time]
        end
        
        % note: I might want to create W matrices per subject here.
    end
end
%% step 3: plot grouped synergies


% plot synergy weights
labelMuscleAbbrev = {'TA','GAS','SOL','VL','RF','HAM'};
axisValues1 = [0.5 6.5 0 1.1];
xtickValues1 = [1:6];
for N = 1:5 % cycle through number of synergies examined
    fig = figure(N);
    for n = 1:N % cycle through synergies 
        
        subplot(N,2,2*n-1)
        %plot([1:6],W.left{N,n},'-o')
        plot([1:6],W.left{N,n},'o','MarkerEdgeColor','none','MarkerFaceColor',rgb('LightGray'))
        hold on
        boxplot(W.left{N,n});
        hold off
        title(['N = ' num2str(N) ', n = ' num2str(n) ', LEFT']); xlabel('Muscles'); ylabel(['W (weight)']);
        axis(axisValues1); xticks(xtickValues1); xticklabels(labelMuscleAbbrev);
        
        subplot(N,2,2*n)
        %plot([1:6],W.right{N,n},'-o')
        plot([1:6],W.right{N,n},'o','MarkerEdgeColor','none','MarkerFaceColor',rgb('LightGray'))
        hold on
        boxplot(W.right{N,n})
        hold off
        title(['N = ' num2str(N) ', n = ' num2str(n) ', RIGHT']); xlabel('Muscles'); ylabel(['W (weight)']);
        axis(axisValues1); xticks(xtickValues1); xticklabels(labelMuscleAbbrev);
    end
    
    fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 35 25];
    filename = [syn(1).subject_type '_tp' num2str(syn(1).testPoint) '_' syn(1).trialType '_' emg_type '_WEIGHTS_N' num2str(N)];
    %print(filename,'-depsc','-painters','-loose');
    print(filename,'-dpng','-painters','-loose');
    close(fig)
end



%% plot synergy activations
nStrides = 5;
xtickValues2 = [0:nStrides];
axisValues2 = [0 nStrides 0 1];
dp = nStrides*100;
t = 0:nStrides/dp:nStrides;
for N = 1:5 % cycle through number of synergies examined
    fig = figure(N+10);
    for n = 1:N % cycle through synergies
        for iSUB = 1:length(C.left{N,n})
            %subplot(N,2,2*n-1)
            activations.left(iSUB,:) = C.left{N,n}{iSUB}(1:dp+1);
            %hold on
            %plot(t,activations.left(iSUB,:),'Color',rgb('LightGray'))
            %hold off
        end
        
        for iSUB = 1:length(C.right{N,n})
            %subplot(N,2,2*n)
            activations.right(iSUB,:) = C.right{N,n}{iSUB}(1:dp+1);
            %hold on
            %plot(t,activations.right(iSUB,:),'Color',rgb('LightGray'))
            %hold off
        end
         
        % plot average activations
         subplot(N,2,2*n-1)
         %hold on
         %plot(t, mean(activations.left),'LineWidth',2,'Color',rgb('Crimson'))
         shadedErrorBar(t,mean(activations.left),std(activations.left),{'color',rgb('Gray')})
         %hold off
         title(['N = ' num2str(N) ', n = ' num2str(n) ', LEFT']); xlabel('strides'); ylabel(['Activations']);
         axis(axisValues2); xticks(xtickValues2);
        
         subplot(N,2,2*n)
         %hold on
         %plot(t, mean(activations.right),'LineWidth',2,'Color',rgb('Crimson'))
         shadedErrorBar(t,mean(activations.right),std(activations.right),{'color',rgb('Gray')})
         %hold off
         title(['N = ' num2str(N) ', n = ' num2str(n) ', RIGHT']); xlabel('strides'); ylabel(['Activations']);
         axis(axisValues2); xticks(xtickValues2);
    end
    
    % save fig
    fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 35 25];
    filename = [syn(1).subject_type '_tp' num2str(syn(1).testPoint) '_' syn(1).trialType '_' emg_type '_ACTIVATIONS_N' num2str(N)];
    %print(filename,'-depsc','-painters','-loose');
    print(filename,'-dpng','-painters','-loose');
    close(fig)
end

