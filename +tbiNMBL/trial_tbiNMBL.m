classdef trial_tbiNMBL < handle
    % Filename: trial_tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     27 Jan 2016
    % Description:
    % This class file is used to store all the EMG data from a single
    % trial. The class creates a much smaller data file of the emg curves
    % for the average gait cycle of the trial, as well as collecting all
    % the trial emg labels and freq. features a plot of emg data
    %
    % The raw emg data must be in a .txt format, not .hpf
    % To create the .txt version, open program 'emgworks_analysis' on collection
    % computer. load .hpf into workspace, click 'Tools', 'export to text tile'. Put this
    % file in the same location as the original .hpf
    %
    % Example usage:
    %       tr1 = tbiNMBL.trial_tbiNMBL() %load emg data and calculate average emg cycle data
    %       tr1.plotTrial() % plots average emg cycle data for all muscles recorded
    %       tr1.setTrialType() % update trialtype for file 
    %       tr1.viewEmgLabels() % look at list of EMG labels from the collection
    %       save('tr1.mat','emg1') % save raw and calculated data, so dont have to calculate again

    properties (GetAccess = 'public', SetAccess = 'private')
        trialType; % e.g. check muscles, treadmill_preferredSpeed, etc. see constants_tbiNMBL
        emgData; % normalized emg data over the average gait cycle
        emgStd; % standard deviationnormalized emg data over the average gait cycle
        emgLabel; % names of all the muscles corresponding to each column of emg
        emgFreq; % sampling frequency of this emg data
    end
    properties (Dependent)
        emgDataSize; % m x n, string of the size of the emg data matrix
        emgStdSize; % m x n, string of the size of the emg std matrix
        emgLabelSize; % m x n, string of the size of the emg label matrix
    end
    
    methods (Access = public)
        function tr = trial_tbiNMBL(infile, inpath) % constructor function
            %   Inputs (optional)
            %       1. infile : file to be loaded,
            %                   e.g. 'test.txt'
            %                   If infile is unspecified, the user is prompted to select the input file
            %       2. inpath : directory of location where data file is located
            %                   e.g. '/Users/user1/Documents/emg_directory/'
            %                   when no path is specified, it defaults to current directory

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % load EMG data txt file
            narg = nargin;
            if (narg==0); % gui choose emg txt file
                [infile, inpath]=uigetfile('*.txt','Select input file');
                if infile == 0
                    error('Canceled. No file selected');
                end
            else % check filename and pathname are valid
                % append .txt if not included on infile name
                if ~strcmpi('txt',infile(end-2:end))
                    infile = [infile(1:length(infile)) '.txt'];
                end
                if (narg == 1) % if inpath not specified
                    inpath=[pwd '/']; % sets the current working directory
                else
                    if ~strcmpi(inpath(end),'/') % makes sure slash is at end of path
                        inpath = [inpath '/'];
                    end
                end
                % check file is in directory
                original_directory = pwd;
                try
                    cd(inpath);
                catch
                    error('inpath : directory name not valid. Fix this');
                end
                fileFound = false;
                D = dir('*.txt');
                for i = 1:length(D)
                    if strcmpi(infile,D(i).name)
                        fileFound = true;
                        break;
                    end
                end
                cd(original_directory);
                if fileFound
                    disp('file found.');
                else
                    error('infile : specified filename not found in this directory.');
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % generate emg, ax, ay, az data
            disp('loading and converting raw emg data into matlab friendly format. This might take a while...')
            try
                [emg, ax, ay, az] = tr.load_emgworks(infile,inpath); % outputs = emg structure, acceleration in x,y,z
            catch
                error('could not load emgworks file. Something went wrong in the load_emgworks function.');
            end
            disp('conversion completed. now calculating emg data over average gait cycle....')
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % calculate emg data over the average gate cycle
            calculationPlots = 0; % set to true if you want to see plots of intermediate calculations
            [emgcyc, emgcycstd, emgcyclabel, emgcycfreq] = tr.calcEmgCycle(emg, ax, ay, az, calculationPlots); 
            disp('Successfully calculated EMG data for average gait cycle. Can export to saved file using exportEmgData() function')
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % construct emg data
            tr.emgData = emgcyc;
            tr.emgStd = emgcycstd;
            tr.emgLabel = emgcyclabel;
            tr.emgFreq = emgcycfreq;
            tr.setTrialType(); % specify trial type
        end
        function setTrialType(tr)
            trialTypeChoices = tbiNMBL.constants_tbiNMBL.trialType;
            prompt_defaultAnswer= find(strcmp(tr.trialType,trialTypeChoices)==1);
            if isempty(prompt_defaultAnswer); prompt_defaultAnswer = 1; end; % if setting for first time
            prompt_title = 'Select Trial Type:';
            prompt_title2 = 'Trial Type';
            prompt_answer = listdlg('PromptString',prompt_title,'SelectionMode','single','Name',prompt_title2,'ListString',trialTypeChoices,'InitialValue',prompt_defaultAnswer,'ListSize',[150 75]);
            if isempty(prompt_answer); return; end; % user canceled. bail out.
            % update trial type
            tr.trialType = trialTypeChoices{prompt_answer};
        end
        function plotTrial(tr)
            % this wrapper function plots the emg gait cycle data for the
            % calculated trial. cool, eh?
            %   6 muscles (mean +/- std)

            figure('Name','Trial EMG');
            tr.plotTrialEmg(1);
        end
        function viewEmgLabels(tr) % look at list of EMG labels from the collection
            disp('Trial EMG Muscle Labels:')
            tr.checkEmgLabels()
        end
    end
    
    methods (Access = {?tbiNMBL.testPoint_tbiNMBL, ?tbiNMBL.subject_tbiNMBL})
        % plotting functions
        function plotTrialEmg(tr,plotColorIndex)
            for j=1:6 % RIGHT LEG 
                subplot(6,2,2*j); % plots on right half of figure
                hold on
                if tbiNMBL.constants_tbiNMBL.showErrorBars
                shadedErrorBar([0:100]',tr.emgData(:,j),tr.emgStd(:,j),{'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{plotColorIndex}},tbiNMBL.constants_tbiNMBL.transparentErrorBars);
                end
                plot([0:100]',tr.emgData(:,j),'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{plotColorIndex});
                hold off
                title(tr.emgLabel(j));
                ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
                xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
            end
            for j=1:6 % LEFT LEG
                subplot(6,2,2*j-1); % plots on left half of figure
                hold on
                if tbiNMBL.constants_tbiNMBL.showErrorBars
                shadedErrorBar([0:100]',tr.emgData(:,6+j),tr.emgStd(:,6+j),{'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{plotColorIndex}},tbiNMBL.constants_tbiNMBL.transparentErrorBars);
                end
                plot([0:100]',tr.emgData(:,6+j),'color',tbiNMBL.constants_tbiNMBL.emgPlotColors{plotColorIndex});
                hold off
                title(tr.emgLabel(6+j));
                ylim(tbiNMBL.constants_tbiNMBL.emgPlotYAxisLimits);
                xlabel(tbiNMBL.constants_tbiNMBL.emgPlotXAxisLabel);
            end 
        end
        function checkEmgLabels(tr)
            disp(tr.emgLabel');  % these labels should be same for each trial examined
        end
    end
    methods (Access = private)
        % main functions used in calculating emg data
        function [emg, ax, ay, az] = load_emgworks(tr,infile,inpath)
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
                nch=nch+1;
                ch(nch)=tr.readhdr(line,fid,nch);
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
                if strmatch('EMG',ch(i).type); jemg=[jemg i]; end
                if strmatch('ACC X',ch(i).type); jax=[jax i]; end
                if strmatch('ACC Y',ch(i).type); jay=[jay i]; end
                if strmatch('ACC Z',ch(i).type); jaz=[jaz i]; end
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
        function [emgcyc, emgcycstd, emgcyclabel, emgcycfreq] = calcEmgCycle(tr, emg, ax, ay, az, plots)
            % this function takes the loaded raw emg data, and calculates
            % the data for the average emg for the gait cycle. this is a much smaller
            % amount of data to keep in memory
            
            % plots = 0 or 1, depending if you want to see plots accompanying the
            % calculation
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Finds the peaks of the filtered acceleration data
            
            [bfa,afa]=butter(3,25/(ax(1).freq/2));
            
            
            for i=1:3
                axf=filtfilt(bfa,afa,ax(i).data);
                ayf=filtfilt(bfa,afa,ay(i).data);
                azf=filtfilt(bfa,afa,az(i).data);
                amag(:,i)=(ax(i).data.^2+ay(i).data.^2+az(i).data.^2).^0.5; % acceleration magnitudes
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
            % then get nice activation envelopes - numbers are set for 2000 Hz
            % collection
            [b,a]=butter(4,0.35,'low'); %Used to remove high-frequency noise above 350Hz
            [bb,aa]=butter(4,0.001,'high'); %Used to remove low-frequency drift below 1Hz
            [bbb,aaa]=butter(4,0.01,'low'); %Used to filter to 10Hz to get envelope
            emgdatar = zeros(size(emg(1).data));% preallocate for speed
            emgdatalabel = cell(1,12);% preallocate for speed
            for ii=1:12
                emgdatar(:,ii)=emg(ii).data; %Raw emg data - Here just pulling the matrix of data out of the structure I loaded
                emgdatalabel{ii}=emg(ii).label;
            end
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
                emgc(j)=tr.avgcycle(emgtime,emgdata(:,j),ax(1).time(hsrp),10,50); %right leg muslces
                emgc(6+j)=tr.avgcycle(emgtime,emgdata(:,6+j),ax(2).time(hslp),10,50); % left leg muscles
            end
            
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
        end
        % sub functions used in calculating emg data
        function hdr = readhdr(tr,line,fid,nch)
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
        function xc = avgcycle(tr,time,x,tc,hcf,lcf)
            % xc = tr.avgcycle(x,tc,hcf,lcf)
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
                xc.cycles(:,j)=tr.normcycle(xf(j1:j2),npts);
                xc.period(j)=time(j2)-time(j1);
            end
            xc.avg=mean(xc.cycles')';
            xc.sd=std(xc.cycles')';
            % xc.label=x.label;
        end
        function yf = normcycle(tr,y,n,x)
            % yf = tr.normcycle(y,n,x)
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
    end
    methods % used for set and get methods
        function dataSize = get.emgDataSize(tr) %m x n, string of the size of the emg data matrix
            dataSize_num = size(tr.emgData);
            dataSize = [num2str(dataSize_num(1)) 'x' num2str(dataSize_num(2))];
        end
        function set.emgDataSize(tr,~) % cant set size of emg data matrix
            fprintf('%s%d\n','emgDataSize is: ',tr.emgDataSize)
            error('You cannot set the emgDataSize property');
        end
        function stdSize = get.emgStdSize(tr) %m x n, string of the size of the emg data matrix
            stdSize_num = size(tr.emgStd);
            stdSize = [num2str(stdSize_num(1)) 'x' num2str(stdSize_num(2))];
        end
        function set.emgStdSize(tr,~) % cant set size of emg data matrix
            fprintf('%s%d\n','emgStdSize is: ',tr.emgStdSize)
            error('You cannot set the emgStdSize property');
        end
        function labelSize = get.emgLabelSize(tr) %m x n, string of the size of the emg data matrix
            labelSize_num = size(tr.emgLabel);
            labelSize = [num2str(labelSize_num(1)) 'x' num2str(labelSize_num(2))];
        end
        function set.emgLabelSize(tr,~) % cant set size of emg data matrix
            fprintf('%s%d\n','emgLabelSize is: ',tr.emgLabelSize)
            error('You cannot set the emgLabelSize property');
        end
    end
end