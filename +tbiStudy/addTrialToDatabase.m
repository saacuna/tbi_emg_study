function addTrialToDatabase(tr,inpath)
% Filename: addTrialToDatabase.m
% Author:   Samuel Acuna
% Date:     24 May 2016
% Description:
% This function simply adds the filename and location of a trial structure
% into the SQLite database. The trial structure is created using
% tbiStudy.procesEMGtrail().
% make sure the trial file is somewhere in folder: tbiStudy.constants.dataFolder
%
%
% Usage:
%       tbiStudy.addTrialToDatabase(tr,inpath);
%
% Alternate: popup window to find the trial file
%       tbiStudy.addTrialToDatabase();


%%%%%%%%%%%%%%%%%%%%%%%%%
% load trial .mat file
if nargin == 0 % if not inputted, find and load the trial
    disp('Select trial .mat file')
    [infile, inpath]=uigetfile('*.mat','Select trial',tbiStudy.constants.dataFolder);
    if infile == 0
        error('Canceled. No file selected');
    end
    load([inpath infile]);
    disp(['Selected: ' infile ]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%
% make dataFileLocation relative to tbiStudy.constants.dataFolder location
dataFileLocation = strrep(inpath,tbiStudy.constants.dataFolder,'');


%%%%%%%%%%%%%%%%%%%%%%%%%
% add any additional notes about how EMG was processed
trialProcessingNotes = setNotes();

%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare SQL insert data
data = {tr.subject_id, tr.testPoint, tr.trialType, dataFileLocation, tr.filename,trialProcessingNotes};


%%%%%%%%%%%%%%%%%%%%%%%%%
% SQL insert
% Make connection to database, Using JDBC driver.
conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
exec(conn,'PRAGMA foreign_keys=ON');
datainsert(conn,'trials',tbiStudy.constants.trials_columnNames,data);
%datainsert(conn,'trials_healthy',tbiStudy.constants.trials_columnNames,data);
close(conn);
disp([tr.filename ' successfully added to the database']);
end

function notes = setNotes() % add notes dialogue box
prompt = {'trial EMG Processing Notes:   (if any)'};
prompt_title = 'trial EMG Processing Notes';
prompt_answer = inputdlg(prompt,prompt_title,[3 60]);
if isempty(prompt_answer); prompt_answer{1} = ''; end; 
notes = prompt_answer{1};
end