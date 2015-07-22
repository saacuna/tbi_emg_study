function figures = cyclicplots(emgc,axc,ayc,azc,acc,gpsc,figlabel)
%

figures(1)=figure;
makeplots(emgc,10^6,'emg','crank cycle (%)','microvolts',figlabel);
figures(2)=figure;
makeplots(acc,1,'ax','crank cycle (%)','acc (g)',figlabel);
figures(3)=figure;
makeplots(acc,1,'ay','crank cycle (%)','acc (g)',figlabel);
figures(4)=figure;
makeplots(acc,1,'az','crank cycle (%)','acc (g)',figlabel);
figures(5)=figure;
makeplots(acc,1,'acc','crank cycle (%)','acc (g)',figlabel);


function done=makeplots(xc,gain,ms,xlab,ylab,figlabel)
xvar=0:size(xc(1).cycles,1)-1;
xvar=100*xvar/max(xvar);
for i=1:length(xc)
    subplot(ceil(length(xc)/2),2,i);
    plot(xvar,gain*xc(i).cycles);
    ymax=max(gain*xc(i).cycles(:));
    ymin=min(gain*xc(i).cycles(:));
    yrange=ymax-ymin;
    axis([min(xvar) max(xvar) ymin ymax]);
    title([figlabel,' ',xc(i).label,' ',ms]);
    xlabel(xlab);
    ylabel(ylab);
end
