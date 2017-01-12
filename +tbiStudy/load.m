classdef load
    % Filename: load.m
    % Author:   Samuel Acuna
    % Date:     11 Jan 2017
    % Description:
    % Used to load various data for analysis
    %
    %
    % Example Usage:
    %       tbiStudy.load.trials(sqlquery)
    
    
    methods (Static)
        function tr = trials(sqlquery) % constructor function
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
                error('Query failed. Check for typos.');
            elseif strcmp(data{1,1},'No Data')
                error('Successful Query, but returned no results.');
            else
                [rows, ~] = size(data);
                tr_temp = [];
                for i = 1:rows %iteratively load queried trials into structure
                    dataFileLocation = data{i,4}; % load relative file location
                    dataFileLocation = [tbiStudy.constants.dataFolder dataFileLocation]; % create absolute file location
                    filename = data{i,5};
                    load([dataFileLocation filename]);
                    tr_temp = [tr_temp; tr];
                end
                tr = tr_temp;
                disp('Loaded query successfully.');
            end
            
            % Close database connection.
            close(conn); 
        end
        function tr = healthy(trialTypeNumber) % load all individual healthy control data
            % INPUTS:
            % trialTypeNumber = number specifying which trialtype (see tbiStudy.constants.trialType)
            
            tr_temp = [];
            for i = 1:tbiStudy.constants.nHealthy % number of healthy controls
                sn = sprintf('%02d',i);
                dataFileLocation = [ tbiStudy.constants.healthyFolder 'HYN' sn '/'];
                trialType = tbiStudy.constants.trialType{trialTypeNumber};
                filename = ['hyn' sn '_tp00_' trialType '.mat'];
                load([dataFileLocation filename]);
                tr_temp = [tr_temp; tr];
            end
            tr = tr_temp;
            disp(['Loaded healthy ' trialType ' trials.']);
        end
    end %methods
    
end %classdef