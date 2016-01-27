% driver for emg_tbiNMBL






return
hy01 = emg_tbiNMBL()
hy01.loadTestPoint(1)
hy01.loadTestPoint(2)
hy01.loadTestPoint(3)
subj1.plotGaitCycle()
save('subj1.mat','subj1')

%% as a way to eliminate long package decalrations

% tbiNMBL.tbiConstants.trialType % is a lot. but try importing first...
import tbiNMBL.*
tbiConstants.trialType
% clear import


