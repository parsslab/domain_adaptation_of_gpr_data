


TP = (pred(1:testSize_p)+1)/2
%TP2 = TP - (1:1:length(TP));
TN = find(pred(testSize_p+1:testSize_p+testSize_n)+1)


% TN2 = TN-(1:1:length(TN));
% TT = [TP TN];
% TT2 = sort(TT);

ROC = [];
TrueUntil = [];

for i = 1:length(TN)
    
    TrueUntil = [TrueUntil sum(TP(1:TN(i)))];
    ROC = [ROC TrueUntil(i)/TN(i)];
       
end

TrueUntil = TrueUntil
ROC = ROC

figure
plot(TrueUntil)
% figure
% plot(ROC)
hold on
scatter(1:length(TN),TrueUntil)