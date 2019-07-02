function [drop, x_store, y_store] = ...
        generate_drops(bp, image_files, TLog)
% This function generates an array of drops based on user input

% Generate initial image for picking drops out
f1 = figure(1);
set(gcf, 'Position', get(0, 'Screensize'));

imUnfrozen = imread([bp,image_files{1}]);
imshow(imUnfrozen);hold on;

x = 1; b = 1;
x_store = []; y_store = [];
while b == 1;
    [x,y,b] = ginput(1);
    
    if ~isempty(x)
        x_store(end+1) = x;
        y_store(end+1) = y;
        plot(x_store(end),y_store(end),'ro','markersize',18,'LineWidth',2);
    end
end
close(f1);

% Create empty (mostly) data structure
for i = 1:length(x_store)
    drop(i).x = x_store(i);
    drop(i).y = y_store(i);
    drop(i).tile = {};
    drop(i).T = [];
    drop(i).fileName = {};
    drop(i).keep = {};
    drop(i).status = zeros(length(TLog),1);
    drop(i).toss_ind = [];
end
close all;
