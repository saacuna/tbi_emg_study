function figures = emgcomparison(files,stitle,figtitle)
% Loop over 3 conditions: bike or road
nsub=size(files,1)/3;
k=1;
gain=10^6;
for i=1:nsub
    for j=1:3
        disp(['Loading ',files(k,:)]);
        load(files(k,:));
        emgc(5).label='R MULTIFIDUS';   % correction for mislabeled muscle in emg header
        [rms(:,k),sd(:,k)]=rmssd(emgc);
        k=k+1;
        legends(j,:)=files(j,end-2:end);
    end
end

hf=figure('units','normalized','outerposition',[0 0 1 1]);
for i=1:length(emg)
   subplot(ceil(length(emg)/2),2,i);
   if nsub>1
       rmsc=reshape(rms(i,:),3,[]);
       sdc=reshape(sd(i,:),3,[]);
   else
       rmsc=rms(i,:);
       sdc=sd(i,:);
   end
   bar(gain*rmsc);
   hold on;
   errorb(gain*rmsc,gain*sdc,'top');
   ylabel('microvolts');
   title([emgc(i).label]);
   if (i>=(length(emg)-1))
       set(gca,'XTickLabel',legends);
   else
       set(gca,'XTickLabel',[]);
   end
end

suptitle(stitle);
saveas(hf,figtitle,'jpg');

function [rms,sd]=rmssd(xc)
for i=1:length(xc)
    rmsv=sum(xc(i).cycles.^2);
    rmsv=sqrt(rmsv/size(xc(i).cycles,1));
    sd(i,1)=std(rmsv);
    rms(i,1)=mean(rmsv);
end
