%scrubDataFileLocation.m


%%%%%%%%%%%%%%%%%%%
%%
 disp('Select trial .mat file')
    [infile, inpath]=uigetfile('*.mat','Select trial',tbiStudy.constants.dataFolder);
    if infile == 0
        error('Canceled. No file selected');
    end
    load([inpath infile]);
    disp(['Selected: ' infile ]);

    
tr = rmfield(tr,'dataFileLocation');
save([inpath tr.filename], 'tr');
disp(['dataFileLocation scrubbed.']);
disp(['Trial Data saved as: ' tr.filename]);
disp(['in folder: ' inpath]);

tbiStudy.addTrialToDatabase(tr,inpath);

%% 
%%%%%%%%%%%%%%%%
%     sqlquery = 'select * from trials';
% 
% 
% % Make connection to database, Using JDBC driver.
% conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
% exec(conn,'PRAGMA foreign_keys=ON');
% 
% % Read data from database.
% curs = exec(conn, sqlquery);
% curs = fetch(curs);
% close(curs);
% 
% % prepare structure of queried data
% data = curs.Data;
% 
%  
%     [rows, ~] = size(data);
% 
%     for i = 1:rows %iteratively load queried trials into structure
%         dataFileLocation = data{i,4}; % load aboslute file location
%         
% 
%         filename = data{i,5};
%         load([dataFileLocation filename]);
%         
%         tr = rmfield(tr,'dataFileLocation');
%         save([dataFileLocation tr.filename], 'tr');
%     end
% 
% % Close database connection.
% close(conn);

%%
%     sqlquery = 'select * from trials';
% 
% 
% % Make connection to database, Using JDBC driver.
% conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
% exec(conn,'PRAGMA foreign_keys=ON');
% 
% % Read data from database.
% curs = exec(conn, sqlquery);
% curs = fetch(curs);
% close(curs);
% 
% % prepare structure of queried data
% data1 = curs.Data;
% 
% % Close database connection.
% close(conn);
% 
% [rows, ~] = size(data1);
% 
% for j = 1:rows
%     dfl =  {strrep(data1{j,4},tbiStudy.constants.dataFolder,'')};
%     
%     whereclause = ['where subject_id = ' num2str(data1{j,1}) ' and testPoint = ' num2str(data1{j,2}) ' and trialType = "' data1{j,3} '"']
% 
%     
% conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
% exec(conn,'PRAGMA foreign_keys=ON');
% 
% update(conn,'trials',{'dataFileLocation'},dfl,whereclause);
% 
% close(conn);
% 
% end
