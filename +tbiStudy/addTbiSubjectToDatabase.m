function addTbiSubjectToDatabase()
% Filename: addSubjectToDatabase.m
% Author:   Samuel Acuna
% Date:     24 May 2016
% Description:
% This function simply adds a subject to the SQLite database. Could also be
% done by accessing the SQLite database directly.
%
% Usage:
%       tbiStudy.addSubjectToDatabase();
%



%%%%%%%%%%%%%%%%%%%%%%%%%
% input subject information
[subject_id, initials] = setSubjectID();
stimulation_level = setStimulationLevel();
status = setStatus();


%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare SQL insert data
data = {subject_id, initials, stimulation_level, status};


%%%%%%%%%%%%%%%%%%%%%%%%%
% SQL insert
% Make connection to database, Using JDBC driver.
conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
exec(conn,'PRAGMA foreign_keys=ON');
datainsert(conn,'tbi_subjects',tbiStudy.constants.tbi_subjects_columnNames,data);
close(conn);
disp(['successfully added tbi subject ' num2str(subject_id) ' to the database']);
end

% information input functions
function [subject_id, initials] = setSubjectID() % update subject identifiers
prompt = {'Subject ID Number:',...
    'Subject Initials:'};
prompt_defaultAnswer = {'01','SA'};
prompt_title = 'Subject Identifiers';
prompt_answer = inputdlg(prompt,prompt_title,[1 60],prompt_defaultAnswer);
try
    ID = str2num(prompt_answer{1});
catch
    error('Must specify numeric subject ID');
end;
subject_id = ID;
initials = prompt_answer{2};

end
function stimulation_level = setStimulationLevel() % update PoNS stimulation type
level = tbiStudy.constants.stimulation_level;
prompt_defaultAnswer= 1;
prompt_title = 'Select PoNS stimulation level:';
prompt_title2 = 'stimulation level';
prompt_answer = listdlg('PromptString',prompt_title,'SelectionMode','single','Name',prompt_title2,'ListString',level,'InitialValue',prompt_defaultAnswer,'ListSize',[150 75]);
if isempty(prompt_answer); error('User canceled'); end; % user canceled.
stimulation_level = level{prompt_answer};
end
function status = setStatus() % update the status of the subject
statuses = tbiStudy.constants.status;
prompt_defaultAnswer = 1;
prompt_title = 'Specify TBI Subject Status:';
prompt_title2 = 'Subject Status';
prompt_answer = listdlg('PromptString',prompt_title,'SelectionMode','single','Name',prompt_title2,'ListString',statuses,'InitialValue',prompt_defaultAnswer,'ListSize',[150 75]);
if isempty(prompt_answer); error('User canceled'); end; % user canceled.
status = statuses{prompt_answer};
end