% driver for tbiNMBL.subject_tbiNMBL

% create healthy subject
hy02 = tbiNMBL.subject_tbiNMBL();
hy02.addTestPoint;
hy02.addTrial(1); % Add baseline to tp1
hy02.addTrial(1); % add overground to tp1
hy02.correlationOfTestPoint(1); % check consistency of subject across the tp
hy02.plotTestPoint(1)
hy02.list
