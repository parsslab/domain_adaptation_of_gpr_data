
function mix_desc_create
% clc;
% clear all;


classes = {'DST';  % 1   
           'WST';  % 2
           'DSsT'  % 3
           'WSsT'  % 4
           };

subFolder = 'Noise_13';
mix=[];
%------------------------------------
file=['Descriptors/',subFolder, '/',classes{1},'_d.mat']
load(sprintf('%s',file));
mix = [mix desc];
clear desc;
%------------------------------------

file=['Descriptors/',subFolder, '/',classes{3},'_d.mat']
load(sprintf('%s',file));
mix = [mix desc];
clear desc;
%------------------------------------

file=['Descriptors/',subFolder, '/',classes{4},'_d.mat']
load(sprintf('%s',file));
mix = [mix desc];
clear desc;
%------------------------------------

desc_count = size(mix,2);

mix_ind = randperm(desc_count);

desc = mix(:,mix_ind(1:400));
mix_desc = desc;
clear mix;

file=['Descriptors/', subFolder, '/', 'Mix0','_d.mat'];
save(file,'desc');

clear desc;

%------------------------------------
file=['Descriptors/',subFolder, '/',classes{2},'_d.mat']
load(sprintf('%s',file));

desc_count_tar = size(desc,2);
desc_ind_tar = randperm(desc_count_tar);
desc_tar = desc(:,desc_ind_tar(:));
clear desc;
%------------------------------------

mix_desc1 = [mix_desc desc_tar(:,1:5)];
mix_desc2 = [mix_desc desc_tar(:,1:10)];
mix_desc3 = [mix_desc desc_tar(:,1:50)];
mix_desc4 = [mix_desc desc_tar(:,1:100)];
mix_desc5 = [mix_desc desc_tar(:,1:200)];
mix_desc6 = [mix_desc desc_tar(:,1:320)];
test_tar = desc_tar(:,387:486);

desc = mix_desc1;
file=['Descriptors/', subFolder, '/', 'Mix1','_d.mat'];
save(file,'desc');
clear desc;

desc = mix_desc2;
file=['Descriptors/', subFolder, '/', 'Mix2','_d.mat'];
save(file,'desc');
clear desc;

desc = mix_desc3;
file=['Descriptors/', subFolder, '/', 'Mix3','_d.mat'];
save(file,'desc');
clear desc;

desc = mix_desc4;
file=['Descriptors/', subFolder, '/', 'Mix4','_d.mat'];
save(file,'desc');
clear desc;

desc = mix_desc5;
file=['Descriptors/', subFolder, '/', 'Mix5','_d.mat'];
save(file,'desc');
clear desc;

desc = mix_desc6;
file=['Descriptors/', subFolder, '/', 'Mix6','_d.mat'];
save(file,'desc');
clear desc; 

desc = test_tar;
file=['Descriptors/', subFolder, '/', 'test_tar','_d.mat'];
save(file,'desc');
clear desc;


end











