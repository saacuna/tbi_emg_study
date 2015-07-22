function xc=avgcycle(time,x,tc,hcf,lcf)
% xc=avgcycle(x,tc,hcf,lcf)
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

