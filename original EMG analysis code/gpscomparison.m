function hf = gpscomparison(files,stitle,figtitle)

% Loop over 3 conditions: bike or road
load(files(1,:));   gps1=gpsc;        legends(1,:)=files(1,end-2:end);
load(files(2,:));   gps2=gpsc;        legends(2,:)=files(2,end-2:end);
load(files(3,:));   gps3=gpsc;        legends(3,:)=files(3,end-2:end);

hf=figure('units','normalized','outerposition',[0 0 1 1]);

[pow1,cad1,spd1]=rmssd(gps1);
[pow2,cad2,spd2]=rmssd(gps2);
[pow3,cad3,spd3]=rmssd(gps3);
subplot(5,2,1); makeplot(gps1.power,gps2.power,gps3.power,'power','watts',legends);
subplot(5,2,2); makebarplot(pow1,pow2,pow3,'power','watts',legends);
subplot(5,2,3); makeplot(gps1.cadence,gps2.cadence,gps3.cadence,'cadence','rpm',legends);
subplot(5,2,4); makebarplot(cad1,cad2,cad3,'cadence','rpm',legends);
subplot(5,2,5); makeplot(gps1.speed,gps2.speed,gps3.speed,'speed','km/hr',legends);
subplot(5,2,6); makebarplot(spd1,spd2,spd3,'speed','km/hr',legends);
subplot(5,2,7); makeplot(gps1.altitude,gps2.altitude,gps3.altitude,'altitude','m',legends);
subplot(5,2,8); makeplot(gps1.distance,gps2.distance,gps3.distance,'distance','km',legends);
subplot(5,2,9); makeplot(gps1.latitude,gps2.latitude,gps3.latitude,'latitude','deg',legends);
subplot(5,2,10); makeplot(gps1.longitude,gps2.longitude,gps3.longitude,'longitude','deg',legends);

suptitle(stitle);
saveas(hf,figtitle,'jpg');


function done=makebarplot(x1,x2,x3,ptitle,ylab,legends)
bar([x1(1) x2(1) x3(1)]');
hold on;
errorb([x1(1) x2(1) x3(1)]',[x1(2) x2(2) x3(2)]','top');
ylabel(ylab);
title(ptitle);
set(gca,'XTickLabel',legends);


function [pow,cad,spd]=rmssd(gps)
pow=[mean(gps.power) std(gps.power)];
cad=[mean(gps.cadence) std(gps.cadence)];
spd=[mean(gps.speed) std(gps.speed)];


function done=makeplot(x1,x2,x3,ptitle,ylab,legends)
plot(x1,'b');
hold on;
plot(x2,'g');
plot(x3,'r');
h=legend(legends,'Location','NorthWest');
set(h,'FontSize',6,'Box','off');
ylabel(ylab);
xlabel('time (s)');
title(ptitle);

