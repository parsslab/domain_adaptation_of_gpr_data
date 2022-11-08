


clc, clear all, close all

names = {  'DST';   %1
           'WST';   %2
           'DSsT'   %3
           'WSsT'   %4
           };

subFolder = 'Noise_13'; 

classes{1} = names{2};  % target class
classes{2} = names{4};  % source class for single model 
classes{3} = names{1};  % source class for multi model
classes{4} = names{3};  % source class for multi model

clsCount = numel(classes);
srcCount = clsCount-1;

for i = 1:clsCount

    file=['Models/', subFolder, '/',classes{i},'_m.mat'];
    load(sprintf('%s',file));
    if i == 1
        fprintf('\nTarget class: %s\n',classes{i});
    else
        fprintf('Source class-%d: %s\n',i-1, classes{i});
    end
    cModels{i} = model;
    clear model;
    
end


krnPram = cModels{1}.kp;


file=['Descriptors/', subFolder, '/',classes{1},'_d.mat'];
load(sprintf('%s',file));
desc_p = desc;
clear desc
[featSize, dataCount_p] = size(desc_p);

% !
% Clutter target için daha önce eðitimde kullanýlan olmamasýný saðla
% !

file=['Descriptors/', subFolder, '/','Clutter','_d.mat'];
load(sprintf('%s',file));
desc_n = desc;
clear desc2
[featSize, dataCount_n] = size(desc_n);

C2 = 10;
dotCnt = 0;

for rpt = 1:20

    testSize_p = 100;
    randInd_p = randperm(dataCount_p);
    
    testSize_n = 100;
    randInd_n = randperm(dataCount_n);
    
    for trCnt = 1:6
        
        
        
        trSize_p = trCnt;
        trRange_p = 1:trSize_p;
        testRange_p = (trSize_p+1):(trSize_p+testSize_p);
        
        
        trSize_n = 6;
        if trSize_n < trCnt 
            trSize_n = trCnt;
        end
        trRange_n = 1:trSize_n;
        testRange_n = (trSize_n+1):(trSize_n+testSize_p);        
        
        xTr_tar = [desc_p(:,randInd_p(trRange_p)), ...
                   desc_n(:,randInd_n(trRange_n))];

        yTr_tar = [ones(1,trSize_p), ...
                  -ones(1,trSize_n)];

        xTst_tar = [desc_p(:,randInd_p(testRange_p)), ...
                  desc_n(:,randInd_n(testRange_n))];


        Ktr_tar_tar = compute_kernel(xTr_tar,xTr_tar,krnPram);
        Ktst_tar_tar = compute_kernel(xTr_tar,xTst_tar,krnPram);
       
        
% ========================================================================= 
% Multi Source Knowledge Transfer 
% =========================================================================
        clear y_head_m
        for j = 2:clsCount

            xTr_src = cModels{j}.X;
            Ktr_tar_src = compute_kernel(xTr_tar,xTr_src,krnPram);
            y_head_m(:,j-1) = Ktr_tar_src * cModels{j}.a;

        end

        model_multi_KT.X = xTr_tar;
        model_multi_KT.C = C2;
        model_multi_KT.K = Ktr_tar_tar;
        model_multi_KT.Y =yTr_tar;

        [model_multi_KT, beta_m, loss_m]=optimize_beta(model_multi_KT, y_head_m); 

        predSrc_m = zeros(size(xTst_tar,2),1);
        for j = 2:clsCount

            xTr_src = cModels{j}.X;
            Ktst_src_tar = compute_kernel(xTr_src,xTst_tar,krnPram); 
            %predSrc_m = predSrc_m + Ktst_src_tar' * cModels{j}.a * beta_m(j-1);
            predSrc_m = predSrc_m + Ktst_src_tar' * cModels{j}.a * beta_m(j-1)+cModels{j}.b;
        end

        
        %-----------------------------
        % Sadece kaynaklarýn lineer birleþiminin kestirim deðeri
        %-----------------------------
        %pred_multi_KT = predSrc_m + Ktst_tar_tar' * model_multi_KT.a + model_multi_KT.b;
        pred_multi_KT = predSrc_m;
        clsf_multi_KT = sign(pred_multi_KT);
        %-----------------------------
        TruePos_TL  = sum((clsf_multi_KT(1:testSize_p)+1)/2);
        FalseNeg_TL = testSize_p - TruePos_TL;

        TrueNeg_TL = sum((clsf_multi_KT(1+testSize_p:end)-1)/-2);
        FalsePos_TL = testSize_n - TrueNeg_TL;

        Succes_multi_KT(trCnt,rpt) = (TruePos_TL/testSize_p + TrueNeg_TL/testSize_n)*100/2;
