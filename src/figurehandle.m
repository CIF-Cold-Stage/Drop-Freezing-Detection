function [fig, ax] = figurehandle(width, height, fig)
% Formats figure window for output

fig = figure(fig);
clf();
set(0,'DefaultAxesFontSize', 10)
set (0, 'defaulttextfontsize', 8) 
set(gcf, 'PaperUnits', 'inches', 'Papersize', [width,height]);
set(gcf, 'PaperPosition', [0 0 width height], 'Color', 'w');
hold on
