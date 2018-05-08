function [tr, inpath] = processEMGtrial(inpath,infile)
% Filename: processEMGtrial.m
% Author:   Samuel Acuna
% Date:     24 May 2016
% Updated:  01 May 2018
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
    'subject_id',[],...
    'testPoint',[],...
    'trialType',[],...
    'filename',[]);
% setup empty acceleration structure
acc= struct(...
    'subject_id',[],...
    'testPoint',[],...
    'trialType',[],...
    'filename',[]);

c = strsplit(infile,'_'); % parse out info from file name

try % subject ID
    ID = str2num(c{1}(4:end));
    disp(['Subject ID: ' num2str(ID)])
catch
    ID = setSubjectID();
end
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

[hsr_time, hsl_time, hsr_index, hsl_index, time_acc] = findStridesAcc(ax, ay, az); % get indexes of heel strike for R and L ankles

acc(1).ax = ax; % save raw acceleration data, to use for later...
acc(1).ay = ay;
acc(1).az = az;
acc(1).hsr_index = hsr_index; % sync indexes with acc(1).time to get actual times
acc(1).hsl_index = hsl_index;
acc(1).hsr_time = hsr_time;
acc(1).hsl_time = hsl_time;
acc(1).time = time_acc;
clear ax ay az hsr_index hsl_index time_acc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 5: filter EMG, amplitude normalize, and divide into steps (time normalize to step)
disp('Filtering (BP 10-500 Hz), rectifying, linear envelopes (10 Hz), amplitude normalizing (peaks), time normalizing into steps.');
time_emg = emg(1).time;
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
[EMG_gaitCycles,nStrides_right,nStrides_left] = findStridesEMG(time_emg,EMG_normalized,hsr_time,hsl_time); % divide into steps and time normalize to 101 pts/cycle

tr(1).emgLabel = EMG_label_sorted;
tr(1).emgFreq = emg(1).freq;
tr(1).emgSteps = EMG_gaitCycles;
clear emg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 6: save concatentated and average EMG by steps
% created concatenated pattern across all steps
EMG_concat = cell(1,12);
for i = 1:12
    steps = size(EMG_gaitCycles{1}(1:100,:),2);
    EMG_concat1 = EMG_gaitCycles{i}(1:100,:);% cut off last time point for each step (since it is first of next step)
    EMG_concat{i} = reshape(EMG_concat1,[steps*100,1]); % reshape into single vector
end
tr(1).emgConcat = EMG_concat;

