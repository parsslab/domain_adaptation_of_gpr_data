
function Success_mix = cross_val_v1_1_mix

% clc, clear all, close all

names = {  'DSC';  % 1
           'DST';  % 2
           'WST';  % 3
           'DSsT'  % 4
           'WSsT'  % 5
           'Mix0'   % 6
           'Mix1'  % 7
           'Mix2'  % 8
           'Mix3'  % 9
           'Mix4'  % 10
           'Mix5'  % 11
           'Mix6'  % 12
           'test_tar' %13
           };

subFolder = 'Noise_13'; 

for idx = 6:12

classes{1} = names{idx};  % Model file that predicts
classes{2} = names{13};  % Target desc that is predicted
% classes{3} = names{4};  
% classes{4} = names{2};  

clsCount = numel(classes);
srcCount = clsCount-1;


modelFile=['Models/',subFolder, '/',classes{1},'_m.mat'];
load(modelFile);

cModels{1} = model;
clear model;

krnPram = cModels{1}.kp;


descfile=['Descriptors/',subFolder, '/',classes{2},'_d.mat'];
load(descfile);
desc_p = desc;
clear desc
[featSize dataCount_p] = size(desc_p);



C2 = 10;

testSize_p = dataCount_p;
randInd_p = randperm(dataCount_p);

testRange_p = 1:testSize_p;

xTst_tar = [desc_p(:,randInd_p(testRange_p))];


% for j = 1:1

    xTr_src = cModels{1}.X;
    Ktst_src_tar = compute_kernel(xTst_tar,xTr_src,krnPram);
    
% end


[pred, margins] = predict_LS_SVM(Ktst_src_tar, cModels{1});

TruePos = sum((pred(1:testSize_p) + 1 )/2);
FalseNeg = sum((pred(1:testSize_p) - 1 )/-2);

Succes_p = TruePos / (TruePos+FalseNeg);

Success_mix(idx-5) = Succes_p;

end

Success_mix = Success_mix;

end






















