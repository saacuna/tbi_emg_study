classdef correlation
    % Filename: correlation.m
    % Author:   Samuel Acuna
    % Date:     27 May 2016
    % Description:
    % This class holds static correlation analysis functions
    % The trials must already in the workspace.
    %
    % Example Usage:
    %       tbiStudy.correlation.ofTestPoint(1,1) %returns correlation matrices of subj 1 testPoint 1
    
    methods (Static)
        function cor = testPoint(subject_id,testPoint) % correlation coefficient between all trials in a testpoint
            % correlation of a muscle to itself across trials within a testpoint
            % cor = {corrCoeff matrices, muscleName}
            % example: tbiStudy.correlation.testPoint(1,1)
            
            % retrieve from database
            sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and testPoint = ' num2str(testPoint)];
            tr = tbiStudy.load.trials(sqlquery);
            
            assert(length(tr) >=2, 'Must have at least 2 trials in testPoint to perform correlations');
            
            % assemble observation matrix for correlation
            cor = tbiStudy.correlation.assembleMatrix(tr);
            
            % create labels
            for i = 1:length(tr)
                labels{i} = tr(i).trialType;
            end
            
            % list correlations on screen
            tbiStudy.correlation.list(cor,labels);
        end
        function cor = trialType(subject_id, trialType) % correlation coefficient of a trial type across all testPoints
            % correlation of a muscle to itself across testPoints of the same trialType
            % cor = {corrCoeff matrices, muscleName}
            % example: tbiStudy.correlation.trialType(1,'baseline')
            
            % retrieve from database
            sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and trialType = "' trialType '"'];
            if strcmp(trialType,'preferred');
                sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and (trialType = "preferred" or (testPoint = 1 and trialType = "baseline"))'];
            end
            tr = tbiStudy.load.trials(sqlquery);
            
            assert(length(tr) >=2, ['Must have at least 2 testPoints for trialType "' trialType '" to perform correlations']);
            
            % assemble observation matrix for correlation
            cor = tbiStudy.correlation.assembleMatrix(tr);
            
            % create labels
            for i = 1:length(tr)
                labels{i} = ['TP' num2str(tr(i).testPoint)];
            end
            
            % list correlations on screen
            tbiStudy.correlation.list(cor,labels);
        end
        function cor = subjects(subject_id1, subject_id2,testPoint, trialType) % correlation between subjects
            % correlation of a muscle to itself between subjects. same testPoint and trialType
            % cor = {corrCoeff matrices, muscleName}
            % example: tbiStudy.correlation.subjects(1,2,1,'baseline')
            % example: tbiStudy.correlation.subjects(1,2) % assumes tp1, baseline
            
            % specify defaults
            if nargin < 4
                trialType = 'baseline';
            end
            if nargin < 3
                testPoint = 1;
            end
            
            % retrieve from database
            if strcmp(trialType,'preferred') && (testPoint == 1); trialType = 'baseline'; end
            sqlquery = ['select * from trials where (subject_id = ' num2str(subject_id1) ' or subject_id = ' num2str(subject_id2) ') and testPoint = ' num2str(testPoint) ' and trialType = "' trialType '"'];
            tr = tbiStudy.load.trials(sqlquery);
            
            assert(length(tr) >=2, 'The second subject must be in the database');
            
            % assemble observation matrix for correlation
            cor = tbiStudy.correlation.assembleMatrix(tr);
            
            % create labels
            for i = 1:length(tr)
                labels{i} = ['tbi' num2str(tr(i).subject_id)];
            end
            
            % list correlations on screen
            tbiStudy.correlation.list(cor,labels);
        end
        function cor = healthyTrial(subject_id,testPoint,trialType) % correlation between specific trial and healthy subject
            % USeS  AN AGGREGATE HEALTHY TRIAL  AS SPECIFIED IN
            % tbiStudy.constants.healthy, 
            
            % cor = {corrCoeff matrices, muscleName}
            % example: tbiStudy.correlation.
            
            % specify defaults
            if nargin < 3
                trialType = 'baseline';
            end
            if nargin < 2
                testPoint = 1;
            end
            
            % retrieve one trial from database
            if strcmp(trialType,'preferred') && (testPoint == 1); trialType = 'baseline'; end
            sqlquery = ['select * from trials where subject_id = ' num2str(subject_id) ' and testPoint = ' num2str(testPoint) ' and trialType = "' trialType '"'];
            tr = tbiStudy.load.trials(sqlquery);
            
            % calculate correlation to healthy
            cor = tbiStudy.correlation.healthy(tr);
            
            % create labels
            labels{1} = ['tbi' num2str(tr(1).subject_id)];
            labels{2} = 'healthy';
            
            % list correlations on screen
            tbiStudy.correlation.list(cor,labels);
        end
        function cor = healthy(tr) % correlation between given trial data and healthy subject
            % USES  AN AGGREGATE HEALTHY TRIAL  AS SPECIFIED IN
            % tbiStudy.constants.healthy, 
            
            % cor = {corrCoeff matrices, muscleName}
            % example: tbiStudy.correlation.
            
            assert(length(tr) == 1, 'Should only be specifying one specific trial');
            
            % append healthy subject to working trial
            load(tbiStudy.constants.healthy); % healthy subject has the workspace variable 'hy'
            tr = [tr; hy];
            
            % assemble observation matrix for correlation
            cor = tbiStudy.correlation.assembleMatrix(tr);
        end
        function [DGI, cor, labels] = DGIvsHealthy() % DGI vs healthy Correlation, pre/post
            
            % 1. retrieve from database, using default values
            sqlquery = ['select trials.* from trials, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (totalNumTestPoints > 1) '...
                'and (trials.subject_id  != 26) '... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % temporary until file fixed!
                'and trialType = "baseline" '... % default trialType
                'and (testPoint = 1 or testPoint = 2)']; % default Pre/Post window
            tr = tbiStudy.load.trials(sqlquery);
            
            % observe that all the odd rows are PRE and all the even rows
            % are POST
            [rows ~] = size(tr); % total rows
            
            % 2. find healthy correlation for each trial
            healthyCor =  zeros(rows,12); % 12 muscles
            for i = 1:rows
                cor = tbiStudy.correlation.healthy(tr(i)); % calc correlation matrices for each muscle
                for muscle = 1:12 
                    healthyCor(i,muscle) = cor{muscle,1}(1,2); % pull corr coeff for each muscle
                end
            end
            
            % 3. pull the muscle labels
            for i = 1:12
            labels{i} = cor{i,2};
            end
            
            % 4. find DGI that corresponds to each trial
            sqlquery = ['select DGI.* from DGI, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = DGI.subject_id) '...
                'and (totalNumTestPoints > 1) '...
                'and (DGI.subject_id  != 26) '... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % temporary until file fixed!
                'and (testPoint = 1 or testPoint = 2)']; % default Pre/Post window
            conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
            exec(conn,'PRAGMA foreign_keys=ON');
            curs = exec(conn, sqlquery);
            curs = fetch(curs);
            DGI = curs.Data;
            DGI = cell2mat(DGI(:,3));
            close(curs);
            close(conn);
            % observe that all the odd rows are PRE and all the even rows
            % are POST, and they match with the pre/post trials above

            % 5. Now that we have our data, assemble data for plotting 
            % DGIplot = [pre post]
            DGI2 = zeros(rows/2,2);
            DGI2(:,1) = DGI(1:2:rows); % pre
            DGI2(:,2) = DGI(2:2:rows); % post
            
            
            % healthyCorPlot = [pre post], each with 12 muscles
            healthyCor2 = zeros(rows/2,2,12);
            healthyCor2(:,1,:) = healthyCor(1:2:rows,:); % pre
            healthyCor2(:,2,:) = healthyCor(2:2:rows,:); % post
            
            % 6. outputs
            DGI = DGI2;
            cor = healthyCor2;
            % labels = labels; 
        end
        function [DGI, cor, subject_id] = DGIvsHealthy_muscle(muscleNumber) % DGI vs healthy Correlation, pre/post, one muscle group
            % Since looking at just a single muscle, need to specify
            % whether looking at right leg, left leg, or average of both.
            % For most cases, use the average of both, but for some trials
            % one of the signals might be bad data. So we neglect those.
            %
            % This is done by referencing the database table
            % trial_useDataFromLeg, where each muscle is specified for
            %           1 = use right leg data
            %           0 = use average leg data
            %          -1 = use left leg data
            %
            
            
            assert((muscleNumber <= 6) && (muscleNumber > 0), 'Muscle Number just 1:6. Legs chosen in database table trial_useDataFromLeg');
            
            
            % 1. retrieve emg trials from database, using default values
            sqlquery = ['select trials.*, trials_useDataFromLeg.' tbiStudy.constants.muscles{muscleNumber} ' as legChoice '...
                'from trials, tbi_subjectsSummary_loadedTrials, trials_useDataFromLeg '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (trials.subject_id = trials_useDataFromLeg.subject_id) '...
                'and (trials.testPoint = trials_useDataFromLeg.testPoint) '... % trial must also have leg specified in trials_useDataFromLeg
                'and (totalNumTestPoints > 1) '...
                'and trials.trialType = "baseline" '... % default trialType
                'and (trials.testPoint = 1 or trials.testPoint = 2)']; % default Pre/Post window
            tr = tbiStudy.load.trials(sqlquery);
            % observe that all the odd rows are PRE and all the even rows
            % are POST
            [rows, ~] = size(tr); % total rows
            
            
            % 2. find leg choice (left,right,average) that corresponds to each trial
            % this is from the trial_useDataFromLeg table
            conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
            exec(conn,'PRAGMA foreign_keys=ON');
            curs = exec(conn, sqlquery);
            curs = fetch(curs);
            legChoice = curs.Data;
            legChoice = cell2mat(legChoice(:,7));
            close(curs);
            close(conn);
            % observe that all the odd rows are PRE and all the even rows
            % are POST, and they match with the pre/post trials above
            
            
            % 3. extract healthy subject emg curve for the specified muscle
            load(tbiStudy.constants.healthy); % healthy subject has the workspace variable 'hy'
            healthy_muscle = mean([hy.emgData(:,muscleNumber),hy.emgData(:,muscleNumber+6)]')'; % average between legs
            
            
            % 4. find healthy correlation for specified muscles
            healthyCor =  zeros(rows,1);
            for i = 1:rows  
                % extract subject emg curve for the specified muscle
                if legChoice(i) == 0  % average the emg data for both legs
                    tbiMuscle = mean([tr(i).emgData(:,muscleNumber), tr(i).emgData(:,muscleNumber+6)],2);
                elseif legChoice(i) == 1 % just look at the right leg
                    tbiMuscle = tr(i).emgData(:,muscleNumber);
                elseif legChoice(i) == -1 % just look at the left leg
                    tbiMuscle = tr(i).emgData(:,muscleNumber+6);
                end
                
                % calc correlation with healthy, store
                R_mat = corrcoef(healthy_muscle,tbiMuscle);
                healthyCor(i) = R_mat(1,2);
            end
            
            
            % 5. find DGI that corresponds to each trial
            sqlquery = ['select DGI.* from DGI, trials, tbi_subjectsSummary_loadedTrials, trials_useDataFromLeg '...
                'where (DGI.subject_id = trials.subject_id) and (DGI.testPoint = trials.testPoint) '...
                'and (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (trials.subject_id = trials_useDataFromLeg.subject_id) '...
                'and (trials.testPoint = trials_useDataFromLeg.testPoint) '... % trial must also have leg specified in trials_useDataFromLeg
                'and (totalNumTestPoints > 1) '...
                'and trials.trialType = "baseline" '... % default trialType
                'and (trials.testPoint = 1 or trials.testPoint = 2)']; % default Pre/Post window
            conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
            exec(conn,'PRAGMA foreign_keys=ON');
            curs = exec(conn, sqlquery);
            curs = fetch(curs);
            DGI = curs.Data;
            DGI = cell2mat(DGI(:,3));
            close(curs);
            close(conn);
            % observe that all the odd rows are PRE and all the even rows
            % are POST, and they match with the pre/post trials above
            
            
            % 6. now that we have all our data, prepare data in nicer matrices
            % DGIplot = [pre post]
            DGI2 = zeros(rows/2,2);
            DGI2(:,1) = DGI(1:2:rows); % pre
            DGI2(:,2) = DGI(2:2:rows); % post
            
            % healthyCorPlot = [pre post]
            healthyCor2 = zeros(rows/2,2);
            healthyCor2(:,1) = healthyCor(1:2:rows); % pre
            healthyCor2(:,2) = healthyCor(2:2:rows); % post
            
            % 7, Outputs
            DGI = DGI2;
            cor = healthyCor2; 
            
            subject_id = zeros(rows/2,1); % subject ID's for each subject
            for k = 1:rows/2
                subject_id(k) = tr(2*k).subject_id;
            end
        end
        function [DGI, cor, labels] = baseline_DGIvsHealthy() % DGI vs healthy Correlation, baseline only
            
            % 1. retrieve from database, using default values
            sqlquery = ['select trials.* from trials, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (trials.subject_id  != 26) '... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % temporary until file fixed!
                'and trialType = "baseline" '... % default trialType
                'and (testPoint = 1)']; % default Pre/Post window
            tr = tbiStudy.load.trials(sqlquery);
            [rows ~] = size(tr); % total rows
            
             % 2. find healthy correlation for each trial
             healthyCor =  zeros(rows,12); % 12 muscles
            for i = 1:rows
                cor = tbiStudy.correlation.healthy(tr(i)); % calc correlation matrices for each muscle
                for muscle = 1:12 
                    healthyCor(i,muscle) = cor{muscle,1}(1,2); % pull corr coeff for each muscle
                end
            end
            
            % 3. pull the muscle labels
            for i = 1:12
            labels{i} = cor{i,2};
            end
            
            % 4. find DGI that corresponds to each trial
            sqlquery = ['select DGI.* from DGI, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = DGI.subject_id) '...
                'and (DGI.subject_id  != 26) '... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % temporary until file fixed!
                'and (testPoint = 1)']; % default Pre/Post window
            conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
            exec(conn,'PRAGMA foreign_keys=ON');
            curs = exec(conn, sqlquery);
            curs = fetch(curs);
            DGI = curs.Data;
            DGI = cell2mat(DGI(:,3));
            close(curs);
            close(conn);
            

            % 5. Now that we have our data, assemble data for plotting 
            
            % 6. outputs
            DGI = DGI;
            cor = healthyCor; % [nSubjects x 12 muscles]
            % labels = labels; 
        end
        function [SOT, cor, labels] = baseline_SOTvsHealthy() % SOT vs healthy Correlation, baseline only
            
            % 1. retrieve from database, using default values
            sqlquery = ['select trials.* from trials, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (trials.subject_id  != 26) '... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % temporary until file fixed!
                'and trialType = "baseline" '... % default trialType
                'and (testPoint = 1)']; % default Pre/Post window
            tr = tbiStudy.load.trials(sqlquery);
            [rows ~] = size(tr); % total rows
            
             % 2. find healthy correlation for each trial
             healthyCor =  zeros(rows,12); % 12 muscles
            for i = 1:rows
                cor = tbiStudy.correlation.healthy(tr(i)); % calc correlation matrices for each muscle
                for muscle = 1:12 
                    healthyCor(i,muscle) = cor{muscle,1}(1,2); % pull corr coeff for each muscle
                end
            end
            
            % 3. pull the muscle labels
            for i = 1:12
            labels{i} = cor{i,2};
            end
            
            % 4. find DGI that corresponds to each trial
            sqlquery = ['select SOT.* from SOT, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = SOT.subject_id) '...
                'and (SOT.subject_id  != 26) '... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % temporary until file fixed!
                'and (testPoint = 1)']; % default Pre/Post window
            conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
            exec(conn,'PRAGMA foreign_keys=ON');
            curs = exec(conn, sqlquery);
            curs = fetch(curs);
            SOT = curs.Data;
            SOT = cell2mat(SOT(:,3));
            close(curs);
            close(conn);
            

            % 5. Now that we have our data, assemble data for plotting 
            
            % 6. outputs
            SOT = SOT;
            cor = healthyCor; % [nSubjects x 12 muscles]
            % labels = labels; 
        end
        function [sixMWT, cor, labels] = baseline_sixMWTvsHealthy() % SOT vs healthy Correlation, baseline only
            
            % 1. retrieve from database, using default values
            sqlquery = ['select trials.* from trials, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = trials.subject_id) '...
                'and (trials.subject_id  != 26) '... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % temporary until file fixed!
                'and trialType = "baseline" '... % default trialType
                'and (testPoint = 1)']; % default Pre/Post window
            tr = tbiStudy.load.trials(sqlquery);
            [rows ~] = size(tr); % total rows
            
             % 2. find healthy correlation for each trial
             healthyCor =  zeros(rows,12); % 12 muscles
            for i = 1:rows
                cor = tbiStudy.correlation.healthy(tr(i)); % calc correlation matrices for each muscle
                for muscle = 1:12 
                    healthyCor(i,muscle) = cor{muscle,1}(1,2); % pull corr coeff for each muscle
                end
            end
            
            % 3. pull the muscle labels
            for i = 1:12
            labels{i} = cor{i,2};
            end
            
            % 4. find DGI that corresponds to each trial
            sqlquery = ['select sixMWT.* from sixMWT, tbi_subjectsSummary_loadedTrials '...
                'where (tbi_subjectsSummary_loadedTrials.subject_id = sixMWT.subject_id) '...
                'and (sixMWT.subject_id  != 26) '... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % temporary until file fixed!
                'and (testPoint = 1)']; % default Pre/Post window
            conn = database('', '', '', 'org.sqlite.JDBC', tbiStudy.constants.dbURL);
            exec(conn,'PRAGMA foreign_keys=ON');
            curs = exec(conn, sqlquery);
            curs = fetch(curs);
            sixMWT = curs.Data;
            sixMWT = cell2mat(sixMWT(:,3));
            close(curs);
            close(conn);
            

            % 5. Now that we have our data, assemble data for plotting 
            
            % 6. outputs
            sixMWT = sixMWT;
            cor = healthyCor; % [nSubjects x 12 muscles]
            % labels = labels; 
        end
        function [DGI, SOT, sixMWT, cor, DGIcor, SOTcor, sixMWTcor, labels] = baseline_vsHealthy() % metrics vs average correlation to healthy, baseline only
            [DGI, cor, labels] = tbiStudy.correlation.baseline_DGIvsHealthy();
            [SOT] = tbiStudy.correlation.baseline_SOTvsHealthy();
            [sixMWT] = tbiStudy.correlation.baseline_sixMWTvsHealthy(); 
            
            % combine the correlations for all the muscles for average value
            cor = mean(cor,2);
            
            % compute correlation of METRIC vs Average Muscle Correlation
            data = [DGI,SOT,sixMWT, cor];
            [coef, P] = corrcoef(data);
            DGIcor = coef(1,4);
            SOTcor = coef(2,4);
            sixMWTcor = coef(3,4);
        end
        function list(cor,labels) % display correlation coefficients to the screen
            % 'cor' will always be 12x2 cell. first column is the
            % correlation matrices, 2nd column is the muscle name
            % calculate 'cor' with tbiStudy.correlation functions
            
            %tpTitles = {'tp01','tp02','tp06','tp10'};
            
            if isequal(size(cor{1}),[2 2]) % 2x2 correlation matrix
                fprintf('\n\t%s',['Correlation between ' labels{1} ' and ' labels{2} ':']);
                fprintf('\n\t%s\t%s\n\t%s\t%s\n','CorCoef','Muscle','-------','-------'); % list headers
                for muscle = 1:12 % list correlation coeff
                    fprintf('\t%1.2f\t%s\n',cor{muscle,1}(1,2),cor{muscle,2});
                end
                return
            end
            
            for muscle = 1:12 % matrix for each muscle
                fprintf('\n\t%s%s\n','Muscle: ',cor{muscle,2}); % print muscle header
                if isequal(size(cor{1}),[3 3]) % 3x3 correlation matrix
                    fprintf('\t\t%s\t%s\n',labels{2},labels{3})
                    fprintf('\t%s\t%1.2f\t%1.2f\n',labels{1},cor{muscle,1}(1,2),cor{muscle,1}(1,3));
                    fprintf('\t%s\t%s\t%1.2f\n',labels{2},'-',cor{muscle,1}(2,3));
                end
                if isequal(size(cor{1}),[4 4]) % 4x4 correlation matrix
                    fprintf('\t\t%s\t%s\t%s\n',labels{2},labels{3},labels{4})
                    fprintf('\t%s\t%1.2f\t%1.2f\t%1.2f\n',labels{1},cor{muscle,1}(1,2),cor{muscle,1}(1,3),cor{muscle,1}(1,4));
                    fprintf('\t%s\t%s\t%1.2f\t%1.2f\n',labels{2},'-',cor{muscle,1}(2,3),cor{muscle,1}(2,4));
                    fprintf('\t%s\t%s\t%s\t%1.2f\n',labels{3},'-','-',cor{muscle,1}(3,4));
                end
                % end
            end
        end
        function [DGI, cor_muscle, labels] = baseline_DGIvsHealthy_muscle()
            % looks at correlations to healthy, for specific muscles
            [DGI, cor, labels] = tbiStudy.correlation.baseline_DGIvsHealthy; % pull data
            
            % average right and left legs
            for muscle = 1:6
                cor_muscle(:,muscle) = mean([cor(:,muscle) cor(:,muscle+6)],2);
            end
            
            labels = regexprep(labels,'R ',''); % remove right leg specifier
            labels = labels(1:6);
            
        end
        function cor = assembleMatrix(tr) % assemble the correlation matrix for above functions
            cor = cell(12,2); %  12 muscles x (data, name)
            for muscle = 1:12
                for i = 1:length(tr)
                    M(:,i) = tr(i).emgData(:,muscle); % assemble observation matrix for correlation
                end
                cor{muscle,1} = corrcoef(M(:,:)); % correlation of a muscle to itself
                cor{muscle,2} = tr(1).emgLabel{muscle}; % muscle name
            end
            
        end
        function [cor_muscle, labels] = healthySubjVsHealthy()
            % correlation to a healthy subject to the ensemble healthy
            
            % 1. retrieve from database, using default values
            sqlquery = ['select trials_healthy.* from trials_healthy '...
                'where trialType = "treadmill22" ']; % default trialType
            tr = tbiStudy.load.trials(sqlquery);
            [rows ~] = size(tr); % total rows
            
             % 2. find healthy correlation for each trial
             healthyCor =  zeros(rows,12); % 12 muscles
            for i = 1:rows
                cor = tbiStudy.correlation.healthy(tr(i)); % calc correlation matrices for each muscle
                for muscle = 1:12 
                    healthyCor(i,muscle) = cor{muscle,1}(1,2); % pull corr coeff for each muscle
                end
            end
            
            
            % 3. pull the muscle labels
            for i = 1:12
            labels{i} = cor{i,2};
            end
            
            labels = regexprep(labels,'R ',''); % remove right leg specifier
            labels = labels(1:6);
            
                   
            % 4. average right and left legs
            cor = healthyCor; % [nSubjects x 12 muscles]
            for muscle = 1:6
                cor_muscle(:,muscle) = mean([cor(:,muscle) cor(:,muscle+6)],2);
            end
        end
    end
end