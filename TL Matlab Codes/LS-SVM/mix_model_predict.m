


for rpt_mix = 1:20
    
    
    mix_desc_create
    
    train_mix_model
    
    Success_mix_rpt10(rpt_mix,:) = cross_validate_mix
    
end

close all;

mean_mix = mean(Success_mix_rpt10)

std(Success_mix_rpt10)

step_mix = [0 5 10 50 100 200 300];

plot(step_mix, mean_mix, '-+k', 'LineWidth', 2 )
hold on
set(gca,'YGrid','on');
set(gca,'XGrid','on');
set(gca,'FontSize', 16, 'fontweight','b')
% set(gca,'XTick',1:1:trCnt, 'FontSize', 16, 'fontweight','b')
set(gca,'FontSize', 16, 'fontweight','b')
% xlabel('Number of Samples', 'FontSize', 16, 'fontweight','b')
% ylabel('Recognition Rate', 'FontSize', 16, 'fontweight','b')
xlabel('Eðitim Veri Sayýsý', 'FontSize', 16, 'fontweight','b')
ylabel('Sezim Oraný', 'FontSize', 16, 'fontweight','b')

drawnow