function tr = processEMGtrial()
% Filename: processEMGtrial.m
% Author:   Samuel Acuna
% Date:     24 May 2016
% Description:
% This class file is used to convert EMG data from a text file into a
% matlab structure of the average gait cycle (a much smaller file)
%
% The raw emg data must be in a .txt format, not .hpf
% To create the .txt version, open program 'emgworks_analysis' on collection
% computer. load .hpf into workspace, click 'Tools', 'export to text tile'. Put this
% file in the same location as the original .hpf
% 
% This puts the processed Matlab file in the same location as the original
% .txt file
% 
%
% Usage:
%       tr = tbiStudy.processEMGtrial();
%

%%%%%%%%%%%%%%%%%%%%%%%%%
% load EMG data txt file
disp('Select .txt EMG data file');
dataFolder = '/Users/samuel/Documents/data tbi_emg_study/'; % mac formatting. Might need to Change to windows style.
[infile, inpath]=uigetfile('*.txt','Select input file',dataFolder);
if infile == 0
    error('Canceled. No file selected');
end
disp(['Selected: ' infile ]);


%%%%%%%%%%%%%%%%%%%%%%%%%
% setup empty trial structure
tr= struct(...
    'emg',{},...    % emg data
    'ax',{},...		% accelerometer data, x 
    'ay',{},...		% accelerometer data, y
    'az',{});		% accelerometer data, z 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate emg, ax, ay, az data
disp('loading and converting raw emg data into matlab friendly format.')
disp('This might take a while...')
try
    [emg, ax, ay, az] = load_emgworks(infile,inpath); % outputs = emg structure, acceleration in x,y,z
catch
    error('could not load emgworks file. Something went wrong in the load_emgworks function.');
end

% save raw data to structure
tr(1).emg = emg;
tr(1).ax = ax;
tr(1).ay = ay;
tr(1).az = az;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIONAL: calculate emg data over the average gait cycle. This also
% FILTERS the data.
if 1 % change to 0 or 1 to activate this function
	
	calculationPlots = 1; % set to true if you want to see plots of intermediate calculations
	
	[emgcyc, emgcycstd, emgcyclabel, emgcycfreq] = calcEmgCycle(emg, ax, ay, az, calculationPlots);

	% save to structure
	tr(1).emgcyc = emgcyc;
	tr(1).emgcycstd = emgcycstd;
	tr(1).emgcyclabel = emgcyclabel;
	tr(1).emgcycfreq = emgcycfreq;
	
	disp('Successfully calculated EMG data for average gait cycle.')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save file 
pattern = '.txt';
replacement = '';
filename = regexprep(infile,pattern,replacement); % remove .txt from input file
filename = [filename '_processed']; % might want to change this to something more creative
save([inpath filename], 'tr');
disp(['Trial Data saved as: ' filename]);
disp(['in folder: ' inpath]);
end


% processing functions
function [emg, ax, ay, az] = load_emgworks(infile,inpath)
            %   [emg,ax,ay,az]=load_emgworks(infile,inpath)
            %   LOAD_EMGWORKS is used to open a txt formateed data file generated by the emgworks
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
                line(line=='�')=' ';
                line(line=='n')=' ';
                line(line=='p')=' ';
                line(line=='f')=' ';
                % figure out where the data goes
                kk=(diff(jc)>1);
                data(k,kk)=sscanf(line,'%f',[1 length(kk)]);
                km=(units=='m');  data(k,km)=data(k,km)*.001;
                ku=(units=='�');  data(k,ku)=data(k,ku)*.000001;
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
                    if strmatch('EMG',ch(i).type); jemg=[jemg i]; end
                else % acceleration only for sensors 14-16
                    if strmatch('ACC X',ch(i).type); jax=[jax i]; end
                    if strmatch('ACC Y',ch(i).type); jay=[jay i]; end
                    if strmatch('ACC Z',ch(i).type); jaz=[jaz i]; end
                end
            end
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




function [emgcyc, emgcycstd, emgcyclabel, emgcycfreq] = calcEmgCycle(emg, ax, ay, az, plots)
% this function takes the loaded raw emg data, and calculates
% the data for the average emg for the gait cycle. this is a much smaller
% amount of data to keep in memory

% plots = 0 or 1, depending if you want to see plots accompanying the
% calculation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finds the peaks of the filtered acceleration data

[bfa,afa]=butter(3,25/(ax(1).freq/2));


for i=1:3
    axf=filtfilt(bfa,afa,ax(i).data);
    ayf=filtfilt(bfa,afa,ay(i).data);
    azf=filtfilt(bfa,afa,az(i).data);
    % amag(:,i)=(ax(i).data.^2+ay(i).data.^2+az(i).data.^2).^0.5; % unflitered acceleration magnitudes
    amagf(:,i)=(axf.^2+ayf.^2+azf.^2).^0.5;
end

