function appendTrialInDatabase(trial_file)
% Filename: addTrialToDatabase.m
% Author:   Samuel Acuna
% Date:     08 May 2018
% Description:
% This function simply adds the filename and location of the new trial structure
% into the SQLite database, for a pre-existing trial.


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
    
    if strcmp(infile(end-6:end-4),'ACC')
        trial_file = acc;
    elseif strcmp(infile(end-6:end-4),'EMG')
        trial_file = tr;
    elseif strcmp(infile(end-6:end-4),'SYN')
        trial_file = syn;
    else
        error('Inputting wrong type of structure');
    end
end



% %%%%%%%%%%%%%%%%%%%%%%%%%
% % add any additional notes about how EMG was processed
% trialProcessingNotes = setNotes();

%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare SQL update data
data = {trial_file.filename};
    if strcmp(trial_file.filename(end-2:end),'ACC')
        colname = {'filename_ACC'};
    elseif strcmp(trial_file.filename(end-2:end),'EMG')
        colname = {'filename_EMG'};
    elseif strcmp(trial_file.filename(end-2:end),'SYN')
        colname = {'filename_SYN'};
    else
        error('Inputting wrong type of structure');
    end
whereclause = ['WHERE subject_id = ' num2str(trial_file.subject_id) ' AND testPoint = ' num2str(trial_file.testPoint) ' AND trialType = "' trial_file.trialType '"'];

%%%%%%%%%%%%%%%%%%%%%%%%%
% SQL update
% Make connection to database, Using JDBC driver.
conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
exec(conn,'PRAGMA foreign_keys=ON');
if strcmp(trial_file.subject_type,'tbi')
    tablename = 'trials';
elseif strcmp(trial_file.subject_type,'hyn')
    tablename = 'trials_healthy';
else
    error('Trial structure not updated to latest version.')
    %datainsert(conn,'trials',tbiStudy.constants.trials_columnNames,data);
    %datainsert(conn,'trials_healthy',tbiStudy.constants.trials_columnNames,data);
end
update(conn,tablename,colname,data,whereclause);
close(conn);
disp([trial_file.filename ' successfully updated in the database']);
end

% function notes = setNotes() % add notes dialogue box
% prompt = {'trial EMG Processing Notes:   (if any)'};
% prompt_title = 'trial EMG Processing Notes';
% prompt_answer = inputdlg(prompt,prompt_title,[3 60]);
% if isempty(prompt_answer); prompt_answer{1} = ' '; end; 
% notes = prompt_answer{1};
% end