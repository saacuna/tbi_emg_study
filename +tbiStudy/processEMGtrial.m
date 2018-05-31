function [tr, inpath] = processEMGtrial(inpath,infile)
% Filename: processEMGtrial.m
% Author:   Samuel Acuna
% Created:     24 May 2016
% Updated:  17 May 2018
% Description:
% This class file is used to convert EMG data from a text file into a
% matlab structure 
%
% creates either a structure of of the average gait cycle (a much smaller file)
% or concatenated steps (much larger file)
%
% --- --- --- --- --- --- ---
% INPUTS (OPTIONAL):
%   inpath: path of the EMG data
%   infile: filename of the EMG data
%
%
% The raw emg data must be in a .txt format, not .hpf
% To create the .txt version, open program 'emgworks_analysis' on collection
% computer. load .hpf into workspace, click 'Tools', 'export to text tile'. 
% 
% --- --- --- --- --- --- ---
% OUTPUTS:
% The processed Matlab file will appear in the same location as the original
% EMG .txt file. It will contain the matlab structure 'tr'
% 
%
% --- --- --- --- --- --- ---
% NOTES:
% if I need to switch select sensors for left and right leg, see section in
% calcEmgCycle function below
%
%
% --- --- --- --- --- --- ---
% EXAMPLE:
%       tr = tbiStudy.processEMGtrial(); 


%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 1: load EMG data txt file
clc; clear; close all;

if nargin < 2 % query for EMG data file
    disp('Select .txt EMG data file');
    [infile, inpath]=uigetfile('*.txt','Select input file',tbiStudy.constants.dataFolder);
    if infile == 0
        error('Canceled. No file selected');
    end
    disp(['Selected: ' infile ]);
    disp(' ');
elseif nargin == 2
    disp(['Selected: ' infile ]);
    disp(' ');
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 2: specify trial information

% setup empty trial structure
tr= struct(...
    'subject_type',[],...
    'subject_id',[],...
    'testPoint',[],...
    'trialType',[],...
    'filename',[]);
% setup empty acceleration structure
acc= struct(...
    'subject_type',[],...
    'subject_id',[],...
    'testPoint',[],...
    'trialType',[],...
    'filename',[]);
 
c = strsplit(infile,'_'); % parse out info from file name

try % subject ID
    subject_type = c{1}(1:3);
    ID = str2num(c{1}(4:end));
    disp(['Subject ID: ' num2str(ID)])
catch
    ID = setSubjectID();
end
tr(1).subject_type = subject_type;
acc(1).subject_type = subject_type;
tr(1).subject_id = ID;
acc(1).subject_id = ID;

try % testPoint
    TP = str2num(c{2}(3:end));
    assert(any(cell2mat(tbiStudy.constants.testPoint)==TP));
    disp(['Test Point: ' num2str(TP)])
catch
    TP = setTestPoint();
end
tr(1).testPoint = TP;
acc(1).testPoint = TP;

try % TrialType
    c2 = strsplit(c{3},'.');
    TT = c2{1};
    assert(any(strcmp(tbiStudy.constants.trialType,TT)));
    disp(['Trial Type: ' TT])
catch
    TT = setTrialType();
end
tr(1).trialType = TT;
acc(1).trialType = TT;
disp(' ');

% generate filenames
acc(1).filename = [tr.subject_type sprintf('%02d',tr.subject_id) '_tp' sprintf('%02d',tr.testPoint) '_' tr.trialType '_ACC'];
tr(1).filename = [tr.subject_type sprintf('%02d',tr.subject_id) '_tp' sprintf('%02d',tr.testPoint) '_' tr.trialType '_EMG'];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: generate emg, ax, ay, az data
disp('loading and converting raw EMG data into matlab friendly format.')
disp('This might take a while...')
try
    [emg, ax, ay, az] = load_emgworks(infile,inpath); % outputs = emg structure, acceleration in x,y,z
catch
    error('could not load emgworks file. Something went wrong in the load_emgworks function.');
