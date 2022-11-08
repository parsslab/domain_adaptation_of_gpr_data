

curDir = pwd;
idcs   = strfind(curDir,'\');
rootDir = curDir(1:idcs(end)-1);
gprDir = strcat(rootDir, '\','gpr Generated Files');
imgPath = strcat(gprDir, '\','20-Demo Image');


imgCode = input('Enter out-file name (in 20-Demo Image) to process\n>>');
% Entery example : 'DST_Dimension_rgwc_2111.out'
% imgCode = 'DST_Dimension_rgwc_2111.out';

gprFile = strcat(imgPath,'\',imgCode);

c=h5read(gprFile,'/rxs/rx1/Ex');

plot(c(15,:),'LineWidth',2)



% %xTick = 1:100:2000;
% set(gca,'YGrid','on');
% set(gca,'XGrid','on');
% 
 set(gca,'FontSize', 16, 'fontweight','b')
% ylim([0.7 1])
% set(gca, 'FontSize', 16, 'fontweight','b')
xlabel('Zaman', 'FontSize', 16, 'fontweight','b')
ylabel('Genlik', 'FontSize', 16, 'fontweight','b')

