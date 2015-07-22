function stdfill(y,e,acolor,alpha);%% Use with pre-digested means and standard deviations

% x=(1:length(y))';
x=(.1:.1:100)';
% if isempty(alpha)
% fill([x' fliplr(x')],[y'+e' fliplr(y'-e')],acolor,'linestyle','none');
% else
% fill([x' fliplr(x')],[y'+e' fliplr(y'-e')],acolor,'FaceAlpha',alpha,'linestyle','none');   
% end

plot(x,y+e,':k')
hold on
plot(x,y-e,':k')

plot(x,y,'k','LineWidth',1.5)
end
