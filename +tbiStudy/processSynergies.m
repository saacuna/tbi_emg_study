% Filename: processSynergies.m
% Author:   Samuel Acuña
% Date:     12 Jun 2018
% Description: construct synergies from the EMG data, to be used in further
% analysis
%
%
%
clear; close all; clc;

% trialType = {'overground','treadmill22','treadmill28','treadmill34'}; % find synergies for healthy subjects
trialType = {'baseline', 'overground','preferred'}; % find synergies for TBI subjects

% STEP 1: load subjects data
for tt = 1%:length(trialType)
    %sqlquery = ['select * from trials_healthy where trialType = "' trialType{tt} '" order by subject_id'];
    sqlquery = ['select * from trials where trialType = "' trialType{tt} '" order by subject_id,  testPoint'];
    %sqlquery = ['select * from trials where trialType = "' trialType{tt} '" and filename_SYN is null order by subject_id,  testPoint'];
    disp(['query: ' sqlquery]);
    querydata = tbiStudy.load(sqlquery);
    
    [rows, ~] = size(querydata);
    tr_temp = [];
    dfl_temp = cell(rows,1);
    for i = 1:rows %iteratively load queried trials into structure
        dataFileLocation = querydata{i,4}; % load relative file location
        dataFileLocation = [tbiStudy.constants.dataFolder dataFileLocation]; % create absolute file location
        filename = querydata{i,7}; % load EMG data
        load([dataFileLocation filename]);
        tr_temp = [tr_temp; tr];
        dfl_temp{i} = dataFileLocation;
    end
    tr = tr_temp;
    dataFileLocation = dfl_temp;
    clear filename i querydata sqlquery tr_temp dfl_temp rows
    
    
    
    % STEP 2: solve for synergies
    emg_type = {'avg_peak','avg_unitVar','concat_peak','concat_unitVar'};
    emg_dataType = {'emgData','emgData_scaledUnitVariance','emgConcat','emgConcat_scaledUnitVariance'};
    % 1. SYNERGIES FROM AVERAGE STRIDE, SCALED TO PEAK
    % 2. SYNERGIES FROM AVERAGE STRIDE, SCALED TO UNIT VARIANCE
    % 3. SYNERGIES FROM CONCATENATED STRIDES, SCALED TO PEAK
    % 4. SYNERGIES FROM CONCATENATED STRIDES, SCALED TO UNIT VARIANCE
    leg = {'right','left','both'};
    region = {[1:6],[7:12],[1:12]};
    synergy_region = {[1:3],[1:3],[1:3]}; % {[1:6],[1:6],[1:12]}; % doing all 12 was taking way too long. Just do 6 for now.
    
    for i = 1:length(tr)
        clear syn
        
        % subject info
        syn.subject_type = tr(i).subject_type;
        syn.subject_id = tr(i).subject_id;
        syn.testPoint = tr(i).testPoint;
        syn.trialType = tr(i).trialType;
        syn.filename = [syn.subject_type sprintf('%02d',syn.subject_id) '_tp' sprintf('%02d',syn.testPoint) '_' syn.trialType '_SYN'];
        
        disp(['Constructing synergies for ' syn.subject_type sprintf('%02d',syn.subject_id) '_tp' sprintf('%02d',syn.testPoint) '_' syn.trialType ':']);
        
        % Maybe add a 20 Hz filter to clean up discontinuties from removing the EMG spikes. But
        % I dont think filtering will change the results that much.
        %[b_LP,a_LP]=butter(4,20/(100/2),'low');
        
        % if already processed part of the data, reload the data:
        if exist(fullfile([dataFileLocation{i} syn.filename '.mat']),'file')
            load(fullfile([dataFileLocation{i} syn.filename '.mat']));
            disp('You have already processed some of this data. Are you sure you want to proceeed? You dont want to repeat things.');
            disp('1: yes 2:skip this trial');
            answer = input('Input: ','s');
            if answer ~= 1
                disp('Aborting, and continuing to next trial to analyze.');
                continue;
            end
        end
        
        % synergy constructions: create A matrix [m x t]
        syn1.(emg_type{1}).(leg{1}).A = tr(i).(emg_dataType{1})(:,region{1})'; % SYNERGIES FROM AVERAGE STRIDE, SCALED TO PEAK
        syn1.(emg_type{1}).(leg{2}).A = tr(i).(emg_dataType{1})(:,region{2})';
        syn1.(emg_type{1}).(leg{3}).A = tr(i).(emg_dataType{1})(:,region{3})';
        syn1.(emg_type{2}).(leg{1}).A = tr(i).(emg_dataType{2})(:,region{1})'; % SYNERGIES FROM AVERAGE STRIDE, SCALED TO UNIT VARIANCE
        syn1.(emg_type{2}).(leg{2}).A = tr(i).(emg_dataType{2})(:,region{2})';
        syn1.(emg_type{2}).(leg{3}).A = tr(i).(emg_dataType{2})(:,region{3})';
        syn1.(emg_type{3}).(leg{1}).A = [tr(i).(emg_dataType{3}){region{1}}]'; % SYNERGIES FROM CONCATENATED STRIDES, SCALED TO PEAK
        syn1.(emg_type{3}).(leg{2}).A = [tr(i).(emg_dataType{3}){region{2}}]';
        syn1.(emg_type{4}).(leg{1}).A = [tr(i).(emg_dataType{4}){region{1}}]'; % SYNERGIES FROM CONCATENATED STRIDES, SCALED TO UNIT VARIANCE
        syn1.(emg_type{4}).(leg{2}).A = [tr(i).(emg_dataType{4}){region{2}}]';
        if tr(i).nStrides_left == tr(i).nStrides_right % ensure each leg has same number of strides
            syn1.(emg_type{3}).(leg{3}).A = [tr(i).(emg_dataType{3}){region{3}}]'; % SYNERGIES FROM CONCATENATED STRIDES, SCALED TO PEAK
            syn1.(emg_type{4}).(leg{3}).A = [tr(i).(emg_dataType{4}){region{3}}]'; % SYNERGIES FROM CONCATENATED STRIDES, SCALED TO UNIT VARIANCE
        elseif tr(i).nStrides_left > tr(i).nStrides_right % remove stride from left leg
            if (tr(i).nStrides_left - tr(i).nStrides_right == 1) % remove one stride
            temp = [tr(i).(emg_dataType{3}){region{2}}]; % L
            syn1.(emg_type{3}).(leg{3}).A = [tr(i).(emg_dataType{3}){region{1}} temp(1:end-100,:)]';
            temp = [tr(i).(emg_dataType{4}){region{2}}];
            syn1.(emg_type{4}).(leg{3}).A = [tr(i).(emg_dataType{4}){region{1}} temp(1:end-100,:)]';
            clear temp
            else % remove multiple strides.  Pause here in debugger and manually set the correct regions.
                disp('The accelerometers cut out and there is not an even number of strides.  Pause here in debugger and manually set the correct regions. For now, we skip it.');
                continue; % comment this out if debugging
            end
        else % remove stride from right leg
            if (tr(i).nStrides_right - tr(i).nStrides_left == 1) % remove one stride
            temp = [tr(i).(emg_dataType{3}){region{1}}];
            syn1.(emg_type{3}).(leg{3}).A = [temp(1:end-100,:) tr(i).(emg_dataType{3}){region{2}}]';
            temp = [tr(i).(emg_dataType{4}){region{1}}];
            syn1.(emg_type{4}).(leg{3}).A = [temp(1:end-100,:) tr(i).(emg_dataType{4}){region{2}}]';
            clear temp
            else % remove multiple strides. Pause here in debugger and manually set the correct regions.
                continue;
                disp('The accelerometers cut out and there is not an even number of strides.  Pause here in debugger and manually set the correct regions. For now, we skip it.');
                continue; % comment this out if debugging
                % for tbi13_tp06_overground: A = [temp(501:end,:) tr(i).(emg_dataType...
                % for tbi15_tp02_overground: A = [temp(1101:end,:) tr(i).(emg_dataType...
                % for tbi17_tp01_overground: A = [temp(501:end,:) tr(i).(emg_dataType...
                % for tbi18_tp01_overground: A = [temp(601:end-100,:) tr(i).(emg_dataType...
            end
        end
        
        for j = 1:length(emg_type) % cycle through EMG data types
            for k = 1:length(leg) % cycle through leg selection
                for n = synergy_region{k} % cycle through number of synergies
                    disp(['     processing ' emg_type{j} ' for ' leg{k} ' legs using ' num2str(n) ' synergies...']);
                    clear A;
                    A = syn1.(emg_type{j}).(leg{k}).A;
                    [W, C, err] = NNMF_stacie_May2013(A,n); %nnmf (non negative matrix factorization)
                    RECON = W*C; % reconstructed signal
                    VAF = 1-sumsqr(A-RECON)/sumsqr(A); % Variance Accounted For  (steele2015, de Rugy 2013)
                    VnAF = 1-VAF; % Variance NOT Accounted For
                    [VAF_activations, VAF_weights, VAF2] = funur(A,W,C); %calculate VAF of reconstruction
                    
                    % save data
                    syn.(emg_type{j}).(leg{k}).W{n} = W;
                    syn.(emg_type{j}).(leg{k}).C{n} = C;
                    syn.(emg_type{j}).(leg{k}).err{n} = err;
                    % syn.(emg_type{j}).(leg{k}).RECON{n} = RECON; % Not saving this variable to save space in hard drive, but can easily create it by W*C
                    syn.(emg_type{j}).(leg{k}).VAF{n} = VAF;
                    syn.(emg_type{j}).(leg{k}).VnAF{n} = VnAF;
                    % syn.(emg_type{j}).(leg{k}).VAF_activations{n} = VAF_activations; % Not saving this variable to save space in hard drive % this doesn't seem a helpful metric, It is equivalent to VAFmus, but shows VAF for each point in the activation time series
                    syn.(emg_type{j}).(leg{k}).VAF_weights{n} = VAF_weights;
                    syn.(emg_type{j}).(leg{k}).VAF2{n} = VAF2;
                    clear W C err RECON VAF VnAF VAFcond VAFmus VAF2
                    disp('     done.');
                end
            end
            syn.(emg_type{j}).A = A; % save variable A at this point, which should have all 12 original signals here.
        end
        
        
        %% STEP 3: save synergies to file
        save([dataFileLocation{i} syn.filename],'syn');
        disp(['Synergy data saved as: ' syn.filename]);
        disp(['in folder: ' dataFileLocation{i}]);
        tbiStudy.appendTrialInDatabase(syn);
        
    end
end







%% PROCESSING FUNCTIONS
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
% Original function name: NNMF_stacie_May2013.m
% Created: May 14, 2013 by SAC
% Last modified: 12 Jun 2018 by Samuel Acuña
% Last modification: adjusted flags so you dont have to scale data

if nargin < 3
    flag = 0;
end

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
if flag ==1
    stdev = std(Vnew'); %scale the data to have unit variance of this data set
    Vnew = diag(1./stdev)*Vnew;
elseif flag ==2;
    %global stdev % use this if you want to use the stdev (unit variance scaling) from a different data set
    % Vnew = diag(1./stdev)*Vnew;
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts = statset('MaxIter',1000,'TolFun',1e-6,'TolX',1e-4);
[W,H,err] = nnmf(Vnew,r,'alg','mult','rep',50,'options',opts);
% [W,H,err] = nnmf(Vnew,r,'alg','mult','rep',50);


% Re-scale the original data and the synergies; add in zero rows; calculate
% final error.

%undo the unit variance scaling so synergies are back out of unit variance
%space and in the same scaling as the input data was
if flag == 1
    Vnew = diag(stdev)*Vnew;
    W = diag(stdev)*W;
end


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
[URcond]=rsqr_uncentered(data',ReconData');
URcond=100*(URcond);

%Calculate error in the reconstruction of each muscle activity level
%URmus(nmus x 1)
[URmus]=rsqr_uncentered(data,ReconData);
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