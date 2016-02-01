% driver for tbiNMBL.subject_tbiNMBL


tbi20 = tbiNMBL.subject_tbiNMBL();
tbi20.addTestPoint;
tbi20.addTrial(1); % Add baseline to tp1
tbi20.addTrial(1); % add overground to tp1
tbi20.plotTestPoint(1,1) % plot, and check emg labels


%% add second testPoint
tbi20.addTestPoint;
tbi20.addTrial(2); % Add baseline to tp2
tbi20.addTrial(2); % add overground to tp2
tbi20.addTrial(2); % add preferred to tp2
tbi20.plotTestPoint(2,1) % plot, and check emg labels


%% add testpoint 6
tbi20.addTestPoint;
tbi20.addTrial(3); % Add baseline to tp6
tbi20.addTrial(3); % add overground to tp6
tbi20.addTrial(3); % add preferred to tp6
tbi20.plotTestPoint(3,1) % plot, and check emg labels


%% add testpoint 10
tbi20.addTestPoint;
tbi20.addTrial(4); % Add baseline to tp10
tbi20.addTrial(4); % add overground to tp10
tbi20.addTrial(4); % add preferred to tp10
tbi20.plotTestPoint(4,1) % plot, and check emg labels


%% show data
tbi20.list
tbi20.plotSubject([1 2 ],[ 1 1]) % plot subject baseline over successive testpoints
tbi20.plotSubject([1 2 ],[ 2 2]) % plot subject overground over successive testpoints

%% check baseline improvement
baseline_corr = tbi20.correlationAcrossTestPoints(1); % check improvement, baseline
%% check overground improvement
overground_corr = tbi20.correlationAcrossTestPoints(2); % check improvement, overground

%% check consistency
tbi20.correlationOfTestPoint(1); % check consistency
tbi20.correlationOfTestPoint(2); % check consistency
tbi20.correlationOfTestPoint(3); % check consistency
tbi20.correlationOfTestPoint(4); % check consistency

%% optionally, if emg labels are out of order, for some trials
tbi20.fixSensor1Data(1) % for testPoint 1
tbi20.fixSensor1Data(2) % for testPoint 2
tbi20.fixSensor1Data(3) % for testPoint 6
tbi20.fixSensor1Data(4) % for testPoint 10

%% compare to healthy subject
% tbi01.correlationBetweenSubjects(hy08); % compare to a healthy subject
return

%%  create healthy subject
hy08 = tbiNMBL.subject_tbiNMBL();
hy08.addTestPoint;
hy08.addTrial(1); % Add baseline to tp1
hy08.addTrial(1); % add overground to tp1
hy08.list
hy08.correlationOfTestPoint(1); % check consistency of subject across the tp
hy08.plotTestPoint(1,1)
