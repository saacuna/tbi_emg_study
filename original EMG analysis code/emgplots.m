function hf = emgplots(files,stitle,figtitle)
% Create ensemble emg plots
nsub=size(files,1)/3;
cl={'b-','g--','r:'};
ymin=zeros(8,1); ymax=zeros(8,1);
hf=figure('units','normalized','outerposition',[0 0 1 1]);
% Loop over 3 conditions: bike or road
for j=1:3
    load(files(j,:));
    emgc(5).label='MULTIFIDUS';
    [h(j),ymin,ymax]=makeplots(emgc,10^6,'crank cycle (%)','microvolts',char(cl(j)),ymin,ymax);
    legends(j,:)=files(j,end-2:end);
end
h=legend(h,legends,'Location','best');
set(h,'FontSize',8,'Box','off');
suptitle(stitle);
saveas(hf,figtitle,'jpg');



function [h,ymin,ymax]=makeplots(xc,gain,xlab,ylab,curve,ymin,ymax)
xvar=0:size(xc(1).cycles,1)-1;
xvar=100*xvar/max(xvar);
for i=1:length(xc)
    subplot(ceil(length(xc)/2),2,i);
    h=plot(xvar,gain*xc(i).avg,curve);
    set(h,'LineWidth',4);
    hold on;
    yu=xc(i).avg+xc(i).sd;
    h2=plot(xvar,gain*yu,curve);
    set(h2,'LineWidth',0.5);
    yl=xc(i).avg-xc(i).sd;
    ymax(i)=max([ymax(i); gain*yu(:)]);
%    ymin(i)=min([ymin(i); gain*yl(:)]);
    yrange=ymax(i)-ymin(i);
    axis([min(xvar) max(xvar) ymin(i) ymax(i)+0.05*yrange]);
    if (i>=(length(xc)-1))
        xlabel(xlab);
    else
        set(gca,'XTick',[])
    end
    ylabel(ylab);
    h=title(char(xc(i).label));
    set(h,'fontsize',10);
end
subplot(ceil(length(xc)/2),2,1);

