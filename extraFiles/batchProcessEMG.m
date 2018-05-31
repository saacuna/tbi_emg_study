

ID = '01'
TP = '01'
% TP = '02' 
% TP = '06' 
% TP = '10' 

inpath = [tbiStudy.constants.dataFolder 'TBI_' ID '/TP' TP '/']


%% BASELINE

infile = ['tbi' ID '_tp' TP '_baseline.txt']
[tr,inpath] = tbiStudy.processEMGtrial(inpath,infile);
tbiStudy.addTrialToDatabase(tr,inpath);

%% PREFERRED
infile = ['tbi' ID '_tp' TP '_preferred.txt']
[tr,inpath] = tbiStudy.processEMGtrial(inpath,infile);
tbiStudy.addTrialToDatabase(tr,inpath);

%% OVERGROUND
infile = ['tbi' ID '_tp' TP '_overground.txt']
[tr,inpath] = tbiStudy.processEMGtrial(inpath,infile);
tbiStudy.addTrialToDatabase(tr,inpath);
return

%% add to database (RUN THIS FOR ALL)
tbiStudy.addTrialToDatabase(tr,inpath);

