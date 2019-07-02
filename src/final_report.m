function [] = final_report(bp, out, image_files)
% This function provides a final report for freezing validation.
    
load([out, 'verifiedDrops.mat'])

close all;
figure(1);
imUnfrozen = imread([bp, image_files{1}]);
imshow(imUnfrozen);hold on;
plot([verifiedDrops.x],[verifiedDrops.y], ...
    'ro','markersize',18,'LineWidth',2);

figure(2);
T = [verifiedDrops.T];
plot(sort(T,'descend'),(1:length(T))./length(T));
xlabel('Tfreeze (deg C)');ylabel('Fraction frozen');

axis([-35 0 ylim]);
set(gcf, 'PaperUnits', 'inches','PaperSize',[8 6], ...
    'paperposition',[0 0 8 6],  'Color', 'w')
set(gca, 'FontSize',10, 'TickLength',[0.02 0], 'Box', 'off', ...
    'XMinorTick','on','YMinorTick','on', 'XColor','k','Ycolor','k');
