% driver for emg_tbiNMBL

clear

subj1 = emg_tbiNMBL()
subj1.loadTestPoint(1)
subj1.plotGaitCycle(1)
save('subj1.mat','subj1')