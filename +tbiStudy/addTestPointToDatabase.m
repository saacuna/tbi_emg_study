function addTestPointToDatabase()
% Filename: addTestPointToDatabase.m
% Author:   Samuel Acuna
% Date:     24 May 2016
% Description:
% This function simply adds a testPoint to the SQLite database. Could also be
% done by accessing the SQLite database directly.
%
% Usage:
%       tbiStudy.addTestPointToDatabase();
%



%%%%%%%%%%%%%%%%%%%%%%%%%
% input subject and testpoint information
subject_id = setSubjectID();
testPoint = setTestPoint();
[dateCollected, dataCollectedBy] = setTestPointMetaData();
[walkingSpeed_time1,...
    walkingSpeed_1,...
    walkingSpeed_time2,...
    walkingSpeed_2,...
    walkingSpeed_preferred,...
    treadmillSpeed_preferred,...
    treadmillSpeed_baseline] = setSpeeds();
notes = setNotes();

%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare SQL insert data
data = {subject_id,...
    testPoint,... 
    dateCollected,...
    dataCollectedBy,...
    walkingSpeed_time1,...
    walkingSpeed_1,...
    walkingSpeed_time2,...
    walkingSpeed_2,...
    walkingSpeed_preferred,...
    treadmillSpeed_preferred,...
    treadmillSpeed_baseline,...
    notes};


%%%%%%%%%%%%%%%%%%%%%%%%%
% SQL insert
% Make connection to database, Using JDBC driver.
conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
exec(conn,'PRAGMA foreign_keys=ON');
datainsert(conn,'testPoints',tbiStudy.constants.testPoints_columnNames,data);
close(conn);
disp(['successfully added testPoint ' num2str(testPoint) ' to the database']);
end

% input functions
function subject_id = setSubjectID()
ID = inputdlg('Subject ID Number:','Subject ID Number',[1 60],{'01'});
try
    ID = str2num(ID{1});
catch
    error('Must specify numeric subject ID');
end;
subject_id = ID;
end
function testPoint = setTestPoint()
TPchoices = num2str(cell2mat(tbiStudy.constants.testPoint)');
selection = listdlg('Name','Test Point','PromptString','Select Test Point:','SelectionMode','single','ListString',TPchoices,'ListSize',[150 75]);
if isempty(selection); error('Must specify test point'); end; % user canceled.
testPoint = tbiStudy.constants.testPoint{selection};
testPoint = str2num(['uint16(' num2str(testPoint) ')']); % force the integer datatype
end
function [dateCollected, dataCollectedBy] = setTestPointMetaData()
prompt = {'Date Test Point Collected:   (yyyy-mm-dd)',...
    'Data Collected by:   (fullName1, fullName2, ...)'};
prompt_title = 'Test Point metadata';
prompt_defaultAnswer = {datestr(date,'yyyy-mm-dd'),'Samuel Acuna'};
prompt_answer = inputdlg(prompt,prompt_title,[1 60],prompt_defaultAnswer);
if isempty(prompt_answer); error('User Canceled.'); end; % user canceled.
dateCollected = prompt_answer{1};
dataCollectedBy = prompt_answer{2};
end
function [walkingSpeed_time1, walkingSpeed_1, walkingSpeed_time2, walkingSpeed_2, walkingSpeed_preferred, treadmillSpeed_preferred, treadmillSpeed_baseline] = setSpeeds();
prompt = {'Walking Speed - time 1: (sec)',...
    'Walking Speed - time 2: (sec)',...
    'Treadmill Speed - preferred: (mph)',...
    'Treadmill Speed - baseline: (mph)'};
prompt_title = 'Test Point ? speeds';
prompt_answer = inputdlg(prompt,prompt_title,[1 60]);

walkingSpeed_time1 = round(str2double(prompt_answer{1}),2);
walkingSpeed_time2 = round(str2double(prompt_answer{2}),2);  
treadmillSpeed_preferred = round(str2double(prompt_answer{3}),1);
treadmillSpeed_baseline = round(str2double(prompt_answer{4}),1);
% calculate speeds
walkingSpeed_1 = round((4/walkingSpeed_time1)*2.23694,2);
walkingSpeed_2 = round((4/walkingSpeed_time2)*2.23694,2);
walkingSpeed_preferred = round((4/mean([walkingSpeed_time1,walkingSpeed_time2]))*2.23694,2);
end
function notes = setNotes()
prompt = {'Notes:   (if any)'};
prompt_title = 'Test Point Notes';
prompt_answer = inputdlg(prompt,prompt_title,[3 60]);
if isempty(prompt_answer); prompt_answer{1} = ''; end; 
notes = prompt_answer{1};
end