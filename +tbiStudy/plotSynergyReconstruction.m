% Filename: plotSynergyReconstruction.m
% Author:   Samuel Acuña
% Date:    11 Sep 2018
% Description: plots the reconstructed EMG from synergies

clear; close all; clc;

% choose which trial types to plot
subject_id = 44;
trialType = 'baseline'; %'overground';'treadmill22';
testPoint = 1;
emg_type = 'concat_peak';
leg = 'right';

%% load synergy & EMG data
% datafolder = [tbiStudy.constants.healthyFolder 'HYN' sprintf('%02d',subject_id) '/']
% datafile = ['hyn' sprintf('%02d',subject_id) '_tp00_' trialType '_SYN.mat']
% filename = ['hyn' sprintf('%02d',subject_id) '_tp00_' trialType '_' emg_type '_' leg '_RECON'];

datafolder = [tbiStudy.constants.dataFolder 'TBI_' sprintf('%02d',subject_id) '/TP' sprintf('%02d',testPoint) '/']
datafile = ['tbi' sprintf('%02d',subject_id) '_tp' sprintf('%02d',testPoint) '_' trialType '_SYN.mat']
filename = ['tbi' sprintf('%02d',subject_id) '_tp' sprintf('%02d',testPoint) '_' trialType '_' emg_type '_' leg '_RECON'];

load([datafolder datafile]);


%% plot reconstruction
figure(1)
m = 2; % just look at gastroc (muscle 2)
for n = 1:5 % cycle through number of synergies
    
W = syn.(emg_type).(leg).W{n}; %synergy weights
C = syn.(emg_type).(leg).C{n}; %synergy activations
RECON = W*C; % EMG reconstruction
A = syn.(emg_type).A; % original EMG

subplot(5,1,n)
plot(A(m,:));
hold on
plot(RECON(m,:))
hold off
title(['Medial Gastrocnemius: ' num2str(n) ' synergies'])
ylabel('EMG')
xlim([0 500])

end
legend('original EMG','reconstructed EMG')

%% save fig
fig = gcf; %tightfig(gcf);
fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 15 20];
print([datafolder filename],'-depsc','-painters','-loose');
disp(['Plot of RECONS saved as: ' filename '.eps']);
