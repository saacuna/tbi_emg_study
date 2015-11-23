classdef emgDataRaw_tbiNMBL < handle
    % Filename: emgDataRaw_tbiNMBL.m
    % Author:   Samuel Acuna
    % Date:     20 Nov 2015
    % Description:
    % This class file is used to store all the EMG data from a single
    % trial. This class can generate a more condensed data format that can
    % be used for further processing.
    %
    % Example usage:
    %
    
    
    properties (GetAccess = 'public', SetAccess = 'private')
        % public read access, but private write access.
        
        subjectID; % e.g. TBI-06
        subjectInitials; % e.g. SA
        dateCollected; % e.g. 'nov 23, 2015'
        testPoint; % 1, 2, 6, or 10
        dataCollectedBy; % e.g. 'SA' or 'KR'
        walkingSpeed_preferred; % e.g.  2.0 mph. for testPoint 1, this is the same as the baseline.
        walkingSpeed_baseline; % e.g.  1.6 mph
        trialType; % relaxed standing, relaxed lying down, baseline preferred treadmill, new preferred treadmill, overground
        notes; % anything worth mentioning for this data (e.g. hands on treadmill)
        
        
        emg;  % structure containing the emg data
        accX; % structure containing the x-acceleration data
        accY; % structure containing the y-acceleration data
        accZ; % structure containing the z-acceleration data
        
        % each structure contains file name, time, and data matrix
        % e.g.
        %     emg.label
        %     emg.type
        %     emg.sensor
        %     emg.freq
        %     emg.npts
        %     emg.xstart
        %     emg.unit
        %     emg.domainunit
        %     emg.sysgain
        %     emg.adgain
        %     emg.bitres
        %     emg.bias
        %     emg.hpcutoff
        %     emg.lpcutoff
        %     emg.file
        %     emg.time
        %     emg.data
        
    end
    methods ( Access = public )
        % constructor function
        function obj = emgDataRaw_tbiNMBL(infile,inpath)
            %   Inputs (optional)
            %       infile - file to be loaded
            %                If infile is unspecified, the user is prompted to select the input file
            %       inpath - directory of location where data file is located
            %               when no path is specified, it defaults to current directory
            
            if nargin>=0
                infile = []; inpath = [];
            end
            
%             
%             narg = nargin;
%             if (narg==0);
%                 [infile, inpath]=uigetfile('*.txt','Select input file')
%                 if isempty(infile)
%                     disp('No file selected');
%                     emg=[]; acc=[]; ax=[];  ay=[];  az=[];
%                     return;
%                 end
%             elseif (narg==1);
%                 if ~strmatch('txt',infile(end-2:end))
%                     infile = [infile(1:length(infile)) '.txt'];
%                 end
%                 inpath=[];
%             elseif (narg==2);
%                 if strmatch(infile(end-2:end)~='txt')
%                     infile = [infile(1:length(infile)) '.txt'];
%                 end
%             end
%             
%             
%             % generate emg, accX, accY, accZ data
%             load_emgworks(obj,infile,inpath)
            
            % record subject / trial info
            obj.subjectID = '';
            obj.subjectInitials = '';
            obj.dateCollected = '';
            obj.testPoint = '01';
            obj.dataCollectedBy = '';
            obj.walkingSpeed_preferred = '';
            obj.walkingSpeed_baseline = '';
            obj.trialType = '';
            obj.notes = '';
            
            updateSubjectTrialInfo(obj);
            
                
        end
        
        function updateSubjectTrialInfo(obj)
            prompt1 = {'Subject ID:   (ex: "TBI-06")',...
                'Subject Initials:   (ex: "SA")',...
                'Date Collected:   (yyyy-MM-dd)',...
                'Data Collected by:   (ex: "SA")'};
            prompt1_defaultAnswer = {obj.subjectID,obj.subjectInitials,obj.dateCollected,obj.dataCollectedBy};
            prompt1_title = 'Trial Information';
            answer1 = inputdlg(prompt1,prompt1_title,[1 40],prompt1_defaultAnswer);
            
            obj.subjectID = answer1(1);
            obj.subjectInitials = answer1(2);
            obj.dateCollected = answer1(3);
            obj.dataCollectedBy = answer1(4);
            
            prompt2 = {'01','02','06','10'};
            if obj.testPoint == '01'
                default2 = 1;
            elseif obj.testPoint == '02'
                default2 = 2;
            elseif obj.testPoint == '06'
                default2 = 3;
            elseif obj.testPoint == '10'
                default2 = 4;
            end
            answer2 = listdlg('PromptString','Select Test Point:','SelectionMode','single','Name','Test Point','ListString',prompt2,'InitialValue',default2,'ListSize',[100 50]);
            obj.testPoint = prompt2(answer2);
            
            prompt3 = {'Preferred walking speed:   (ex: "2.1 mph")',...
                'Baseline walking speed:   (ex: "2.0 mph")',...
                'Trial Type:   (ex: "Relaxed Standing")',...
                'Notes:   (ex: "hands on treadmill")'};
%             prompt3_defaultAnswer
            prompt3_title = 'Trial Information';
            
        end
    end
    
    methods ( Access = private )
        function load_emgworks(obj, infile,inpath)
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
                ch(nch)=readhdr(line,fid,nch);
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
                disp(['line ',num2str(k),' time ',num2str(data(k,1))]);
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
            obj.emg=ch(jemg);
            for i=1:length(obj.emg); obj.emg(i).file=file;  obj.emg(i).time=data(1:obj.emg(i).npts,jemg(i)*2-1);   obj.emg(i).data=data(1:obj.emg(i).npts,jemg(i)*2); end
            obj.accX=ch(jax);
            for i=1:length(obj.accX); obj.accX(i).file=file;   obj.accX(i).time=data(1:obj.accX(i).npts,jax(i)*2-1);   obj.accX(i).data=data(1:obj.accX(i).npts,jax(i)*2); end
            obj.accY=ch(jay);
            for i=1:length(obj.accY); obj.accY(i).file=file;   obj.accY(i).time=data(1:obj.accY(i).npts,jay(i)*2-1);   obj.accY(i).data=data(1:obj.accY(i).npts,jay(i)*2); end
            obj.accZ=ch(jaz);
            for i=1:length(obj.accZ);  obj.accZ(i).file=file;  obj.accZ(i).time=data(1:obj.accZ(i).npts,jaz(i)*2-1);   obj.accZ(i).data=data(1:obj.accZ(i).npts,jaz(i)*2); end
            clear ch;
            clear data;
            fclose(fid);
            
        end
        
    end
end

% local functions only (within this m-file)
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