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
            tr = tbiStudy.loadSelectTrials(sqlquery);
            
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
            tr = tbiStudy.loadSelectTrials(sqlquery);
            
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
            tr = tbiStudy.loadSelectTrials(sqlquery);
            
            assert(length(tr) >=2, 'The second subject must be in the database');
            
            % assemble observation matrix for correlation
            cor = tbiStudy.correlation.assembleMatrix(tr);
            
            % create labels
            for i = 1:length(tr)
                labels{i} = ['TBI_' num2str(tr(i).subject_id)];
            end
            
            % list correlations on screen
            tbiStudy.correlation.list(cor,labels);
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
    end
end