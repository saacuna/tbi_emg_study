function [emgc,axc,ayc,azc,acc,gpsc] = cyclicpatterns(emg,ax,ay,az,gps,offset,tt)
% [emgc,axc,ayc,azc,acc,gpsc] = cyclicpatterns(emg,ax,ay,az,gps,offset,tt)
%
%   extract cycles of data
 
% Correct the gps time based on the estimated offset
gps.time=gps.time-offset;

% Low-pass filter the accelerometer used to define pedal strokes
jax=7;  % gastroc accelerometer
cutoff=5;   % low-pass filter cutoff frequency
[bf,af]=butter(3,cutoff/ax(jax).freq/2);
axf=filtfilt(bf,af,ax(jax).data);

% Now sequentially go through each interval
npasses=size(tt,1);
tc=[];
for np=1:npasses
    % Find cycles within duration of interest
    t1=tt(np,1);
    t2=tt(np,2);
    j1=find(ax(jax).time>t1); j1=j1(1);
    j2=find(ax(jax).time>t2); j2=j2(1);

    % Find the acceleration peaks within here to define cycles
    jc=peakseek(axf(j1:j2))+j1-1;
    
    % Add on the cycles
    tc=[tc; ax(jax).time(jc(1:end-1)) ax(jax).time(jc(2:end))];
end

    % Make ensemble cycles of emg and acceleration data
    hcf=10;
    lcf=50;
    for i=1:length(emg)
        emgc(i)=avgcycle(emg(i),tc,hcf,lcf);
    end
    for i=1:length(ax)
        axc(i)=avgcycle(ax(i),tc,[],[]);
    end
    for i=1:length(ay)
        ayc(i)=avgcycle(ay(i),tc,[],[]);
    end
    for i=1:length(az)
        azc(i)=avgcycle(az(i),tc,[],[]);
    end
    
    % Make an ensemble plot acceleration magnitude
    ac=ax;
    for i=1:length(ac)
        ac(i).data=sqrt(ax(i).data.^2+ay(i).data.^2+az(i).data.^2);
        ac(i).type='ACC MAG';
        acc(i)=avgcycle(ac(i),tc,[],[]);
    end
    
    % Now summarize the gps information over these intervals
    gpsc.power=[];  gpsc.cadence=[]; gpsc.speed=[]; gpsc.latitude=[]; gpsc.longitude=[]; gpsc.distance=[]; gpsc.altitude=[]; gpsc.time=[];
    for i=1:npasses
        j1=find(gps.time>tt(i,1));   j1=j1(1);
        j2=find(gps.time>tt(i,2));   j2=j2(1);
        gpsc.power=[gpsc.power; gps.power(j1:j2)];
        gpsc.cadence=[gpsc.cadence; gps.cadence(j1:j2)];
        gpsc.speed=[gpsc.speed; gps.speed(j1:j2)];
        gpsc.latitude=[gpsc.latitude; gps.latitude(j1:j2)];
        gpsc.longitude=[gpsc.longitude; gps.longitude(j1:j2)];
        gpsc.distance=[gpsc.distance; gps.distance(j1:j2)-gps.distance(j1)];
        gpsc.altitude=[gpsc.altitude; gps.altitude(j1:j2)-gps.altitude(j1)];
        gpsc.time=[gpsc.time; gps.time(j1:j2)-gps.time(j1)];
    end
        
    

function xc=avgcycle(x,tc,hcf,lcf)
npts=201;
if (length(hcf)>0)
    [bhf,ahf]=butter(3,hcf/(x.freq/2),'high');
    xf=filtfilt(bhf,ahf,x.data);
else
    xf=x.data;
end
if (length(lcf)>0)
    [blf,alf]=butter(3,lcf/(x.freq/2));
    xf=filtfilt(blf,alf,abs(xf));
end
xc.cycles=zeros(201,size(tc,1));
for j=1:size(tc,1)
    j1=find(x.time>tc(j,1));  j1=j1(1);
    j2=find(x.time>tc(j,2));  j2=j2(1);
    xc.cycles(:,j)=normcycle(xf(j1:j2),npts);
    xc.period(j)=x.time(j2)-x.time(j1);
end
xc.avg=mean(xc.cycles')';
xc.sd=std(xc.cycles')';
xc.label=x.label;

    