% find average gait cycle pattern across all steps
disp('calculating emg data over average gait cycle....');
EMG_avg = zeros(size(EMG_gaitCycles{1},1),12);
EMG_std = zeros(size(EMG_gaitCycles{1},1),12);
for i = 1:12
    EMG_avg(:,i) = mean(EMG_gaitCycles{i}')';
    EMG_std(:,i) = std(EMG_gaitCycles{i}')';
end
tr(1).emgData = EMG_avg; % save average gait cycle
tr(1).emgStd = EMG_std;

% plot average gait cycle and steps overlaid
figure(2)
for j = 1:6
    subplot(6,2,2*j)
    shadedErrorBar([0:100]',EMG_avg(:,j),EMG_std(:,j));%,{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
    hold on
    for i = 1:nStrides_right
        plot([0:100]',EMG_gaitCycles{j}(:,i))
    end
    hold off
    title(EMG_label_sorted{j})
    
    subplot(6,2,2*j-1)
    shadedErrorBar([0:100]',EMG_avg(:,6+j),EMG_std(:,6+j));%,{'color',tbiStudy.plot.emgPlotColors{1}},tbiStudy.plot.transparentErrorBars);
    hold on
    for i = 1:nStrides_left
        plot([0:100]',EMG_gaitCycles{6+j}(:,i))
    end
    hold off
    title(EMG_label_sorted{6+j})
end
fig = gcf; tightfig(gcf);
suptitle(['TBI-' sprintf('%02d',tr(1).subject_id) ' TP' sprintf('%02d',tr(1).testPoint) ' ' tr(1).trialType])
fig.PaperUnits = 'centimeters'; fig.PaperPosition = [0 0 25 30]; 
filename = ['tbi' sprintf('%02d',tr(1).subject_id) '_tp' sprintf('%02d',tr(1).testPoint) '_' tr(1).trialType '_avg'];
path_orig = cd(inpath);
print(filename,'-dpng','-painters','-loose');
cd(path_orig);
disp(['Plot of EMG over gait cycles saved as: ' filename '.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 7: save file to original folder
%tr(1).filename = ['hyn' sprintf('%02d',tr.subject_id) '_tp' sprintf('%02d',tr.testPoint) '_' tr.trialType];
tr(1).filename = ['tbi' sprintf('%02d',tr.subject_id) '_tp' sprintf('%02d',tr.testPoint) '_' tr.trialType '_EMG'];
save([inpath tr.filename], 'tr');
disp(['EMG data saved as: ' tr.filename]);
disp(['in folder: ' inpath]);

acc(1).filename = ['tbi' sprintf('%02d',tr.subject_id) '_tp' sprintf('%02d',tr.testPoint) '_' tr.trialType '_ACC'];
save([inpath acc.filename], 'acc');
disp(['Acceleration data saved as: ' acc.filename]);
disp(['in folder: ' inpath]);
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
function [hsr_time, hsl_time, hsr_index, hsl_index, time_acc] = findStridesAcc(ax, ay, az)
% THis function Finds the peaks of the filtered acceleration data, which we interpret as
% the instances of heel strike.
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
    axf(:,i)=filtfilt(bfa,afa,ax(i).data);
    ayf(:,i)=filtfilt(bfa,afa,ay(i).data);
    azf(:,i)=filtfilt(bfa,afa,az(i).data);
    amagf(:,i)=(axf(:,i).^2+ayf(:,i).^2+azf(:,i).^2).^0.5;
    % detrended, filter 25 hz
    axdf(:,i)=filtfilt(bfa,afa,detrend(ax(i).data));
    aydf(:,i)=filtfilt(bfa,afa,detrend(ay(i).data));
    azdf(:,i)=filtfilt(bfa,afa,detrend(az(i).data));
    amagdf(:,i)=(axdf(:,i).^2+aydf(:,i).^2+azdf(:,i).^2).^0.5;
    % no filter
    axnf(:,i) = detrend(ax(i).data); 
    aynf(:,i) = detrend(ay(i).data);
    aznf(:,i) = detrend(az(i).data);
    amagnf(:,i)=(ax(i).data.^2+ay(i).data.^2+az(i).data.^2).^0.5; % unflitered acceleration magnitudes
    amagnf2(:,i)=(axnf(:,i).^2+aynf(:,i).^2+aznf(:,i).^2).^0.5; % unflitered acceleration magnitudes
    
end

% amplitude ax normalize to max acceleration
azdf_scaled = azdf./max(azdf);

%% plot acceleration data
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


% Uses the magnitudes from filtered acc data and finds the peaks
% (representing heel strikes)
% OLD: using peak of magnitude of acceleration (filtered, not detrended, not scaled):
% [hsr_value, hsr_index]=findpeaks(amagf(:,1),'MinPeakHeight',2.,'MinPeakDistance',100); % [heel strike right ankle, time of strike]
% [hsl_value, hsl_index]=findpeaks(amagf(:,2),'MinPeakHeight',2.,'MinPeakDistance',100); % [heel strike left ankle, time of strike]
% CURRENT: using peak of Anterior-Posterior acceleration (z direction)
[hsr_value, hsr_index]=findpeaks(azdf_scaled(:,1),'MinPeakHeight',0.6,'MinPeakDistance',100); % [heel strike right ankle, time of strike]
[hsl_value, hsl_index]=findpeaks(azdf_scaled(:,2),'MinPeakHeight',0.6,'MinPeakDistance',100); % [heel strike left ankle, time of strike]

time_acc = ax(1).time; % acceleration time series
hsr_time = time_acc(hsr_index); % time of instances of heel strike right
hsl_time = time_acc(hsl_index); % time of instances of heel strike left

% Uses the magnitudes from filtered acc data and finds the peaks
% (representing toe off)
% PENDING. I dont think I can easily do this. Will need a fancier
% algorithm.

%% Plots the peaks as x's and o's
figure(1)
plot(ax(1).time,azdf_scaled(:,1:2),'-');
hold on;
plot(ax(1).time(hsr_index),hsr_value, 'o');
plot(ax(1).time(hsl_index),hsl_value,'x');
hold off;
legend('R Ankle', 'L Ankle')
ylim([0 2]);
title('Peaks of Acceleration Magnitudes, filtered')


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
function [gaitCycle,nStrides_right,nStrides_left] = findStridesEMG(time,EMG,hsr_time,hsl_time)
% divides the EMG signals insto strides
% time: vector of time
% EMG: vector of EMG data
% hs_index: indices of when heel strike events happened
npts = 101; % points per gait cycle
nStrides_right = length(hsr_time)-1; % number of complete gait cycles
nStrides_left  = length(hsl_time)-1; 
gaitCycle = cell(1,12);

for m = 1:6 %sort through each muscle
   % RIGHT LEG
   emg1 = EMG(:,m);
   gaitCycle{m} = zeros(npts,nStrides_right); % preallocated
   for j = 1:nStrides_right
       j1 = find(time>hsr_time(j),1); % get index of time at first heel strike
       j2 = find(time>hsr_time(j+1),1); % get index of time at second heel strike
       gaitCycle{m}(:,j) = normcycle(emg1(j1:j2),npts); % time normalize
   end
   
   % LEFT LEG
   emg1 = EMG(:,6+m);
   gaitCycle{6+m} = zeros(npts,nStrides_left); 
   for j = 1:nStrides_left
       j1 = find(time>hsl_time(j),1); % get index of time at first heel strike
       j2 = find(time>hsl_time(j+1),1); % get index of time at second heel strike
       gaitCycle{6+m}(:,j) = normcycle(emg1(j1:j2),npts); % time normalize
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
