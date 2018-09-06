function querydata = load(sqlquery) % constructor function
% Filename: load.m
% Author:   Samuel Acuña
% Date:     12 Jun 2018
% Description:
% Used to load data from SQLite database for analysis in Matlab
%
% Example usage:
%         sqlquery = ['select * from trials_healthy where trialType = "overground" order by subject_id'];
%         queryData = tbiStudy.load(sqlquery);
% 
%         [rows, ~] = size(queryData);
%         tr_temp = [];
%         for i = 1:rows %iteratively load queried trials into structure
%             dataFileLocation = queryData{i,4}; % load relative file location
%             dataFileLocation = [tbiStudy.constants.dataFolder dataFileLocation]; % create absolute file location
%             filename = queryData{i,7}; % load EMG data
%             load([dataFileLocation filename]);
%             tr_temp = [tr_temp; tr];
%         end
%         tr = tr_temp;
%
% some example queries:
% sqlquery = 'select * from tbi_subjects';
% sqlquery = 'select tbi_subjects.subject_id from tbi_subjects left outer join trials on trials.subject_id = tbi_subjects.subject_id where trials.testPoint = 6 and trials.trialType = "overground" and tbi_subjects.stimulation_level = "Control"';
% sqlquery = 'select tbi_subjects.subject_id from tbi_subjects left outer join trials on trials.subject_id = tbi_subjects.subject_id where trials.testPoint = 10 and trials.trialType = "baseline"';
% sqlquery = 'select subject_id from tbi_subjects where stimulation_level = "Active"';
% sqlquery = 'select tbi_subjects.subject_id from tbi_subjects left outer join trials on trials.subject_id = tbi_subjects.subject_id where trials.testPoint = 1 and trials.trialType = "overground"';
%


if nargin==0 % select all by default
    sqlquery = 'select * from trials';
end

% Make connection to database, Using JDBC driver.
conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
exec(conn,'PRAGMA foreign_keys=ON');

% Read data from database.
curs = exec(conn, sqlquery);
curs = fetch(curs);

% prepare structure of queried data
querydata = curs.Data;
close(curs);

if ~iscell(querydata)
    error('Query failed. Check for typos.');
elseif strcmp(querydata{1,1},'No Data')
    error('Successful Query, but returned no results.');
else
    disp('Loaded query successfully.');
end

% Close database connection.
close(conn);
end


