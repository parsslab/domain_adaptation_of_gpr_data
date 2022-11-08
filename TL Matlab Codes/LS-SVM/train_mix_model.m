
function train_mix_model

% srcDesc : 260xn matrix that must be transposed
% negDesc : 260xn matrix that must be transposed
% clc, clear , close all

classes = {'Mix0'  % 1
           'Mix1'  % 2
           'Mix2'  % 3
           'Mix3'  % 4
           'Mix4'  % 5
           'Mix5'  % 6
           'Mix6'  % 7
           };


for idx = 1:7

noiseDir = {'Noise_13'};
%noiseDir = {'Noise_00', 'Noise_05', 'Noise_09', 'Noise_13'};

saveFile = 1;

testSize_p = 100;
testSize_n = 100;
rptCount = 1;
trCount = 6;

% ========================================================================

for rpt = 1:rptCount
    
fprintf('\nIteration number:%d.\n',rpt)

for nD = 1:length(noiseDir)

    subFolder = noiseDir{nD}; 

    file=['Descriptors/',subFolder, '/',classes{idx},'_d.mat'];
    load(sprintf('%s',file));
    desc_p = desc;
    clear desc
    [featSize_p, dataCount_p] = size(desc_p);

    file=['Descriptors/',subFolder, '/','Clutter','_d.mat'];
    load(sprintf('%s',file));
    desc_n = desc;
    clear desc
    [featSize_n, dataCount_n] = size(desc_n);

    %fprintf('Class{%d} descriptor size: %d x %d\n',idx, featSize_p ,dataCount_p)
    %fprintf('Clutter descriptor size: %d x %d\n', featSize_n ,dataCount_n)

    
    trDataCount = dataCount_p-testSize_p;
    
    
    trStep = fix(trDataCount/trCount);
    dotCnt = 0;

    %if rpt == 1 % *** only generate for new rpt ***
        randInd_p = randperm(dataCount_p);
        randInd_n = randperm(dataCount_n);
    %end
    
    for trCnt = 1:trCount

        
        trSize_p = trStep * trCnt;
        trRange_p = 1:trSize_p;
        %testRange_p = (trSize_p+1):(trSize_p+1+testSize_p);
        testRange_p = dataCount_p-testSize_p+1:dataCount_p;

        trSize_n = trSize_p;
        trRange_n = 1:trSize_n;
        %testRange_n = (trSize_n+1):(trSize_n+1+testSize_p);
        testRange_n = dataCount_n-testSize_n+1:dataCount_n;

        train.X = [desc_p(:,randInd_p(trRange_p)), ...
                   desc_n(:,randInd_n(trRange_n))];

        train.Y = [ones(1,trSize_p), ...
                  -ones(1,trSize_n)];

        test_X = [desc_p(:,randInd_p(testRange_p)), ...
                  desc_n(:,randInd_n(testRange_n))];

 
        g_array=[2e-3];
        c_array=[10];
        
        %g_array=[1e-5 1e-3 2e-3 0.01 0.1 0.5 5 10 20 ];
        %c_array=[1e-5 1e-3 2e-3 0.01 0.1 0.5 5 10 20 ];

        err = zeros(numel(g_array),numel(c_array));


        model.X = train.X;
        
        for j=1:numel(g_array)
            for i=1:numel(c_array)

                C = c_array(i);
                krnPram.gamma=g_array(j);
                krnPram.type = 'rbf';

                Ktr = compute_kernel(train.X,train.X,krnPram);

                model.C = C;
                model.K = Ktr;
                model.Y = train.Y;

                %fprintf('gamma = %.2d,  C = %.2d\n',g_array(j),c_array(i));
                fprintf('.')
                dotCnt = dotCnt + 1;
                if (mod(dotCnt,50)) == 0
                    fprintf('\n')
                end
                
                [model, looErr, looPred] = LS_SVM(model);
                err(j,i) = looErr(2);
            end
        end

        [val rows] = min(err);
        [minval,cols]=min(val);

        g_j = rows(cols);
        c_i = cols;

%         fprintf('\nThe best parameters are: gamma = %.2d and C = %.2d\n', g_array(g_j),c_array(c_i));

        krnPram.gamma=g_array(g_j);
        Ktr = compute_kernel(train.X,train.X,krnPram);

        model.C = c_array(c_i);
        model.K = Ktr;
        model.Y = train.Y;
        model.kp = krnPram;

        [model, loo_err, loo_pred] = LS_SVM(model);

        Ktest = compute_kernel(train.X,test_X,krnPram);

        [pred, margins] = predict_LS_SVM(Ktest', model);

        TruePos = sum((pred(1:testSize_p) + 1 )/2);
        FalseNeg = sum((pred(1:testSize_p) - 1 )/-2);

        TrueNeg = sum((pred(testSize_p+1:end) - 1 )/-2);
        FalsePos = sum((pred(testSize_p+1:end) + 1 )/2);

        Succes_p = TruePos / (TruePos+FalseNeg);
        Succes_n = TrueNeg / (TrueNeg+FalsePos);

        Succes = (Succes_p+Succes_n)/2;

        predMat{nD}(trCnt, rpt) = Succes;
    end
end
end


for nD = 1:length(noiseDir)
    predArr{nD} = mean(predMat{nD}, 2);
end

% xTick = (1:1:trCnt)*trStep;
% 
% font = {'-or','-sg','-*m', '-oc','-+b', };
% figure(1)
% for nD = 1:length(noiseDir)
%     plot(xTick, predArr{nD}, font{nD}, 'LineWidth', 2 )
%     hold on
% end
% 
% set(gca,'YGrid','on');
% set(gca,'XGrid','on');
% 
% set(gca,'XTick',xTick, 'FontSize', 16, 'fontweight','b')
% ylim([0.7 1])
% set(gca,'YTick',0.70:0.05:1, 'FontSize', 16, 'fontweight','b')
% xlabel('Training Sample', 'FontSize', 16, 'fontweight','b')
% ylabel('Prediction Rate', 'FontSize', 16, 'fontweight','b')
% % 
% drawnow
% 
%     %h = legend(noiseDir,1);
% %h = legend('Gürültü_00');
%     %set(h,'Interpreter','none', 'Location','best')
% fprintf('\nSuccess:\n');
% disp(predArr);

if saveFile == 1
    file=['Models/',subFolder, '/',classes{idx},'_m.mat'];
    save(file,'model')
end
end

end