end
disp('conversion completed.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 4: Identify steps from acceleration data
disp('Finding steps in the acceleration data...');

% filter acc: LP 25hz, detrended, and scaled -1 to 1. Only keeping Z direction for Heel strikes
[z_acc, time_acc] = filterACC(ax, ay, az);

% save acc data
acc(1).x_raw = ax; % save raw acceleration data, to use for later...
acc(1).y_raw = ay;
acc(1).z_raw = az;
acc(1).z_filt = z_acc;
acc(1).time = time_acc;
clear ax ay az time_acc

% use algorithm to detect heel strike. MUST MANUALLY VALIDATE IT IS OKAY.
[hsr, hsl, param] = findHeelStrikes(acc,tr,inpath);
% if I accidentally put accelerometers on the wrong legs, switch it here.
% hsr_temp = hsr; hsr = hsl; hsl = hsr_temp; clear hsr_temp;
%
acc(1).hsr.time = hsr.time;
acc(1).hsl.time = hsl.time;
acc(1).hsr.value = hsr.value;
acc(1).hsl.value = hsl.value;
acc(1).param = param; %peak finding parameters
clear hsr hsl;

% SAVE acc data at this point, just in case EMG processing fails, we already have heel strikes identified.
% save ACC file to original folder:
save([inpath acc.filename], 'acc');
disp(['Acceleration data saved as: ' acc.filename]);
disp(['in folder: ' inpath]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 5: filter EMG, amplitude normalize, and divide into steps (time normalize to step)
disp('Filtering (BP 10-500 Hz), rectifying, linear envelopes (10 Hz), amplitude normalizing (peaks), time normalizing into steps.');
tr(1).emgTime = emg(1).time;
[EMG_envelope, EMG_label] = filterEMG(emg); %BP filter 10-500 Hz, rectify, LP filter 10 Hz
[EMG_sorted, EMG_label_sorted] = sortEMGsignals(EMG_envelope, EMG_label); % rearrange channels to match R & L legs

% EMG_normalized = EMG_sorted./rms(EMG_sorted); % old: normalize to RMS of linear envelopes
EMG_normalized = EMG_sorted./max(EMG_sorted); % current: normalize to Peak of linear envelopes
% note: in my original analysis, I amplitude normalized the average gait
% cycle by the rms of filtered EMG (I also normalized the std of the gait
% cycle), which seems wrong now, but maybe mathematically works out.
%         for j=1:12  % Normalize the EMG data to root-mean-squared
%             emgrms(j)=rms(emgdata(:,j));
%             normemg(:,j)=(emgc(j).avg)./(emgrms(j));
%             normemgstd(:,j)=(emgc(j).sd)./(emgrms(j));
%         end


% %  here, might need to manually rearrange EMG columns if sensors were placed
% %  on the incorrect muscles

disp('Calculated EMG data by gait cycles.')
[EMG_strides,nStrides_right,nStrides_left] = findStridesEMG(tr(1).emgTime,EMG_normalized,acc(1).hsr.time,acc(1).hsl.time); % divide into steps and time normalize to 101 pts/cycle

tr(1).emgLabel = EMG_label_sorted;
tr(1).emgFreq = emg(1).freq;
tr(1).emgStrides = EMG_strides;
tr(1).nStrides_left = nStrides_left;
tr(1).nStrides_right = nStrides_right;
disp(['Number of strides [L,R]: ' num2str(nStrides_left) '  ' num2str(nStrides_right)]);
clear emg EMG_normalized hsr_time hsl_time EMG_envelope EMG_label EMG_sorted EMG_label_sorted EMG_strides nStrides_left nStrides_right;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 6: save concatentated and average EMG by steps
% created concatenated pattern across all steps
EMG_concat = cell(1,12);
for i = 1:12
    strides = size(tr.emgStrides{i}(1:100,:),2);
    EMG_concat1 = tr.emgStrides{i}(1:100,:);% cut off last time point for each step (since it is first of next step)
    EMG_concat{i} = reshape(EMG_concat1,[strides*100,1]); % reshape into single vector
    EMG_concat{i} = [EMG_concat{i}; tr.emgStrides{i}(end,end)]; % add last time point of last step
end
tr(1).emgConcat = EMG_concat;
clear EMG_concat1 EMG_concat strides;

% also find emgConcat scaled to unit variance (this undos the scaling to
% peak amplitude)
for i = 1:12
    emgConcat_scaledUnitVariance{i} = tr(1).emgConcat{i}/std(tr(1).emgConcat{i});
end
tr(1).emgConcat_scaledUnitVariance = emgConcat_scaledUnitVariance;

% find average gait cycle pattern across all steps
disp('calculating emg data over average gait cycle....');
EMG_avg = zeros(size(tr.emgStrides{1},1),12);
EMG_std = zeros(size(tr.emgStrides{1},1),12);
EMG_avg_scaledUnitVariance = zeros(size(tr.emgStrides{1},1),12);
EMG_std_scaledUnitVariance = zeros(size(tr.emgStrides{1},1),12);
for i = 1:12
    EMG_avg(:,i) = mean(tr.emgStrides{i}')'; %scaled to peak EMG
    EMG_std(:,i) = std(tr.emgStrides{i}')';
    EMG_avg_scaledUnitVariance(:,i) = EMG_avg(:,i)/std(tr(1).emgConcat{i}); %scaled to EMG unit variance
    EMG_std_scaledUnitVariance(:,i) = EMG_std(:,i)/std(tr(1).emgConcat{i});
end
tr(1).emgData = EMG_avg; % save average gait cycle
tr(1).emgStd = EMG_std;
tr(1).emgData_scaledUnitVariance = EMG_avg_scaledUnitVariance;
tr(1).emgStd_scaledUnitVariance = EMG_std_scaledUnitVariance;
clear EMG_avg EMG_std EMG_avg_scaledUnitVariance EMG_std_scaledUnitVariance emgConcat_scaledUnitVariance;

% plot average gait cycle and steps overlaid, and save to file
fig = figure(2);
plotEMG(fig,tr,inpath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 7: save EMG file to original folder
save([inpath tr.filename], 'tr');
disp(['EMG data saved as: ' tr.filename]);
disp(['in folder: ' inpath]);

%% append trial to database (temporary)
tbiStudy.appendTrialInDatabase(tr);
tbiStudy.appendTrialInDatabase(acc);
end


% processing functions
function trialType = setTrialType()
selection = listdlg('Name','Trial Type','PromptString','Select Trial Type:','SelectionMode','single','ListString',tbiStudy.constants.trialType,'ListSize',[150 75]);
if isempty(selection); error('Must specify trial type'); end; % user canceled.
trialType = tbiStudy.constants.trialType{selection};
end
function testPoint = setTestPoint()
TPchoices = num2str(cell2mat(tbiStudy.constants.testPoint)');
selection = listdlg('Name','Test Point','PromptString','Select Test Point:','SelectionMode','single','ListString',TPchoices,'ListSize',[150 75]);
if isempty(selection); error('Must specify test point'); end; % user canceled.
testPoint = tbiStudy.constants.testPoint{selection};
end
function subject_id = setSubjectID()
ID = inputdlg('Subject ID Number:','Subject ID Number',[1 60],{'01'});
try
    ID = str2num(ID{1});
catch
    error('Must specify numeric subject ID');
end;
subject_id = ID;
end
function [emg, ax, ay, az] = load_emgworks(infile,inpath)
            %   [emg,ax,ay,az]=load_emgworks(infile,inpath)
            %   LOAD_EMGWORKS is used to open a csv formateed data file generated by the emgworks
            %   software
            %
            %   Inputs
            %       infile - file to be loaded
            %       inpath - directory of location where data file is located
            %
            %   Outputs:
            %       emg   structure containing the emg data
            %       ax   structure containing the x-acc data
            %       ay   structure containing the y-acc data
            %       az   structure containing the z-acc data
            %
            %       each structure contains file name, time, and data matrix
            %       e.g.      emg.file, emg.time, emg.data
            
            fid = fopen([inpath infile],'r');
            if (fid==-1);
                disp('File not found');
                return;
            end
            
            
            % Read in the channel labels first
            line=fgetl(fid);
            nch=0; npts=0; maxpts=0;
            while (line(1:5)~='Start')
                jcolon=find(line==':');
                line(jcolon(2)+6:jcolon(2)+10);
                nch=nch+1; % count number of data channels
                ch(nch)= readhdr(line,fid,nch); 
                if (ch(nch).npts>maxpts), maxpts=ch(nch).npts;  end
                npts=npts+ch(nch).npts;
                line=fgetl(fid);
            end
            
            % Read down to start of data
            while (line(1)~='X')
                line=fgetl(fid);
            end
            
            % Read in all the data at once
            data=zeros(maxpts,2*nch);
            k=1;
            while ~feof(fid)
                line=fgetl(fid);
                % find then eliminate commas
                jc=[0 find(line==',') length(line)+1];
                line(line==',')=' ';
                % find units
                units=line(jc(2:end)-1);
                %     % now eliminate unit signs
                line(line=='m')=' ';
                line(line=='µ')=' ';
                line(line=='n')=' ';
                line(line=='p')=' ';
                line(line=='f')=' ';
                % figure out where the data goes
                kk=(diff(jc)>1);
                data(k,kk)=sscanf(line,'%f',[1 length(kk)]);
                km=(units=='m');  data(k,km)=data(k,km)*.001;
                ku=(units=='µ');  data(k,ku)=data(k,ku)*.000001;
                kn=(units=='n');  data(k,kn)=data(k,kn)*.000000001;
                kp=(units=='p');  data(k,kp)=data(k,kp)*.000000000001;
                kf=(units=='f');  data(k,kf)=data(k,kf)*.000000000000001;
                %    disp(data(k,:));
                % disp(['line ',num2str(k),' time ',num2str(data(k,1))]);
                k=k+1;
            end
            
            % Now distribute the data
            jemg=[]; jax=[]; jay=[]; jaz=[];
            for i=1:nch
                if (ch(i).sensor < 14) % emg only for sensors 1-13
                    if strcmp('EMG',ch(i).type); jemg=[jemg i]; end
                else % acceleration only for sensors 14-16
                    if strcmp('ACC X',ch(i).type); jax=[jax i]; end
                    if strcmp('ACC Y',ch(i).type); jay=[jay i]; end
                    if strcmp('ACC Z',ch(i).type); jaz=[jaz i]; end
                end
                               
                % 
                % % OPTIONAL WORKAROUND: if accleration data on R & L
                % % achilles is missing. not ideal, but we can use Tib Ant
                % % accelerometer as a workaround fix. Comment out above
                % % version of code and use this one:
                % % UPDATE: this doesnt really work. If you run this
                % % version and compare to original, it looks very
                % % different. Almost unusable
                % 
                % if (ch(i).sensor < 14) % emg only for sensors 1-13
                %     if strcmp('EMG',ch(i).type); jemg=[jemg i]; end
                % end
                % 
                % if (strcmp(ch(i).label, 'R TIBIALIS ANTERIOR') || strcmp(ch(i).label, 'L TIBIALIS ANTERIOR') || ch(i).sensor == 16)
                %     if strcmp('ACC X',ch(i).type); jax=[jax i]; end
                %     if strcmp('ACC Y',ch(i).type); jay=[jay i]; end
                %     if strcmp('ACC Z',ch(i).type); jaz=[jaz i]; end
                % end
                % 
                % END OPTIONAL WORKAROUND
            end
            
            % variable 'data' looks like this: 8 signals * 15 channels = 120 columns, 
            % the columns are: [ EMG time, EMG data, ACC time, ACC X, ACC time, ACC Y, ACC time, ACC Z ] * 15
            
            file=[inpath infile];
            emg=ch(jemg);
            for i=1:length(emg); emg(i).file=file; emg(i).time=data(1:emg(i).npts,jemg(i)*2-1);   emg(i).data=data(1:emg(i).npts,jemg(i)*2); end
            ax=ch(jax);
            for i=1:length(ax); ax(i).file=file;   ax(i).time=data(1:ax(i).npts,jax(i)*2-1);   ax(i).data=data(1:ax(i).npts,jax(i)*2); end
            ay=ch(jay);
            for i=1:length(ay); ay(i).file=file;   ay(i).time=data(1:ay(i).npts,jay(i)*2-1);   ay(i).data=data(1:ay(i).npts,jay(i)*2); end
            az=ch(jaz);
            for i=1:length(az);  az(i).file=file;  az(i).time=data(1:az(i).npts,jaz(i)*2-1);   az(i).data=data(1:az(i).npts,jaz(i)*2); end
            clear ch;
            clear data;
            fclose(fid);
            
end
function hdr = readhdr(line,fid,nch)
position = ftell(fid);
jcolon=find(line==':');
hdr.label=sscanf(line(jcolon(1)+1:jcolon(2)-1),'%s%c');
hdr.type=sscanf(line(jcolon(2)+6:jcolon(3)-1),'%s%c');
if strmatch('EMG',hdr.type(1:3)) hdr.sensor=sscanf(hdr.type(4:end),'%d');  hdr.type=hdr.type(1:3); end
if strmatch('ACC',hdr.type(1:3)) hdr.sensor=sscanf(hdr.type(6:end),'%d');  hdr.type=hdr.type(1:5);   end
hdr.freq=sscanf(line(jcolon(3)+1:end),'%f');
hdr.npts=sscanf(line(jcolon(4)+1:end),'%f');
hdr.xstart=sscanf(line(jcolon(5)+1:end),'%f');
hdr.unit=sscanf(line(jcolon(6)+1:end),'%s');
hdr.domainunit=sscanf(line(jcolon(7)+1:end),'%s');
n=0;
while(n<nch)
    line=fgetl(fid);
    if strmatch('System',line);
        n=n+1;
    end
end
jcolon=find(line==':'); hdr.sysgain=sscanf(line(jcolon+1:end),'%f');
line=fgetl(fid);    jcolon=find(line==':'); hdr.adgain=sscanf(line(jcolon+1:end),'%f');
line=fgetl(fid);    jcolon=find(line==':'); hdr.bitres=sscanf(line(jcolon+1:end),'%f');
line=fgetl(fid);    jcolon=find(line==':');	hdr.bias=sscanf(line(jcolon+1:end),'%f');
line=fgetl(fid);    jcolon=find(line==':');	hdr.hpcutoff=sscanf(line(jcolon+1:end),'%f');
line=fgetl(fid);    jcolon=find(line==':');	hdr.lpcutoff=sscanf(line(jcolon+1:end),'%f');
fseek(fid,position,'bof');
end
function [acc_output, time_acc] = filterACC(ax, ay, az)
% assuming trigno sensors attached with arrow pointing up...
% ax axis: towards head
% ay axis: toward left, when looking at subject backside
% az axis: posterior

disp('Checking order of accelerometers: (R ankle, L ankle, Lumbar)');
assert(strcmp(ax(1).label,'R ANKLE (ACC)'));
assert(strcmp(ax(2).label,'L ANKLE (ACC)'));
assert(strcmp(ax(3).label,'LUMBAR (ACC)'));

disp('filtering Acceleration.')
[bfa,afa]=butter(3,25/(ax(1).freq/2)); %Used to remove high-frequency noise above 25Hz. 3rd order butterworth

for i=1:3 
    % filter 25 hz
    %axf(:,i)=filtfilt(bfa,afa,ax(i).data);
    %ayf(:,i)=filtfilt(bfa,afa,ay(i).data);
    %azf(:,i)=filtfilt(bfa,afa,az(i).data);
    %amagf(:,i)=(axf(:,i).^2+ayf(:,i).^2+azf(:,i).^2).^0.5;
    % detrended, filter 25 hz
    %axdf(:,i)=filtfilt(bfa,afa,detrend(ax(i).data));
    %aydf(:,i)=filtfilt(bfa,afa,detrend(ay(i).data));
    azdf(:,i)=filtfilt(bfa,afa,detrend(az(i).data));
    %amagdf(:,i)=(axdf(:,i).^2+aydf(:,i).^2+azdf(:,i).^2).^0.5;
    % no filter
    %axnf(:,i) = detrend(ax(i).data); 
    %aynf(:,i) = detrend(ay(i).data);
    %aznf(:,i) = detrend(az(i).data);
    %amagnf(:,i)=(ax(i).data.^2+ay(i).data.^2+az(i).data.^2).^0.5; % unflitered acceleration magnitudes
    %amagnf2(:,i)=(axnf(:,i).^2+aynf(:,i).^2+aznf(:,i).^2).^0.5; % unflitered acceleration magnitudes
    
end

% amplitude ax normalize to max acceleration
azdf_scaled = azdf./max(azdf);

% acceleration time series
time_acc = ax(1).time; 

% Uses the magnitudes from filtered acc data and finds the peaks
% (representing heel strikes)
% OLD: using peak of magnitude of acceleration (amagf: filtered, not detrended, not scaled):
% CURRENT: using peak of Anterior-Posterior acceleration (z direction)
acc_output = azdf_scaled(:,1:2);

%% plot acceleration data, just to examine it... will need to uncomment some above values
% figure()
% for i = 1:3 
%     subplot(3,1,i);
%     %Plots the raw acc data of x,y,z for each ankle and lumbar, as dashes
%     plot(ax(1).time,[ax(i).data ay(i).data az(i).data],'--');
%     hold on;
%     %Plots the filtered acc data of x,y,z for each ankle and lumbar
%     plot(ax(1).time,[axf(:,i) ayf(:,i) azf(:,i)]);
%     hold off
%     title(ax(i).label);
%     legend('ax raw', 'ay raw', 'az raw','ax filt','ay filt','az filt');
% end

% figure() %Plots the filtered acc data of x,y,z
% xLimits = [0 5];
% i = 1;  % only R ankle
% subplot(2,1,1);
% plot(ax(1).time,[axf(:,i) ayf(:,i) azf(:,i)]);     %Plots the filtered acc data of x,y,z
% title(ax(i).label); xlim(xLimits);
% legend('ax filt','ay filt','az filt');
% subplot(2,1,2);
% plot(ax(1).time,amagf(:,i),'-'); %Plots the total acceleration
% title('Magnitude'); xlim(xLimits);
%
% figure() %Plots the detrended, filtered acc data of x,y,z
% xLimits = [0 5];
% i = 1;  % only R ankle
% subplot(2,1,1);
% plot(ax(1).time,[axdf(:,i) aydf(:,i) azdf(:,i)]);     %Plots the detrended, filtered acc data of x,y,z
% title(ax(i).label); xlim(xLimits);
% legend('ax filt, detrend','ay filt, detrend','az filt, detrend');
% subplot(2,1,2);
% plot(ax(1).time,amagdf(:,i),'-'); %Plots the total acceleration
% title('Magnitude'); xlim(xLimits);
%  

% figure() %Plots the unfiltered acc data of x,y,z
% xLimits = [0 5];
% i = 1;  % only R ankle
% subplot(2,1,1);
% plot(ax(1).time,[axnf(:,i) aynf(:,i) aznf(:,i)]);     %Plots the unfiltered acc data of x,y,z
% title(ax(i).label); xlim(xLimits);
% legend('ax ','ay','az ');
% subplot(2,1,2);
% i = 2;
% plot(ax(1).time,[axnf(:,i) aynf(:,i) aznf(:,i)]);     %Plots the unfiltered acc data of x,y,z
% %plot(ax(1).time,amagnf2(:,i),'-'); %Plots the total acceleration
% title('L Ankle'); xlim(xLimits);


% figure() %Plots the filtered detrended, scaled acc data of z
% xLimits = [0 5];
% figure(1)
% plot(ax(1).time,azdf_scaled(:,1:2),'-');
% xlim(xLimits);
% legend('R Ankle', 'L Ankle')
% title('Peaks of Acceleration Magnitudes, filtered,scaled')
end
function [hsr, hsl, param] = findHeelStrikes(acc,tr,inpath)
% tries to use algorithm to detect heel strike. MUST MANUALLY VALIDATE IT IS OKAY.

% get acceleration signals with heel strikes in it
acc_r = acc.z_filt(:,1); % right leg
acc_l = acc.z_filt(:,2); % left  leg

% peak finding parameters, default
param.MinPeakHeight = 0.6;
param.MinPeakDistance = 0.8;
param.MinPeakProminence = 0;
param.Threshold = 0;
param.dualStrategyUsed = 0;
param.manualStrategyUsed = 0;

% initially try to find peaks
[hsr, hsl] = findpeaksACC(acc_r,acc_l,acc.time,param); 

% plot acceleration signals for R & L heels
fig1 = figure(1);
color_r = [0.8500    0.3250    0.0980]; %red
color_l = [     0    0.4470    0.7410]; %blue
symbol_r = 'kx';
symbol_l = 'ko';
ylimits = [-1 2];
xlimits1 = [0 20.5]; xlimits2 = [20 40.5]; xlimits3 = [40 60.5];

t1_start = 1; t1_end = find(acc.time <= xlimits1(2),1,'last'); % 0-20.5 seconds
t2_start = find(acc.time >= xlimits2(1),1); t2_end = find(acc.time <= xlimits2(2),1,'last'); % 20 - 40.5 seconds
t3_start = find(acc.time >= xlimits3(1),1); t3_end = length(acc.time); % 40 - 60 seconds
t1_start_hsr = 1; t1_end_hsr = find(hsr.time <= xlimits1(2),1,'last');
t2_start_hsr = find(hsr.time >= xlimits2(1),1); t2_end_hsr = find(hsr.time <= xlimits2(2),1,'last');
t3_start_hsr = find(hsr.time >= xlimits3(1),1); t3_end_hsr = length(hsr.time);
t1_start_hsl = 1; t1_end_hsl = find(hsl.time <= xlimits1(2),1,'last');
t2_start_hsl = find(hsl.time >= xlimits2(1),1); t2_end_hsl = find(hsl.time <= xlimits2(2),1,'last');
t3_start_hsl = find(hsl.time >= xlimits3(1),1); t3_end_hsl = length(hsl.time);

fig1 = figure(1);
subplot(3,1,1);
h1t1_r = plot(acc.time(t1_start:t1_end),acc_r(t1_start:t1_end),'color',color_r); hold on;
h1t1_l = plot(acc.time(t1_start:t1_end),acc_l(t1_start:t1_end),'color',color_l);
h2t1_hsr = plot(hsr.time(t1_start_hsr:t1_end_hsr),hsr.value(t1_start_hsr:t1_end_hsr),symbol_r);
h2t1_hsl = plot(hsl.time(t1_start_hsl:t1_end_hsl),hsl.value(t1_start_hsl:t1_end_hsl),symbol_l); hold off;
xlim(xlimits1); ylim(ylimits); title('FIND HEEL STRIKES: 0 - 20 sec');
legend([h1t1_r, h1t1_l, h2t1_hsr, h2t1_hsl],{'R Ankle Acc', 'L Ankle Acc', 'R Heel Strike', 'L Heel Strike'},'location','southeast','orientation','horizontal');

subplot(3,1,2);
h1t2_r = plot(acc.time(t2_start:t2_end),acc_r(t2_start:t2_end),'color',color_r); hold on;
h1t2_l = plot(acc.time(t2_start:t2_end),acc_l(t2_start:t2_end),'color',color_l);
h2t2_hsr = plot(hsr.time(t2_start_hsr:t2_end_hsr),hsr.value(t2_start_hsr:t2_end_hsr),symbol_r);
h2t2_hsl = plot(hsl.time(t2_start_hsl:t2_end_hsl),hsl.value(t2_start_hsl:t2_end_hsl),symbol_l); hold off;
xlim(xlimits2); ylim(ylimits); title('FIND HEEL STRIKES: 20 - 40 sec');
subplot(3,1,3);
h1t3_r = plot(acc.time(t3_start:t3_end),acc_r(t3_start:t3_end),'color',color_r); hold on;
h1t3_l = plot(acc.time(t3_start:t3_end),acc_l(t3_start:t3_end),'color',color_l);
h2t3_hsr = plot(hsr.time(t3_start_hsr:t3_end_hsr),hsr.value(t3_start_hsr:t3_end_hsr),symbol_r);
h2t3_hsl = plot(hsl.time(t3_start_hsl:t3_end_hsl),hsl.value(t3_start_hsl:t3_end_hsl),symbol_l); hold off;
xlim(xlimits3); ylim(ylimits); title('FIND HEEL STRIKES: 40 - 60 sec');

set(fig1, 'Position', get(0, 'Screensize'));

% CHECK heel strike algorithm. If it is not satisfactory, change
% parameters or do find heel strikes manually
loop = 1;
while loop
    disp('Are the heel strikes accurate? (able to continue processing?)');
    disp('1: Good'); 
    disp('2: Change findpeaks Parameters and find again'); 
    disp('3: dual strategy (get dual heel strikes and sort)'); 
    disp('4: manually find/remove peaks'); 
    disp('5: load previous heel strike data');
    disp('6: Abort');
    heelStrikeCheck = input('Input:  ','s');
    
    switch heelStrikeCheck
        case '1' %'Good'
            disp('User specifies that heel strikes are accurate.');
            loop = 0; % exit loop
        case '2' %'Change findpeaks Parameters'
            prompt = {'MinPeakHeight','MinPeakDistance','MinPeakProminence','Threshold'};
            prompt_title = 'Adjust findpeaks parameters';
            prompt_defaultAnswer = {num2str(param.MinPeakHeight),num2str(param.MinPeakDistance),num2str(param.MinPeakProminence),num2str(param.Threshold)};
            prompt_answer = inputdlg(prompt,prompt_title,[1 60],prompt_defaultAnswer);
            if isempty(prompt_answer)
                disp('user canceled. No changes to parameters.'); 
            else
                param.MinPeakHeight = str2num(prompt_answer{1});
                param.MinPeakDistance = str2num(prompt_answer{2});
                param.MinPeakProminence = str2num(prompt_answer{3});
                param.Threshold = str2num(prompt_answer{4});
                [hsr, hsl] = findpeaksACC(acc_r,acc_l,acc.time,param); % find peaks with new parameters
            end 
        case '3' % dual strategy (get every peak and sort)
            loop3 = 1;
            while loop3
                disp('Using the dual strategy (get dual heel strikes and take every other one)');
                disp('Heel strikes must first be identified at every step.');
                disp('Starting on RIGHT LEG (red X) or LEFT LEG (blue O)?   (first heel strike with stance phase)');
                disp('R: right leg,  L: left leg,  A: abort this strategy')
                startingHeel = input('Input:  ','s');
                switch startingHeel
                    case {'R','r'}
                        loop3 = 0;
                        param.dualStrategyUsed = 1;
                        hsr.time  = hsr.time(1:2:end);
                        hsr.value = hsr.value(1:2:end);
                        hsl.time  = hsl.time(2:2:end);
                        hsl.value  = hsl.value(2:2:end);
                    case {'L','l'}
                        loop3 = 0;
                        param.dualStrategyUsed = 1;
                        hsr.time  = hsr.time(2:2:end);
                        hsr.value = hsr.value(2:2:end);
                        hsl.time  = hsl.time(1:2:end);
                        hsl.value = hsl.value(1:2:end);
                    case {'A','a'}
                        loop3 = 0; param.dualStrategyUsed = 0;
                        disp('Aborting this strategy.'); disp(' ');
                    otherwise
                        disp('Unknown input.'); disp(' ');
                end % switch
            end %while loop3
        case '4' % manually find and remove peaks
            loop4 = 1;
            while loop4
                disp('Manually find and remove peaks, using ginput function.');
                disp('Using RIGHT LEG (red X) or LEFT LEG (blue O)?');
                disp('R: right leg,  L: left leg,  A: abort this strategy')
                legChoice = input('Input:  ','s');
                switch legChoice
                    case {'R','r'} % right leg
                        hs_time = hsr.time; hs_value = hsr.value; hs_acc = acc_r; % pull values for processing
                    case {'L','l'} % left leg
                        hs_time = hsl.time; hs_value = hsl.value; hs_acc = acc_l; % pull values
                    case {'A','a'} % abort
                        disp('Aborting this strategy.'); disp(' ');
                        break;
                    otherwise
                        disp('Unknown input. Check capitalization.'); disp(' ');
                        break;
                end    
                        
                loop4 = 0;
                param.manualStrategyUsed = 1;
                disp(' '); disp('Specify time windows on plot:');
                disp('DELETE PEAKS: Select pairs of x-values before and after existing peaks');
                disp('ADD PEAK: select pair of x-values where a peak should be (the maximum of that time window).');
                disp('Press enter when done selecting.');
                [x ~] = ginput(); % get values from plot
                
                if isempty(x) || (length(x) == 1)
                    disp('Not enough points selected.')
                    break;
                end
                
                if ~isEven(length(x)) % if odd, dont consider the last data point
                    x = x(1:end-1);
                end
                
                nWindows = length(x)/2; % number of time windows chosen
                disp(['Number of selected time windows: ' num2str(nWindows)]);
                
                for i = 1:2:length(x) %cycle through all chosen time windows
                    
                    % determine if peak exists in this time window
                    a = find(hs_time > x(i) & hs_time < x(i+1));
                    
                    if ~isempty(a) % remove peaks in this window
                        hs_time(a) = [];
                        hs_value(a) = [];
                    else % add a peak inside this time window at max value of the window
                        t_start_new = find(acc.time >= x(i),1);
                        t_end_new = find(acc.time <= x(i+1),1,'last');
                        
                        [hs_value_new, index] = max(hs_acc(t_start_new:t_end_new)); % new peak
                        hs_time_new = acc.time(t_start_new+index-1); % new time of peak
                        
                        a2 = find(hs_time < x(i),1,'last'); % is this the first heel strike in the data?
                        if isempty(a2) % put first
                            hs_time = [hs_time_new; hs_time];
                            hs_value = [hs_value_new; hs_value];
                        else % insert into vector
                            hs_time = [hs_time(1:a2); hs_time_new; hs_time(a2+1:end)];
                            hs_value = [hs_value(1:a2); hs_value_new; hs_value(a2+1:end)];
                        end
                    end
                end
                switch legChoice %reinsert values
                    case {'R','r'} % right leg
                        hsr.time = hs_time; hsr.value = hs_value; 
                    case {'L','l'} % left leg
                        hsl.time = hs_time; hsl.value = hs_value;
                end    
            end %loop4 

        case '5' % load previous heel strike data
            path_orig = pwd;
            cd(inpath);            
            if exist([acc.filename '.mat'],'file') == 2
                acc_previous = load(acc.filename);
                hsr.time  = acc_previous.acc.hsr.time;
                hsr.value = acc_previous.acc.hsr.value;
                hsl.time  = acc_previous.acc.hsl.time;
                hsl.value = acc_previous.acc.hsl.value;
            else
                disp('Previous heel strike data could not be found.');
            end
            cd(path_orig);
        case '6' %'Abort'
            error('User aborted processing heel strikes.');
        otherwise
            disp('unkown response.');disp(' ');
    end %switch
    
    % replot:
    t1_start_hsr = 1; t1_end_hsr = find(hsr.time <= xlimits1(2),1,'last');
    t2_start_hsr = find(hsr.time >= xlimits2(1),1); t2_end_hsr = find(hsr.time <= xlimits2(2),1,'last');
    t3_start_hsr = find(hsr.time >= xlimits3(1),1); t3_end_hsr = length(hsr.time);
    t1_start_hsl = 1; t1_end_hsl = find(hsl.time <= xlimits1(2),1,'last');
    t2_start_hsl = find(hsl.time >= xlimits2(1),1); t2_end_hsl = find(hsl.time <= xlimits2(2),1,'last');
    t3_start_hsl = find(hsl.time >= xlimits3(1),1); t3_end_hsl = length(hsl.time);
    figure(fig1);
    subplot(3,1,1); delete(h2t1_hsr); delete(h2t1_hsl); hold on; 
    h2t1_hsr = plot(hsr.time(t1_start_hsr:t1_end_hsr),hsr.value(t1_start_hsr:t1_end_hsr),symbol_r);
    h2t1_hsl = plot(hsl.time(t1_start_hsl:t1_end_hsl),hsl.value(t1_start_hsl:t1_end_hsl),symbol_l); hold off;
    xlim(xlimits1); ylim(ylimits); legend([h1t1_r, h1t1_l, h2t1_hsr, h2t1_hsl],{'R Ankle Acc', 'L Ankle Acc', 'R Heel Strike', 'L Heel Strike'},'location','southeast','orientation','horizontal');
    subplot(3,1,2); delete(h2t2_hsr); delete(h2t2_hsl); hold on; 
    h2t2_hsr = plot(hsr.time(t2_start_hsr:t2_end_hsr),hsr.value(t2_start_hsr:t2_end_hsr),symbol_r);
    h2t2_hsl = plot(hsl.time(t2_start_hsl:t2_end_hsl),hsl.value(t2_start_hsl:t2_end_hsl),symbol_l); hold off;
    xlim(xlimits2); ylim(ylimits);
    subplot(3,1,3); delete(h2t3_hsr); delete(h2t3_hsl); hold on; 
    h2t3_hsr = plot(hsr.time(t3_start_hsr:t3_end_hsr),hsr.value(t3_start_hsr:t3_end_hsr),symbol_r);
    h2t3_hsl = plot(hsl.time(t3_start_hsl:t3_end_hsl),hsl.value(t3_start_hsl:t3_end_hsl),symbol_l); hold off;
    xlim(xlimits3); ylim(ylimits);
end %while

% save fig
fig = gcf; %tightfig(gcf);
suptitle([tr.subject_type '-' sprintf('%02d',tr(1).subject_id) ' TP' sprintf('%02d',tr(1).testPoint) ' ' tr(1).trialType])
fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 30 15]; 
filename = [tr.subject_type sprintf('%02d',tr(1).subject_id) '_tp' sprintf('%02d',tr(1).testPoint) '_' tr(1).trialType '_HS'];
path_orig = pwd;
cd(inpath);
print(filename,'-dpng','-painters','-loose');
cd(path_orig);
disp(['Plot of HEEL STRIKES saved as: ' filename '.png']);
close(1);


end
function [hsr, hsl] = findpeaksACC(acc_r,acc_l,time,param)
% find peaks in an acceleration signal for both legs 

% get times of heel strike for R and L ankles
    
    % Uses the magnitudes from filtered acc data and finds the peaks (representing heel strikes)
    % OLD: using peak of magnitude of acceleration (amagf: filtered, not detrended, not scaled):
    % CURRENT: using peak of Anterior-Posterior acceleration (z direction)
    
[hsr_value, hsr_time]=findpeaks(acc_r,time,'MinPeakHeight',param.MinPeakHeight,'MinPeakDistance',param.MinPeakDistance, 'MinPeakProminence', param.MinPeakProminence,'Threshold',param.Threshold); 
[hsl_value, hsl_time]=findpeaks(acc_l,time,'MinPeakHeight',param.MinPeakHeight,'MinPeakDistance',param.MinPeakDistance, 'MinPeakProminence', param.MinPeakProminence,'Threshold',param.Threshold); 
hsr.time = hsr_time; % time of strike, right ankle
hsr.value = hsr_value; % accleration at heel strike, right ankle  
hsl.time = hsl_time; % time of strike, left ankle
hsl.value = hsl_value; % accleration at heel strike, left ankle  

% PENDING: Uses the magnitudes from filtered acc data and finds the peaks (representing toe off). I dont think I can easily do this. Will need a fancier algorithm.
end
function [EMG_envelope, EMG_label] = filterEMG(emg)
% Filter the EMG data
% Use filters to remove non-EMG frequency range noise, drift, and
% then get nice activation envelopes
% e.g. for a 2000 Hz collection,
%   350Hz = 350/(freq/2) = 350/(1000) = 0.35
%     1Hz =   1/(freq/2) =   1/(1000) = 0.001
%    10Hz =  10/(freq/2) =  10/(1000) = 0.01
BP = [10 500]; % bandpass filter parameters in Hz [low cutoff, high cutoff]
LP = 10; % low pass filter for linear envelope, in Hz

[b_BP,a_BP]=butter(4,BP/(emg(1).freq/2)); % bandpass filter
[b_LP,a_LP]=butter(4,LP/(emg(1).freq/2),'low'); % linear envelope filter

EMG_raw = zeros(size(emg(1).data));% preallocate for speed
EMG_label = cell(1,12);% preallocate for speed
for ii=1:12
    EMG_raw(:,ii)=emg(ii).data; %Raw emg data - Here just pulling the matrix of data out of the structure I loaded
    EMG_label{ii}=emg(ii).label;
end

EMG_raw     = detrend(EMG_raw,0);          % remove DC offset
EMG_BP      = filtfilt(b_BP,a_BP,EMG_raw); % bandpass filter 
EMG_abs     = abs(EMG_BP);                 % Rectify data (full wave)
EMG_envelope= filtfilt(b_LP,a_LP,EMG_abs); % Filter to linear envelopes of activation

%% plots EMG_envelope over time
% figure()
% for i = 1:12
%     subplot(12,1,i);
%     plot(emg(1).time,EMG_envelope(:,i));
%     title(emg(i).label);
% end

end
function [EMG_sorted, EMG_label_sorted] = sortEMGsignals(EMG_envelope, EMG_label)
% sometimes the EMG data is cleanly in R & L channels. Sometimes it is
% in a different order. This ensures everything in its right strucutre.

disp('Sorting to ensure EMG signals are in correct columns.')

EMG_sorted = zeros(size(EMG_envelope)); % preallocate
EMG_label_sorted = cell(1,12); % preallocate 
for i = 1:12 % cycle through signals recorded
    switch EMG_label{i}
        case 'R TIBIALIS ANTERIOR' % put in column 1
            EMG_sorted(:,1) = EMG_envelope(:,i);
            EMG_label_sorted{1} = EMG_label{i};
        case 'R GASTROCNEMIUS MEDIAL HEAD' % column 2
            EMG_sorted(:,2) = EMG_envelope(:,i);
            EMG_label_sorted{2} = EMG_label{i};
        case 'R SOLEUS' % column 3
            EMG_sorted(:,3) = EMG_envelope(:,i);
            EMG_label_sorted{3} = EMG_label{i};
        case 'R VASTUS LATERALIS' % column 4
            EMG_sorted(:,4) = EMG_envelope(:,i);
            EMG_label_sorted{4} = EMG_label{i};
        case 'R RECTUS FEMORIS' % column 5
            EMG_sorted(:,5) = EMG_envelope(:,i);
            EMG_label_sorted{5} = EMG_label{i};
        case 'R SEMITENDINOSUS' % column 6
            EMG_sorted(:,6) = EMG_envelope(:,i);
            EMG_label_sorted{6} = EMG_label{i};
        case 'L TIBIALIS ANTERIOR' % column 7
            EMG_sorted(:,7) = EMG_envelope(:,i);
            EMG_label_sorted{7} = EMG_label{i};
        case 'L GASTROCNEMIUS MEDIAL HEAD' % column 8
            EMG_sorted(:,8) = EMG_envelope(:,i);
            EMG_label_sorted{8} = EMG_label{i};
        case 'L SOLEUS' % column 9
            EMG_sorted(:,9) = EMG_envelope(:,i);
            EMG_label_sorted{9} = EMG_label{i};
        case 'L VASTUS LATERALIS' % column 10
            EMG_sorted(:,10) = EMG_envelope(:,i);
            EMG_label_sorted{10} = EMG_label{i};
        case 'L RECTUS FEMORIS' % column 11
            EMG_sorted(:,11) = EMG_envelope(:,i);
            EMG_label_sorted{11} = EMG_label{i};
        case 'L SEMITENDINOSUS' % column 12
            EMG_sorted(:,12) = EMG_envelope(:,i);
            EMG_label_sorted{12} = EMG_label{i};
    end    
end


end
function [EMG_strides,nStrides_right,nStrides_left] = findStridesEMG(time,EMG,hsr_time,hsl_time)
% divides the EMG signals insto strides
% time: vector of time
% EMG: vector of EMG data
% hs_index: indices of when heel strike events happened
npts = 101; % points per gait cycle
nStrides_right = length(hsr_time)-1; % number of complete gait cycles
nStrides_left  = length(hsl_time)-1; 
EMG_strides = cell(1,12);

for m = 1:6 %sort through each muscle
   % RIGHT LEG
   emg1 = EMG(:,m);
   EMG_strides{m} = zeros(npts,nStrides_right); % preallocated
   for j = 1:nStrides_right
       j1 = find(time>hsr_time(j),1); % get index of time at first heel strike
       j2 = find(time>hsr_time(j+1),1); % get index of time at second heel strike
       EMG_strides{m}(:,j) = normcycle(emg1(j1:j2),npts); % time normalize
   end
   
   % LEFT LEG
   emg1 = EMG(:,6+m);
   EMG_strides{6+m} = zeros(npts,nStrides_left); 
   for j = 1:nStrides_left
       j1 = find(time>hsl_time(j),1); % get index of time at first heel strike
       j2 = find(time>hsl_time(j+1),1); % get index of time at second heel strike
       EMG_strides{6+m}(:,j) = normcycle(emg1(j1:j2),npts); % time normalize
   end
end

end
function yf = normcycle(y,n,x)
% yf = normcycle(y,n,x)
% Convert a signal y to n even-spaced data points over a cycle
% Often used for presentation of gait data, default for n is 101 points
% can specify an indpendent variable x (optional)
if ~exist('n','var')
    n=101;
end
[nr,nc]=size(y);
if nc==1 && nr>1
    ny=1;
    nx=nr;
elseif nr==1 && nc>1
    y=y';
    ny=1;
    nx=nc;
elseif nr>1 && nc>1
    ny=nc;
    nx=nr;
else
    disp('normcycle does not work on a scalar value');
    yf=[];
    return
end
if ~exist('x','var')
    x=[0:(nx-1)]/(nx-1);
else
    nx=length(x);
    x=(x-x(1))/(x(end)-x(1));
end
kk=[0:(n-1)]/(n-1);
yf=interp1(x,y,kk,'*pchip');

end
function plotEMG(fig,tr,inpath)
% plot EMG data for average gait cycle and all strides overlaid

for j = 1:6
    subplot(6,2,2*j)
    shadedErrorBar([0:100]',tr.emgData(:,j),tr.emgStd(:,j));%,{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
    hold on
    for i = 1:tr.nStrides_right
        plot([0:100]',tr.emgStrides{j}(:,i))
    end
    hold off
    title(tr.emgLabel{j})
    
    subplot(6,2,2*j-1)
    shadedErrorBar([0:100]',tr.emgData(:,6+j),tr.emgStd(:,6+j));%,{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
    hold on
    for i = 1:tr.nStrides_left
        plot([0:100]',tr.emgStrides{6+j}(:,i))
    end
    hold off
    title(tr.emgLabel{6+j})
end
figure(fig); tightfig(fig);
suptitle([tr.subject_type '-' sprintf('%02d',tr(1).subject_id) ' TP' sprintf('%02d',tr(1).testPoint) ' ' tr(1).trialType]);
fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 25 30]; 
filename = [tr.subject_type sprintf('%02d',tr(1).subject_id) '_tp' sprintf('%02d',tr(1).testPoint) '_' tr(1).trialType '_avg'];
path_orig = pwd;
cd(inpath);
print(filename,'-dpng','-painters','-loose');
cd(path_orig);
disp(['Plot of EMG over gait cycles saved as: ' filename '.png']);

% emg scaled to unit variance
fig2 = figure();
for j = 1:6
    subplot(6,2,2*j)
    shadedErrorBar([0:100]',tr.emgData_scaledUnitVariance(:,j),tr.emgStd_scaledUnitVariance(:,j));
    title(tr.emgLabel{j}); ylim([0 5]);
    
    subplot(6,2,2*j-1)
    shadedErrorBar([0:100]',tr.emgData_scaledUnitVariance(:,6+j),tr.emgStd_scaledUnitVariance(:,6+j));
    title(tr.emgLabel{6+j}); ylim([0 5]);
end
    %tightfig(fig2);
    suptitle([tr.subject_type '-' sprintf('%02d',tr(1).subject_id) ' TP' sprintf('%02d',tr(1).testPoint) ' ' tr(1).trialType '  UNIT VARIANCE SCALING']);
    fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 25 30];
    filename = [tr.subject_type sprintf('%02d',tr(1).subject_id) '_tp' sprintf('%02d',tr(1).testPoint) '_' tr(1).trialType '_avg_unitVariance'];
    path_orig = pwd;
    cd(inpath);
    print(filename,'-dpng','-painters','-loose');
    cd(path_orig);
    disp(['Plot of EMG over gait cycles with unit variance saved as: ' filename '.png']);
close(fig2);
end
