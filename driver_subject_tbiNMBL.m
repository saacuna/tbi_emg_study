% driver for tbiNMBL.subject_tbiNMBL





return

%%  create healthy subject
hy08 = tbiNMBL.subject_tbiNMBL();
hy08.addTestPoint;
hy08.addTrial(1); % Add baseline to tp1
hy08.addTrial(1); % add overground to tp1
hy08.list
hy08.correlationOfTestPoint(1); % check consistency of subject across the tp
hy08.plotTestPoint(1,1)
