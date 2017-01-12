classdef synergies
    % Filename: synergies.m
    % Author:   Samuel Acuna
    % Date:     10 Jan 2017
    % Description:
    %
    % 
    %
    % Example Usage:
    %
    
    methods (Static)
        function syn = calcSynergies(A,n)
            % INPUTS:
            %   A = observed muscle activations [m x t]
            %       where m = # of muscles, t = points in time
            %   n = number of synergies to solve for
            % OUTPUTS:
            %   syn = structure containing nnmf results
            
            
            syn.n = n; % the number of synergies
            syn.A = A; % original signal data
            [syn.W, syn.C, syn.err, syn.stdev] = tbiStudy.synergies.NNMF_stacie_May2013(A,n,1); %nnmf
            syn.RECON = syn.W*syn.C; % reconstructed signal
            syn.VAF = 1-sumsqr(syn.A-syn.RECON)/sumsqr(syn.A); % steele2015, de Rugy 2013
            [syn.VAFcond, syn.VAFmus, syn.VAF2] = tbiStudy.synergies.funur(A,syn.W,syn.C); %calculate VAF of reconstruction
            
        end
        % function for multiple synergies
        % function fo bootstrapping VAF to get Confidence Intervals
        function tr = calcHealthySynergies(n,trialTypeNumber)
            % INPUTS:
            %               n = number of synergies to solve for
            % trialTypeNumber = number specifying which trialtype (see tbiStudy.constants.trialType)
            
            % load healthy trial data
            tr = tbiStudy.load.healthy(trialTypeNumber);
           
            % FINISH FROM HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
        end
        function [A,W,C] = generateTestSignals(m,n)
            % this function is just to test the accuracy of my synergy
            % analysis. It also generates simple test signals for running through
            % my analysis code
            
            %%%%%%%%%%%
            % 1. Create *true* synergies (W) and relative activations (C)
            
            % W is [m x n], where 
            %   m = # of muscles
            %   n = specified # of synergies
            W = randi(10,m,n)/10;
            
            % C is [n x t], where
            % 	t = # of time points (101 for a gait cycle)
            t = 0:0.01:1;
            C = zeros(n,length(t));
            for i = 1:n
                C(i,:) = sin(t*randi(50))+1;
            end 
            
            % plot *true* W and C
            nPlots = 1+n;
            figure
            subplot(nPlots,1,1); bar(W); xlabel('Muscle Number'); ylabel('W (Synergy Weight)');
            for i = 1:n
                subplot(nPlots,1,i+1); plot(C(i,:)); xlabel('Gait Cycle'); ylabel(['C' num2str(i) ' (activation)']);
            end
            
            %%%%%%%%%%%
            % 2. Generate *true* mapped signals
            A = W*C;
            
            % optionally, add noise to mapped signals
            %A = A+rand(size(A))*0.5;
            
            % plot *true* mapped signals
            figure
            for i = 1:m
                subplot(m,1,i); plot(A(i,:)); xlabel('Gait Cycle'); ylabel(['A' num2str(i)]); title(['Muscle ' num2str(i)]);
            end
            suptitle('Observed Signals');
            
            
            % look at specific muscle contribution
            muscle = 1;
            A_muscle = W(muscle,:)*C;
            figure
            for i = 1:n
                subplot(n+1,1,i); plot(W(muscle,i)*C(i,:)); xlabel('Gait Cycle'); ylabel('contribution');
            end
            subplot(n+1,1,n+1); plot(A_muscle);  xlabel('Gait Cycle'); ylabel('Total Activation');
            suptitle(['Muscle ' num2str(muscle)]);
        end
        
    end % public methods
    
    methods (Static, Access = private)
        function [W,H,err,stdev] = NNMF_stacie_May2013(V,r,flag)
            % NNMF: Given a nonnegative matrix V, NNMF finds nonnegative matrix W
            %       and nonnegative coefficient matrix H such that V~WH.
            %       The algorithm solves the problem of minimizing (V-WH)^2 by varying W and H
            %       Multiplicative update rules developed by Lee and Seung were used to solve
            %       optimization problem. (see reference below)
            %          D. D. Lee and H. S. Seung. Algorithms for non-negative matrix
            %          factorization. Adv. Neural Info. Proc. Syst. 13, 556-562 (2001)
            % Input:
            %
            % V Matrix of dimensions n x m  Nonnegative matrix to be factorized
            % r Integer                     Number of basis vectors to be used for factorization
            %                               usually r is chosen to be smaller than n or m so that
            %                               W and H are smaller than original matrix V
            % flag                flag == 1; scale the input data to have unit variance
            %                     flag == 2; scale the input data to the unit variance scaling of a different data set
            %
            % Output:
            %
            % W    Matrix of dimensions n x r  Nonnegative matrix containing basis vectors
            % H    Matrix of dimensions r x m  Nonnegative matrix containing coefficients
            % err  Integer                     Least square error (V-WH)^2 after optimization convergence
            %
            % Created: May 14, 2013 by SAC
            % Last modified:
            % Last modification:
            
            V = V.*(V>0); % Any potential negative entrie in data matrix will be set to zero
            
            test=sum(V,2); % Any potential muscle channnel with only zeros is not included in the iteration
            index=find(test~=0);
            ind=find(test==0);
            Vnew_m=V(index,:);
            
            test_cond=sum(V,1); % Any potential condition with only zeros is not included in the iteration
            index_cond=find(test_cond~=0);
            ind_cond=find(test_cond==0);
            Vnew=Vnew_m(:,index_cond);
            
            %If attempting to extract more synergies than remaining
            %muscles, extract only the number of synergies equal to number of muscles
            [nummus,dum]=size(Vnew);
            if r>nummus
                difference=r-nummus;
                rtemp=r-difference;
                r=rtemp;
            end
            
            % Scale the input data to have unit variance %%%%%%%%%
            if flag ==1;
                stdev = std(Vnew'); %scale the data to have unit variance of this data set
            elseif flag ==2;
                %global stdev % use this if you want to use the stdev (unit variance scaling) from a different data set
            end
            
            Vnew = diag(1./stdev)*Vnew;
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            opts = statset('MaxIter',1000,'TolFun',1e-6,'TolX',1e-4);
            [W,H,err] = nnmf(Vnew,r,'alg','mult','rep',50,'options',opts);
            % [W,H,err] = nnmf(Vnew,r,'alg','mult','rep',50);
            
            
            % Re-scale the original data and the synergies; add in zero rows; calculate
            % final error.
            
            %undo the unit variance scaling so synergies are back out of unit variance
            %space and in the same scaling as the input data was
            Vnew = diag(stdev)*Vnew;
            W = diag(stdev)*W;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Synergy vectors normalization  %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            m=max(W);% vector with max activation values
            for i=1:r
                H(i,:)=H(i,:)*m(i);
                W(:,i)=W(:,i)/m(i);
            end
            
            
            % Set to zero the columns or rows that were not included in the iteration
            [n_o,m_o]=size(V);
            
            Hnew=[];
            Wnew=[];
            for l=1:length(ind_cond)
                if ind_cond(l)==1
                    Hnew=[zeros(r,1) H];
                    H=Hnew;
                elseif ind_cond(l)==m_o
                    Hnew=[H zeros(r,1)];
                    H=Hnew;
                else
                    for k=1:m_o
                        if ind_cond(l)==k
                            Hnew=[H(:,1:k-1) zeros(r,1) H(:,k:end)];
                            H=Hnew; break
                        else
                            Hnew=H;
                        end
                    end
                end
            end
            for l=1:length(ind)
                if ind(l)==1
                    Wnew=[zeros(1,r); W];
                    W=Wnew;
                elseif ind(l)==n_o
                    Wnew=[W; zeros(1,r)];
                    W=Wnew;
                else
                    for k=1:n_o
                        if ind(l)==k
                            Wnew=[W(1:k-1,:); zeros(1,r); W(k:end,:)];
                            W=Wnew; break
                        else
                            Wnew=W;
                        end
                    end
                end
            end
        end %NNMF_stacie_May2013.m
        function [URcond, URmus, UR] = funur(data,W,C)
            %[URcond, URmus, UR]=funur(data,w,c)
            % This function calculates uncentered correlation coefficients of data and
            % reconstructed data = WC
            % W and C are used to generate the reconstructed data (recdat= W*C)
            % It determines the mean error in the overall reconstruction (UR)
            % It determines the error in the reconstruction of each muscle tuning
            % curve (URmus) and each muscle activation pattern for every single
            % perturbation direction (URcond)
            % Input:
            %       data    matrix of observed data  (e.g., data=[mus pert_dir])
            %       W       matrix of synergy vectors
            %       C       matrix of coefficiens
            % Output:
            %       URcond   matrix with error % for each condition(e.g., error= [pert_dir error])
            %       URmus    matrix with error % for each muscle (e.g., error= [mus error])
            %       UR       matrix with overall error
            % called functions:
            %       rsqr_uncentered.m
            %
            %
            % this function is called by:
            %       plot_syn.m
            %       plot_syn3D.m
            %
            % Written by: GTO May 24th, 2006
            % Last modified:
            %
            %
            
            [nmuscles ncond]=size(data);
            [nsyn ndum]=size(C);
            
            %Calculate reconstructed values
            ReconData=W*C;
            
            %Make fake reconstructed data with 70% error in the prediction
            %ReconData=data.*1.7;
            
            %Calculate error in the reconstruction of each direction
            %URcond(1 x nconditions)
            [URcond]=tbiStudy.synergies.rsqr_uncentered(data',ReconData');
            URcond=100*(URcond);
            
            %Calculate error in the reconstruction of each muscle activity level
            %URmus(nmus x 1)
            [URmus]=tbiStudy.synergies.rsqr_uncentered(data,ReconData);
            URmus=100*(URmus);
            
            %Calculate overall variability(1x1)
            X=cat(3,data,ReconData);
            UR=(sum(sum(prod(X,3))))^2/(sum(sum(data.^2))*sum(sum(ReconData.^2)));
            UR=100*UR;
        end
        function ursqr = rsqr_uncentered(data,data_rec)
            % This function calculates the uncetered correlation coefficient using "Cluster" method.
            %
            % Syntax:   r_sqr = rsqr_uncentered(data,data_rec)
            %
            % Input:
            % data      Array   matrix of observed data  (e.g., data = [mus pert_dir])
            % data_rec  Array   matrix of reconstructed/predicted data (e.g., data_rec = [mus pert_dir])
            %
            % Output:
            % ursqr     Array   matrix with uncentered correlation coefficients
            %
            % Calls:
            % std_mean0.m
            %
            % Created: May 24, 2006 (Gelsy Torres-Oviedo)
            % Last Modified: July 10, 2006 (Torrence Welch)
            % Last Modification: fix ursqr calculation
            
            % Shift dimensions for regression purposes data magnitudes in rows and data channels in columns
            warning off
            data = data';
            data_rec = data_rec';
            
            % Zar book method p. 334
            dim_data = size(data);
            for i = 1:dim_data(2)
                X = [data(:,i) data_rec(:,i)];
                n = length(X);
                ursqr(i) = sum(prod(X,2))^2 / (sum(data(:,i).^2)*sum(data_rec(:,i).^2)); %regression sum of squares/total sum of squares
            end
            
            ursqr = ursqr';
            return
        end
    end % private methods
end %classdef