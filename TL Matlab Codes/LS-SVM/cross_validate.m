


clc, clear all, close all

names = {  'DST';  % 1
           'WST';  % 2
           'DSsT'  % 3
           'WSsT'  % 4
           'Mix'   % 5
           'Mix1'  % 6
           'Mix2'  % 7
           'Mix3'  % 8
           'Mix4'  % 9
           'Mix5'  % 10
           'Mix6'  % 11
           'test_tar' %12
           };

subFolder = 'Noise_13'; 

classes{1} = names{4};  % Model file that predicts
classes{2} = names{2};  % Target desc that is predicted
% classes{3} = names{4};  
% classes{4} = names{2};  

clsCount = numel(classes);
srcCount = clsCount-1;


modelFile=['Models/',subFolder, '/',classes{1},'_m.mat']
load(modelFile);

cModels{1} = model;
clear model;

krnPram = cModels{1}.kp;


descfile=['Descriptors/',subFolder, '/',classes{2},'_d.mat']
load(descfile);
desc_p = desc;
clear desc
[featSize dataCount_p] = size(desc_p)



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

TruePos = sum((pred(1:testSize_p) + 1 )/2)
FalseNeg = sum((pred(1:testSize_p) - 1 )/-2)

Succes_p = TruePos / (TruePos+FalseNeg)




























