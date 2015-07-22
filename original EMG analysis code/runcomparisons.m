s1dir='..\pilot\emgroad_102913\results\';
s1=[[s1dir,'\bikeG_smooth\GHS'];[s1dir,'\bikeA_smooth\AHS'];[s1dir,'\bikeI_smooth\IHS'];
    [s1dir,'\bikeG_gravel\GHG'];[s1dir,'\bikeA_gravel\AHG'];[s1dir,'\bikeI_gravel\IHG'];
    [s1dir,'\bikeG_rumble\GHR'];[s1dir,'\bikeA_rumble\AHR'];[s1dir,'\bikeI_rumble\IHR']];

s2dir='..\pilot\emgroad_111513\results\';
s2=[[s2dir,'\bikeG_smooth\GHS'];[s2dir,'\bikeA_smooth\AHS'];[s2dir,'\bikeI_smooth\IHS'];
    [s2dir,'\bikeG_gravel\GHG'];[s2dir,'\bikeA_gravel\AHG'];[s2dir,'\bikeI_gravel\IHG'];
    [s2dir,'\bikeG_rumble\GHR'];[s2dir,'\bikeA_rumble\AHR'];[s2dir,'\bikeI_rumble\IHR']];

% First comparison is across bikes for smooth, gravel, rumble conditions
emgplots([s1(1:3,:)],'S1: Smooth Road','..\results2\s1emgS');
emgplots([s1(4:6,:)],'S1: Gravel Road','..\results2\s1emgG');
emgplots([s1(7:9,:)],'S1: Rumble Road','..\results2\s1emgR');
emgplots([s2(1:3,:)],'S2: Smooth Road','..\results2\s2emgS');
emgplots([s2(4:6,:)],'S2: Gravel Road','..\results2\s2emgG');
emgplots([s2(7:9,:)],'S2: Rumble Road','..\results2\s2emgR');

% First comparison is across bikes for smooth, gravel, rumble conditions
emgcomparison([s1(1:3,:)],'S1 - Smooth Road','..\results2\s1smooth');
emgcomparison([s1(4:6,:)],'S1 - Gravel Road','..\results2\s1gravel');
emgcomparison([s1(7:9,:)],'S1 - Rumble Road','..\results2\s1rumble');

emgcomparison([s2(1:3,:)],'S2 - Smooth Road','..\results2\s2smooth');
emgcomparison([s2(4:6,:)],'S2 - Gravel Road','..\results2\s2gravel');
emgcomparison([s2(7:9,:)],'S2 - Rumble Road','..\results2\s2rumble');

% Second comparison is across road conditions for same bike
emgcomparison([s1([1 4 7],:)],'S1 - Bike G','..\results2\s1G');
emgcomparison([s1([2 5 8],:)],'S1 - Bike A','..\results2\s1A');
emgcomparison([s1([3 6 9],:)],'S1 - Bike I','..\results2\s1I');

emgcomparison([s2([1 4 7],:)],'S2 - Bike G','..\results2\s2G');
emgcomparison([s2([2 5 8],:)],'S2 - Bike A','..\results2\s2A');
emgcomparison([s2([3 6 9],:)],'S2 - Bike I','..\results2\s2I');

% Now summarize the gps data
gpscomparison([s1(1:3,:)],'S1 - Smooth Road','..\results2\s1smooth_gps');
gpscomparison([s1(4:6,:)],'S1 - Gravel Road','..\results2\s1gravel_gps');
gpscomparison([s1(7:9,:)],'S1 - Rumble Road','..\results2\s1rumble_gps');

gpscomparison([s2(1:3,:)],'S2 - Smooth Road','..\results2\s2smooth_gps');
gpscomparison([s2(4:6,:)],'S2 - Gravel Road','..\results2\s2gravel_gps');
gpscomparison([s2(7:9,:)],'S2 - Rumble Road','..\results2\s2rumble_gps');
