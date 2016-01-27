% driver for emg_tbiNMBL

subj1 = emg_tbiNMBL()
subj1.loadTestPoint(1)
subj1.loadTestPoint(2)
subj1.loadTestPoint(3)
subj1.plotGaitCycle()
save('subj1.mat','subj1')

