function tr = loadSelectTrials(sqlquery)
% Filename: loadSelectTrials.m
% Author:   Samuel Acuna
% Date:     24 May 2016
% Description:
% This function loads the trials specified with sqlquery into the workspace.
% It forms a structure array called 'tr'. The files must be in the SQLite
% database.
%
% Usage:
%       sqlquery = 'select * from trials where subject_id = 1';
%       tr = tbiStudy.loadSelectTrials(sqlquery);
%
% Alternate: return all the trials in the database
%       tr = tbiStudy.loadSelectTrials(); 

if nargin==0 % select all by default
    sqlquery = 'select * from trials';
end

% Make connection to database, Using JDBC driver.
conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
exec(conn,'PRAGMA foreign_keys=ON');

% Read data from database.
curs = exec(conn, sqlquery);
curs = fetch(curs);
close(curs);

% prepare structure of queried data
data = curs.Data;

if ~iscell(data)
    disp('Query failed. Check for typos.');
elseif strcmp(data{1,1},'No Data')
    disp('Successful Query, but returned no results.');
else 
    [rows, ~] = size(data);
    tr_temp = [];
    for i = 1:rows %iteratively load queried trials into structure
        load([data{i,4} data{i,5}]); % dataFileLocation, filename
        tr_temp = [tr_temp; tr];
    end
    tr = tr_temp;
    disp('Loaded query successfully.');
end

% Close database connection.
close(conn);


end