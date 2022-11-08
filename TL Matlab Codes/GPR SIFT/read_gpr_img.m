
function [gprImg] = read_gpr_img(imgCode, imgPath)


gprFile = strcat(imgPath,'\',imgCode);

c=h5read(gprFile,'/rxs/rx1/Ex');
gprImg=c(3:end-2,250:2070)';
%gprImg=c(3:end-2,250:2070)';
%gprImg=c(2:end,250:2070)';

end



% if ((imgCode(2) == 'I') || (~isstrprop(imgCode(2),'digit')))
%     imgFiles = strcat('D:\Mehmet\ELECTRONICS\5-EDUCATION\Y.LiSANS\', ...
%         '5-Msc Tez\8-Ground Penetrating Radar\8b-Generated Files');
% else 
%     CurrentFolder = pwd;
%     imgFiles = strcat(CurrentFolder,'\Generated Files');
% end
% 
% sourceFile = strcat(imgFiles,'\Source Images\',imgCode,'.out');
% negativeFile = strcat(imgFiles,'\Negative Images\',imgCode,'.out');
% targetFile = strcat(imgFiles,'\Target Images\',imgCode,'.out');
% 
% if strcmp(imgCode(1),'S')
%     c=h5read(sourceFile,'/rxs/rx1/Ex');
%     gprImg=c(2:end,250:2070)';
% elseif strcmp(imgCode(1),'T')
%     c=h5read(targetFile,'/rxs/rx1/Ex');
%     gprImg=c(2:end,250:2070)';
% else % strcmp(imgCode(1),'N')
%     c=h5read(negativeFile,'/rxs/rx1/Ex');
%     gprImg=c(2:end,250:2070)';
% end
% 
% end