% =========================================================================

        Ktr_tar_tar = compute_kernel(xTr_tar,xTr_tar,krnPram);

        model_tar.C = C2;
        model_tar.K = Ktr_tar_tar;
        model_tar.Y = yTr_tar;

        [model_tar, looErr_tar, looPred_tar] = LS_SVM(model_tar);


        pred_tar = Ktst_tar_tar' * model_tar.a + model_tar.b;
        clsf_tar = sign(pred_tar); 

        TruePos_Tar  = sum((clsf_tar(1:testSize_p)+1)/2);
        FalseNeg_Tar = testSize_p - TruePos_Tar;

        TrueNeg_Tar = sum((clsf_tar(1+testSize_p:end)-1)/-2);
        FalsePos_Tar = testSize_n - TrueNeg_Tar;

        Succes_tar(trCnt,rpt) = (TruePos_Tar/testSize_p + TrueNeg_Tar/testSize_n)*100/2;
        
% ========================================================================= 
% Single Source Knowledge Transfer 
% =========================================================================             
        clear y_head_s
        for j = 2:2

            xTr_src = cModels{j}.X;
            Ktr_tar_src = compute_kernel(xTr_tar,xTr_src,krnPram);
            y_head_s(:,j-1) = Ktr_tar_src * cModels{j}.a;

        end

        model_sngl_KT.X = xTr_tar;
        model_sngl_KT.C = C2;
        model_sngl_KT.K = Ktr_tar_tar;
        model_sngl_KT.Y =yTr_tar;

        [model_sngl_KT, beta_s, loss_s]=optimize_beta(model_sngl_KT, y_head_s); 

        predSrc_s = zeros(size(xTst_tar,2),1);
        for j = 2:2

            xTr_src = cModels{j}.X;
            Ktst_src_tar = compute_kernel(xTr_src,xTst_tar,krnPram); 
            predSrc_s = predSrc_s + Ktst_src_tar' * cModels{j}.a * beta_s(j-1);

        end

        
        %-----------------------------
        pred_sngl_KT = predSrc_s + Ktst_tar_tar' * model_sngl_KT.a + model_sngl_KT.b;
        clsf_sngl_KT = sign(pred_sngl_KT);
        %-----------------------------
        TruePos_TL  = sum((clsf_sngl_KT(1:testSize_p)+1)/2);
        FalseNeg_TL = testSize_p - TruePos_TL;

        TrueNeg_TL = sum((clsf_sngl_KT(1+testSize_p:end)-1)/-2);
        FalsePos_TL = testSize_n - TrueNeg_TL;

        Succes_sngl_KT(trCnt,rpt) = (TruePos_TL/testSize_p + TrueNeg_TL/testSize_n)*100/2;
% =========================================================================
        
        fprintf('.')
        dotCnt = dotCnt + 1;
        if (mod(dotCnt,50)) == 0
            fprintf('\n')
        end


    end
end

beta_m=beta_m

Succes_multi_KT_mean = mean(Succes_multi_KT,2)
Succes_sngl_KT_mean = mean(Succes_sngl_KT,2)
Succes_tar_mean = mean(Succes_tar,2)

Std_Dev_multi_KT = std(Succes_multi_KT,1,2)'
Std_Dev_sngl_KT = std(Succes_sngl_KT,1,2)'
Std_Dev_tar = std(Succes_tar,1,2)'

figure(1)

plot(Succes_tar_mean, '-+k', 'LineWidth', 2 )
hold on
plot(Succes_multi_KT_mean, '-sb', 'LineWidth', 2 )
hold on
plot(Succes_sngl_KT_mean, '-or', 'LineWidth', 2 )

set(gca,'YGrid','on');
set(gca,'XGrid','on');
set(gca,'XTick',0:1:trCnt, 'FontSize', 16, 'fontweight','b')
% set(gca,'XTick',1:1:trCnt, 'FontSize', 16, 'fontweight','b')
set(gca,'YTick',50:5:100, 'FontSize', 16, 'fontweight','b')
% xlabel('Number of Samples', 'FontSize', 16, 'fontweight','b')
% ylabel('Recognition Rate', 'FontSize', 16, 'fontweight','b')
xlabel('Eðitim Veri Sayýsý', 'FontSize', 16, 'fontweight','b')
ylabel('Kestirim Oraný', 'FontSize', 16, 'fontweight','b')

drawnow

%h = legend('No Adapt', 'Multi-KT','Single-KT',3);
h = legend('BA: Yok', 'Çoklu lineer','BA: Tekli',3);
set(h,'Interpreter','none', 'Location','best')
fprintf('\n');
fprintf('Multi-KT:');
disp(Succes_multi_KT_mean');
fprintf('Single-KT:');
disp(Succes_sngl_KT_mean');
fprintf('No Adapt:');
disp(Succes_tar_mean');

% disp(Succes_multi_KT_mean'-Succes_sngl_KT_mean')
% 
% for i = 1:size(loss_m,2)
% 
% errLoss_m(i) = loss_m(:,i)'*(loss_m(:,i)>0);
%     
% end
% 
% for i = 1:size(loss_m,2)
% 
% errLoss_s(i) = loss_s(:,i)'*(loss_s(:,i)>0);
%     
% end
% 
% figure(2)
% plot(errLoss_m(1:50), '-sc', 'LineWidth', 2 )
% hold on
% plot(errLoss_s(1:50), '-or', 'LineWidth', 2 )




























































