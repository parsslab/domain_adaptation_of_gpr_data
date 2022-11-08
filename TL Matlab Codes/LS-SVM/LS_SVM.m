function [model, loo_err, y_tilda] = LS_SVM(model)



n = size(model.K,1);

index_p = find(model.Y == 1);
count_p = numel(index_p);

index_n = find(model.Y == -1);
count_n=numel(index_n);

zita=zeros(1,n);
zita(index_p) = n/(2*count_p);
zita(index_n) = n/(2*count_n);


if numel(model.C)==1
    adj = (1/model.C)*(diag(1./zita)); 
else
    adj = diag(1./model.C);
end

M = [model.K+adj, ones(n,1); ...
     ones(1,n),          0];

P = pinv(M);

x = P * [model.Y';0];

model.a = x(1:end-1);
model.b = x(end);

% Training Error Calculation ----------------------------------------------

predTr = model.K * model.a + model.b;

errCla = 1 - numel(find(model.Y' == sign(predTr)))/n;
errMarg = mean((model.Y'-predTr).^2);

% fprintf('Training Set Error Calculation:\n');
% fprintf('MSE = %1.3f,\t',errMarg);
% fprintf('Cla. Rate = %2.2f\n',(1-errCla)*100);


% Leave-One-Out Error Calculation------------------------------------------

Pii = diag(P);
y_tilda = model.Y' - model.a./Pii(1:end-1);

errClaLOO = 1-numel(find(model.Y' == sign(y_tilda)))/n;
errMargLOO = mean((model.Y'-y_tilda).^2);

% fprintf('Leave-One-Out Error Calculation:\n');
% fprintf('LOO MSE = %1.3f,\t',errMargLOO);
% fprintf('LOO Cla. Rate = %2.2f\n\n',(1-errClaLOO)*100);


loo_err(1)=errMargLOO;
loo_err(2)=errClaLOO;

