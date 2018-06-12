function querydata = load(sqlquery) % constructor function
% Filename: load.m
% Author:   Samuel Acuña
% Date:     12 Jun 2018
% Description:
% Used to load data from SQLite database for analysis in Matlab
%
%
% Example Usage:
%       tbiStudy.load.trials(sqlquery)
%
% Example usage 2:
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
%
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