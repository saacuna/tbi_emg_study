classdef tbiNMBL < handle
    % Filename: tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     27 Jan 2016
    % Description:
    % This class is used for the PoNS tbi study at the TCNL. This class
    % houses the emg data for all subjects, testpoints, and trials allowing
    % for easy comparison within subjects and between subjects
    
    properties (GetAccess = 'public', SetAccess = 'private')
        subjects; % stores emg & info on each subject
        healthySubject; %
    end
    properties (Dependent)
        numSubjects; % how many subjects have been stored in database
    end
    
    methods (Access = public)       
        function obj = tbiNMBL()% constructor function
            obj.subjects = cell(0); %setup database of subjects
            obj.healthySubject = cell(0); %setup healthy subject
        end
        function addSubject(obj,subj) % add new subject to database
            obj.subjects{obj.numSubjects+1} = subj; % creates a new instance of the subject class
            disp(['Subject ' obj.subjects{end}.ID ' has been added to the database.']);
            obj.list();
        end
        function setHealthySubject(obj,subj) % add healthy subject to compare TBI subjects against
            obj.healthySubject{1} = subj;
            disp(['Healthy Subject ' obj.healthySubject{1}.ID ' has been added to the database.']);
            obj.list();
        end
        function removeSubject(obj,subjectIndexNumber) % remove a subject from the database
            if (obj.numSubjects < subjectIndexNumber) % subject number must be valid
                disp(['Subject Index #' num2str(subjectIndexNumber) ' is not in this database.']);
            else
                obj.subjects(subjectIndexNumber) = []; % deletes that cell and resizes subject array
                disp(['Subject Index #' num2str(subjectIndexNumber) ' removed from database. Database re-indexed.']);
                obj.list();
            end
        end
        function list(obj) % lists off all subjects in the database
            if length(obj.healthySubject) == 0
                disp('No healthy subject info');
            else % display healthy subject info
                
                fprintf('\t%s\n\t%s\t%s\t%s\t%s\t%s\t%s\n' ,'Healthy Subject in database:','Index','ID','StimLvl','TestPts','Init.','Status'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\n' ,'-------','-------','-------','-------','-------','-------'); 
                indexNumber = 1;
                vals = {indexNumber,...
                        obj.healthySubject{indexNumber}.ID,... 
                        obj.healthySubject{indexNumber}.stimLvl,... 
                        obj.healthySubject{indexNumber}.numTestPoints,... 
                        obj.healthySubject{indexNumber}.initials,... 
                        obj.healthySubject{indexNumber}.status};
                    fprintf('\t%d\t%s\t%s\t%d\t%s\t%s\n\n',vals{:});
                
            end
            
            if ~obj.numSubjects % dont display if empty database
                disp('No subjects in database.');
            else % compile output display
                
                fprintf('\t%s\n\t%s\t%s\t%s\t%s\t%s\t%s\n' ,'Subjects in database:','Index','ID','StimLvl','TestPts','Init.','Status'); % list headers
                fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\n' ,'-------','-------','-------','-------','-------','-------'); 
                for indexNumber = 1:obj.numSubjects % print out index number and subject ID number, etc
                    vals = {indexNumber,...
                        obj.subjects{indexNumber}.ID,... 
                        obj.subjects{indexNumber}.stimLvl,... 
                        obj.subjects{indexNumber}.numTestPoints,... 
                        obj.subjects{indexNumber}.initials,... 
                        obj.subjects{indexNumber}.status};
                    fprintf('\t%d\t%s\t%s\t%d\t%s\t%s\n',vals{:});
                end
            end
        end
        function corrSubj = correlateSubjects(obj,subjectIndexNumber1,subjectIndexNumber2,testPointIndex1,testPointIndex2)
            if nargin == 3
                % look at first testpoints, if not specified
                testPointIndex1 = 1;
                testPointIndex2 = 1;
            end
            corrSubj = obj.subjects{subjectIndexNumber1}.correlationBetweenSubjects(obj.subjects{subjectIndexNumber2},testPointIndex1,testPointIndex2);
        end
        function [baselineCorr,twoWeeksCorr, labels] =  correlateHealthy_subject(obj,subjectIndexNumber)
            % finds correlation to healthy subject for specific subjects
            if length(obj.healthySubject) == 0
                disp('No healthy subject listed.')
                return
            end
            if (obj.numSubjects < subjectIndexNumber) % subject number must be valid
                disp(['Subject Index #' num2str(subjectIndexNumber) ' is not in this database.']);
                return
            end
            baselineCorr_all = obj.healthySubject{1}.correlationBetweenSubjects(obj.subjects{subjectIndexNumber},1,1); % baseline
            twoWeeksCorr_all = obj.healthySubject{1}.correlationBetweenSubjects(obj.subjects{subjectIndexNumber},1,2); % 2 weeks
            for i = 1:length(baselineCorr_all)
                baselineCorr(i,1) = baselineCorr_all{i,1}(1,2);
                twoWeeksCorr(i,1) = twoWeeksCorr_all{i,1}(1,2);
            end
            for i = 1:12
                labels{i} = baselineCorr_all{i,2};
            end
            
        end
        function [baselineCorr,twoWeekCorr, labels] = correlateHealthy(obj)
            % finds correlation to healthy subject for all subjects
            for i = 1:obj.numSubjects
                [base, twoWeek, labels] = obj.correlateHealthy_subject(i);
                baselineCorr(:,i) = base(:,1);
                twoWeekCorr(:,i) = twoWeek(:,1);
            end
        end
        function plotDGIvsCorr(obj,DGI)
            % DGI must be matrix, eg. [subj1_dgi_baseline subj1_dgi_twoWeeks; subj2_dgi_baseline subj2_dgi_twoWeeks]
            if nargin == 1
                display('Must provide DGI data. eg. [subj1_dgi_baseline subj1_dgi_twoWeeks; subj2_dgi_baseline subj2_dgi_twoWeeks]');
                return
            end
            
            [baselineCorr,twoWeekCorr, labels] = obj.correlateHealthy;
             
             figure('Name','DGI vs Correlation')
             set(gcf,'color','w');
             for subj = 1:obj.numSubjects
                 for j = 1:6 % right leg
                     subplot(6,2,2*j);
                     hold on
                     % first plot the straight line
                     plot(DGI(subj,:),[baselineCorr(j,subj),twoWeekCorr(j,subj)],'LineStyle','-','Color','k');
                     % Then plot an invisible line, with circles as endpoints
                     h = plot(DGI(subj,1),baselineCorr(j,subj),'o',DGI(subj,2),twoWeekCorr(j,subj),'o'); % filled and open circle
                     % set first circle as filled
                     set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
                     % set second circle as empty
                     set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
                     hold off
                     title(labels(j))
                     ylim(tbiNMBL.constants_tbiNMBL.dgiPlotYAxisLimits);
                     xlim(tbiNMBL.constants_tbiNMBL.dgiPlotXAxisLimits);
                 end
                 for j = 1:6 % left leg
                     subplot(6,2,2*j-1);
                     hold on
                     plot(DGI(subj,:),[baselineCorr(6+j,subj),twoWeekCorr(6+j,subj)],'LineStyle','-','Color','k');
                     h = plot(DGI(subj,1),baselineCorr(6+j,subj),'o',DGI(subj,2),twoWeekCorr(6+j,subj),'o'); % filled and open circle
                     set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
                     set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
                     hold off
                     title(labels(6+j))
                     ylim(tbiNMBL.constants_tbiNMBL.dgiPlotYAxisLimits);
                     xlim(tbiNMBL.constants_tbiNMBL.dgiPlotXAxisLimits);
                 end
             end
             
             % create legend
            hold on
            % plot a fake point, otherwise its a hassle trying to keep track of all the plots looped on top of each other when forming a legend
            h(1) = plot(NaN,NaN,'o');
            h(2) = plot(NaN,NaN,'o');
            hold off
            set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
            set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
            testPoint_strings = {'Baseline','Two Weeks'};
            %set(h(:),'linewidth',2);
            h = legend(h(:),testPoint_strings);
            set(h,'Position',tbiNMBL.constants_tbiNMBL.legendPosition);
            set(h,'Box','on','Orientation','horizontal','FontSize',12);
            
            % create title that goes over all the subplots
            suptitle(['DGI vs Healthy Correlation']);
            
             
        end
        function [rBASELINE, rTWOWEEKS] = plotDGIvsCorr_muscle(obj,muscleNumber,DGI,compareValuesBASELINE,compareValuesTWOWEEKS)
            % DGI must be matrix, eg. [subj1_dgi_baseline subj1_dgi_twoWeeks; subj2_dgi_baseline subj2_dgi_twoWeeks]
            % muscleNumber = 1-6, specifying muscle (TA - SEMI)
            
            
            % extract healthy subject emg curve for that muscle
            emgMuscle_healthy1 = obj.healthySubject{1}.testPoints{1}.trials{1}.emgData(:,muscleNumber);
            emgMuscle_healthy2 = obj.healthySubject{1}.testPoints{1}.trials{1}.emgData(:,muscleNumber+6);
            emgMuscle_healthy = mean([emgMuscle_healthy1,emgMuscle_healthy2]')';
            
            
            % compute correlation to healthy subject at Baseline
            for i = 1:obj.numSubjects
                
                % extract subject emg curve for specified muscle
                if compareValuesBASELINE(i) == 0 % average the emg data for both sides
                    emgMuscle1 =  obj.subjects{i}.testPoints{1}.trials{1}.emgData(:,muscleNumber);
                    emgMuscle2 =  obj.subjects{i}.testPoints{1}.trials{1}.emgData(:,muscleNumber+6);
                    emgMuscle = mean([emgMuscle1,emgMuscle2]')';
                elseif compareValuesBASELINE(i) == 1 % just look at right leg
                    emgMuscle = obj.subjects{i}.testPoints{1}.trials{1}.emgData(:,muscleNumber);
                elseif compareValuesBASELINE(i) == -1 % just look at left leg
                    emgMuscle = obj.subjects{i}.testPoints{1}.trials{1}.emgData(:,muscleNumber+6);
                end
                
                % compute correlation coefficient, store
                R_mat = corrcoef(emgMuscle_healthy,emgMuscle);
                rBASELINE(i) = R_mat(1,2);
            end
            % compute correlation to healthy subject at two weeks
            for i = 1:obj.numSubjects
                
                % extract subject emg curve for specified muscle
                if compareValuesTWOWEEKS(i) == 0 % average the emg data for both sides
                    emgMuscle1 =  obj.subjects{i}.testPoints{2}.trials{1}.emgData(:,muscleNumber);
                    emgMuscle2 =  obj.subjects{i}.testPoints{2}.trials{1}.emgData(:,muscleNumber+6);
                    emgMuscle = mean([emgMuscle1,emgMuscle2]')';
                elseif compareValuesTWOWEEKS(i) == 1 % just look at right leg
                    emgMuscle = obj.subjects{i}.testPoints{2}.trials{1}.emgData(:,muscleNumber);
                elseif compareValuesTWOWEEKS(i) == -1 % just look at left leg
                    emgMuscle = obj.subjects{i}.testPoints{2}.trials{1}.emgData(:,muscleNumber+6);
                end
                
                % compute correlation coefficient, store
                R_mat = corrcoef(emgMuscle_healthy,emgMuscle);
                rTWOWEEKS(i) = R_mat(1,2);
            end
            
            rBASELINE = rBASELINE';
            rTWOWEEKS = rTWOWEEKS';
            
            figure('Name',['MUSCLE: ' num2str(muscleNumber) ', DGI vs Correlation'])
            set(gcf,'color','w');
             for subj = 1:obj.numSubjects
                 
                 
                     hold on
                     plot(DGI(subj,:),[rBASELINE(subj),rTWOWEEKS(subj)],'LineStyle','-','Color','k');
                     h = plot(DGI(subj,1),rBASELINE(subj),'o',DGI(subj,2),rTWOWEEKS(subj),'o'); % filled and open circle
                     set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
                     set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
                     hold off
                     %title(labels(j))
                     ylim(tbiNMBL.constants_tbiNMBL.dgiPlotYAxisLimits);
                     xlim(tbiNMBL.constants_tbiNMBL.dgiPlotXAxisLimits);
             end
      
                          
             % create legend
            hold on
            h(1) = plot(NaN,NaN,'o');
            h(2) = plot(NaN,NaN,'o');
            hold off
            set(h(1),'MarkerEdgeColor','none','MarkerFaceColor','k')
            set(h(2),'MarkerEdgeColor','k','MarkerFaceColor','none')
            testPoint_strings = {'Pre','Post'};
            %set(h(:),'linewidth',2);
            h = legend(h(:),testPoint_strings);
            set(h,'Position',tbiNMBL.constants_tbiNMBL.legendPosition);
            set(h,'Box','on','FontSize',12); %'Orientation','horizontal'
            
            % title 
            suptitle(['MUSCLE : ' num2str(muscleNumber) ', DGI vs Healthy Correlation']);
        end
        function compareHealthyPlots(obj,subjectIndexNumber)
            if length(obj.healthySubject) == 0
                disp('No healthy subject listed.')
                return
            end
            if (obj.numSubjects < subjectIndexNumber) % subject number must be valid
                disp(['Subject Index #' num2str(subjectIndexNumber) ' is not in this database.']);
                return
            end
            
            
            %subj.testPoints{testPointIndex(i)}.displayEmgTrials(checkEmgLabels, trialIndex(i));
            figure('Name','Compare Healthy')
            set(gcf,'color','w');
            tr = obj.healthySubject{1}.testPoints{1}.trials{1};
            basetr = obj.subjects{subjectIndexNumber}.testPoints{1}.trials{1};
            twoweektr = obj.subjects{subjectIndexNumber}.testPoints{2}.trials{1};
            plotColorIndex = 1;
            for j=1:6 % RIGHT LEG
                subplot(6,2,2*j); % plots on right half of figure
                hold on
                area([0:100]',tr.emgData(:,j),'LineStyle','none','FaceColor',tbiNMBL.constants_tbiNMBL.emgAreaColors{plotColorIndex});
                plot([0:100]',basetr.emgData(:,j),'LineStyle','--','color','k','LineWidth',1);
                plot([0:100]',twoweektr.emgData(:,j),'color','k','LineWidth',1);
                hold off
                title(tr.emgLabel(j));
                ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
                xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
            end
            for j=1:6 % LEFT LEG
                subplot(6,2,2*j-1); % plots on left half of figure
                hold on
                area([0:100]',tr.emgData(:,6+j),'LineStyle','none','FaceColor',tbiNMBL.constants_tbiNMBL.emgAreaColors{plotColorIndex});
                plot([0:100]',basetr.emgData(:,6+j),'LineStyle','--','color','k','LineWidth',1);
                plot([0:100]',twoweektr.emgData(:,6+j),'color','k','LineWidth',1);
                hold off
                title(tr.emgLabel(6+j));
                ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
                xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
            end 
            
                
            % create legend
            hold on
            handle(1) = plot(NaN,NaN,'color',tbiNMBL.constants_tbiNMBL.emgAreaColors{1});
            handle(2) = plot(NaN,NaN,'LineStyle','--','color','k','LineWidth',1);
            handle(3) = plot(NaN,NaN,'LineStyle','-','color','k','LineWidth',1);
            hold off
            testPoint_strings = {'Healthy','Baseline','Two Weeks'};
            set(handle(:),'linewidth',2);
            h = legend(handle(:),testPoint_strings);
            set(h,'Position',tbiNMBL.constants_tbiNMBL.legendPosition);
            set(h,'Box','on','Orientation','horizontal','FontSize',12);
            
            % title 
            suptitle(['Subject ' obj.subjects{subjectIndexNumber}.ID ', Compared to Healthy ']);
            
            % just look at plantar flexors
            figure('Name','Plantar Flexors')
            set(gcf,'color','w');
            subplot(2,1,1)
            j = 8;
            hold on
            %area([0:100]',tr.emgData(:,j),'LineStyle','none','FaceColor',tbiNMBL.constants_tbiNMBL.emgAreaColors{plotColorIndex});
            shadedErrorBar([0:100]',tr.emgData(:,j),tr.emgStd(:,j),{'color',tbiNMBL.constants_tbiNMBL.emgAreaColors{plotColorIndex}},tbiNMBL.constants_tbiNMBL.transparentErrorBars);
            plot([0:100]',basetr.emgData(:,j),'LineStyle','--','color','k','LineWidth',2);
            plot([0:100]',twoweektr.emgData(:,j),'color','k','LineWidth',2);
            hold off
            title(tr.emgLabel(j));
            ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
            xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
            subplot(2,1,2)
            j = 9-6;
            hold on
            %area([0:100]',tr.emgData(:,j),'LineStyle','none','FaceColor',tbiNMBL.constants_tbiNMBL.emgAreaColors{plotColorIndex});
            shadedErrorBar([0:100]',tr.emgData(:,j),tr.emgStd(:,j),{'color',tbiNMBL.constants_tbiNMBL.emgAreaColors{plotColorIndex}},tbiNMBL.constants_tbiNMBL.transparentErrorBars);
            plot([0:100]',basetr.emgData(:,j),'LineStyle','--','color','k','LineWidth',2);
            plot([0:100]',twoweektr.emgData(:,j),'color','k','LineWidth',2);
            hold off
            title(tr.emgLabel(j));
            ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
            xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
            
            % create legend
            hold on
            handle(1) = plot(NaN,NaN,'color',tbiNMBL.constants_tbiNMBL.emgAreaColors{1});
            handle(2) = plot(NaN,NaN,'LineStyle','--','color','k','LineWidth',1);
            handle(3) = plot(NaN,NaN,'LineStyle','-','color','k','LineWidth',1);
            hold off
            testPoint_strings = {'Healthy','Pre','Post'};
            set(handle(:),'linewidth',2);
            h = legend(handle(:),testPoint_strings);
            set(h,'Position',tbiNMBL.constants_tbiNMBL.legendPosition);
            set(h,'Box','on','FontSize',12);
            
            
        end
    end
    methods % used for set and get methods
        function numSubj = get.numSubjects(obj) % calculate the number of test points stored
            numSubj = length(obj.subjects);
        end
        function set.numSubjects(obj,~) % cant set dependent number of test points
            fprintf('%s%d\n','numSubjects is: ',obj.numSubjects)
            error('You cannot set the numSubjects property');
        end
    end
    
end