if plots
    figure()
    for i = 1:3
        subplot(4,1,i);
        %Plots the raw acc data of x,y,z for each ankle and lumbar
        plot(ax(1).time,[ax(i).data ay(i).data az(i).data]);
        hold on;
        %Plots the filtered acc data of x,y,z for each ankle and lumbar
        %overlayed as dashes
        plot(ax(1).time,[axf ayf azf],'--');
        hold off
        title(ax(i).label);
        legend('ax_raw', 'ay_raw', 'az_raw','ax_filt','ay_filt','az_filt');
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uses the magnitudes from filtered acc data and finds the peaks
[hsr, hsrp]=findpeaks(amagf(:,1),'MinPeakHeight',2.,'MinPeakDistance',100); % [heel strike right ankle, time of strike]
[hsl, hslp]=findpeaks(amagf(:,2),'MinPeakHeight',2.,'MinPeakDistance',100); % [heel strike left ankle, time of strike]

if plots
    % Plots the peaks as x's and o's
    subplot(4,1,4);
    plot(ax(1).time,amagf,'-');
    hold on;
    plot(ax(1).time(hsrp),hsr, 'o');
    plot(ax(1).time(hslp),hsl,'x');
    hold off;
    legend('R Ankle', 'L Ankle', 'Lumbar')
    title('Peaks of Acceleration Magnitudes, filtered')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter the EMG data
% Use 3 filters to remove non-EMG frequency range noise, drift, and
% then get nice activation envelopes
% e.g. for a 2000 Hz collection,
%   350Hz = 350/(freq/2) = 350/(1000) = 0.35
%     1Hz =   1/(freq/2) =   1/(1000) = 0.001
%    10Hz =  10/(freq/2) =  10/(1000) = 0.01
[b,a]=butter(4,350/(emg(1).freq/2),'low'); %Used to remove high-frequency noise above 350Hz
[bb,aa]=butter(4,1/(emg(1).freq/2),'high'); %Used to remove low-frequency drift below 1Hz
[bbb,aaa]=butter(4,10/(emg(1).freq/2),'low'); %Used to filter to 10Hz to get envelope
emgdatar = zeros(size(emg(1).data));% preallocate for speed
emgdatalabel = cell(1,12);% preallocate for speed
for ii=1:12
    emgdatar(:,ii)=emg(ii).data; %Raw emg data - Here just pulling the matrix of data out of the structure I loaded
    emgdatalabel{ii}=emg(ii).label;
end
emgdatar = detrend(emgdatar,0); % remove DC offset
EMfr=filtfilt(bb,aa,emgdatar); %Zero-shift filter removing drift first
EMGr=filtfilt(b,a,EMfr); %Zero-shift filter removing high frequency noise
EMGabs=abs(EMGr); %Rectify data
emgdata=filtfilt(bbb,aaa,EMGabs); %Filter to envelopes of activation

if plots % plots the filtered emg data
    figure()
    for i = 1:12
        subplot(12,1,i);
        plot(emg(1).time,emgdata(:,i));
        title(emg(i).label);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Computes the average emg cycle
emgtime=emg(1).time;
for j=1:6
    emgc(j)=avgcycle(emgtime,emgdata(:,j),ax(1).time(hsrp),10,50); %right leg muslces
    emgc(6+j)=avgcycle(emgtime,emgdata(:,6+j),ax(2).time(hslp),10,50); % left leg muscles
end
lumbar = avgcycle(ax(3).time,amagf(:,3),ax(1).time(hsrp),10,50); % lumbar, relative to left leg heel strike



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Normalize the EMG data
for j=1:12
    emgrms(j)=rms(emgdata(:,j));
    normemg(:,j)=(emgc(j).avg)./(emgrms(j));
    normemgstd(:,j)=(emgc(j).sd)./(emgrms(j));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% outputs
emgcyc = normemg;
emgcycstd = normemgstd;
emgcyclabel = emgdatalabel;
emgcycfreq = emg(1).freq;
%lumbarcyc = lumbar;
end


function xc = avgcycle(time,x,tc,hcf,lcf)
% xc = avgcycle(x,tc,hcf,lcf)
npts=101;
% if (length(hcf)>0)
%     [bhf,ahf]=butter(3,hcf/(x.freq/2),'high');
%     xf=filtfilt(bhf,ahf,x.data);
% else
%     xf=x.data;
% end
% if (length(lcf)>0)
%     [blf,alf]=butter(3,lcf/(x.freq/2));
%     xf=filtfilt(blf,alf,abs(xf));
% end
xf=x;
xc.cycles=zeros(npts,size(tc,1));
for j=1:length(tc)-1
    j1=find(time>tc(j));  j1=j1(1);
    j2=find(time>tc(j+1));  j2=j2(1);
    xc.cycles(:,j)=normcycle(xf(j1:j2),npts);
    xc.period(j)=time(j2)-time(j1);
end
xc.avg=mean(xc.cycles')';
xc.sd=std(xc.cycles')';
% xc.label=x.label;
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
