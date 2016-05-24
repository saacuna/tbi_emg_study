function addTrialToDatabase(tr)
% Filename: addTrialToDatabase.m
% Author:   Samuel Acuna
% Date:     24 May 2016
% Description:
% This function simply adds the filename and location of a trial structure
% into the SQLite database. The trial structure is created using
% tbiStudy.procesEMGtrail(),
%
%
% Usage:
%       tbiStudy.addTrialToDatabase(tr);
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
end


%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare SQL insert data
data = {tr.subject_id, tr.testPoint, tr.trialType, tr.dataFileLocation, tr.filename};


%%%%%%%%%%%%%%%%%%%%%%%%%
% SQL insert
% Make connection to database, Using JDBC driver.
conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
exec(conn,'PRAGMA foreign_keys=ON');
datainsert(conn,'trials',tbiStudy.constants.trials_columnNames,data);
close(conn);
disp([tr.filename ' successfully added to the database']);
end