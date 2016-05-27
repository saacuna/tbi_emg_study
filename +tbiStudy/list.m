classdef list
    % Filename: list.m
    % Author:   Samuel Acuna
    % Date:     24 May 2016
    % Description:
    % This class holds static functions that list and display trial information.
    % The trials must already in the workspace.
    %
    % Example Usage:
    %       tbiStudy.list.labels(tr(1))
    %       tbiStudy.list.testPoints();
    %       tbiStudy.list.tbi_subjects();
    
    methods (Static)
        function labels(tr) %lists the EMG labels of a specific trial
            disp(tr.emgLabel');  % these labels should be same for each trial examined
        end
        function subj = missingDGI() % lists all testPoints that don't have DGI values in database
            sqlquery = ['select testPoints.subject_id, testPoints.testPoint ' ...
                        'from testPoints ' ...
                        'left outer join DGI on testPoints.subject_id = DGI.subject_id and testPoints.testPoint = DGI.testPoint ' ...
                        'where DGI.subject_id is null and DGI.testPoint is null'];
            subj = tbiStudy.list.query(sqlquery);
            subj = cell2mat(subj); 
            disp('returns: [subject_id testPoint]');
        end
        function subj = missingSOT() % lists all testPoints that don't have SOT values in database
            sqlquery = ['select testPoints.subject_id, testPoints.testPoint ' ...
                        'from testPoints ' ...
                        'left outer join SOT on testPoints.subject_id = SOT.subject_id and testPoints.testPoint = SOT.testPoint ' ...
                        'where SOT.subject_id is null and SOT.testPoint is null'];
            subj = tbiStudy.list.query(sqlquery);
            subj = cell2mat(subj); 
            disp('returns: [subject_id testPoint]');
        end
        function testPoints() % list summary of testPoints collected

                fprintf('\n\t%s\n\n','testPoints summary:'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\n','subjID','testPt','nTrials','tmill_baseline'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\n' ,'-------','-------','-------','-------');
                
                sqlquery = ['select * from testPointSummary_loadedTrials'];
                summary = tbiStudy.list.query(sqlquery);
                [len ~] = size(summary);
                for i = 1:len
                    fprintf('\t%d\t%d\t%d\t%2.2f\n',summary{i,[1:3,5]});
                end
        end
        function tbi_subjects() %list summary of tbi subjects collected
            
            fprintf('\n\t%s\n\n','tbi_subjects summary:'); % list headers
            fprintf('\t%s\t%s\t%s\t%s\n','subjID','testPts','nTrials','status'); % list headers
            fprintf('\t%s\t%s\t%s\t%s\n' ,'-------','-------','-------','-------');
            
            sqlquery = ['select * from tbi_subjectsSummary_loadedTrials'];
            summary = tbiStudy.list.query(sqlquery);
            [len ~] = size(summary);
            for i = 1:len
                fprintf('\t%d\t%d\t%d\t%s\n',summary{i,:});
            end
        end
    end
    
    methods (Static, Access = private)
        function data = query(sqlquery)
            % Make connection to database, Using JDBC driver.
            conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
            exec(conn,'PRAGMA foreign_keys=ON');
            
            % Read data from database.
            curs = exec(conn, sqlquery);
            curs = fetch(curs);
            close(curs);
            
            % Close database connection.
            close(conn);
            
            % return the query information
            data = curs.data;
            
        end
    end
end