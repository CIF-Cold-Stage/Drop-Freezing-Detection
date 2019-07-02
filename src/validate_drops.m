function [] = validate_drops(out, drop, varargin)
    
%% This routine validates the drops 

for i = 1:length(varargin)
    switch(varargin{i})
        case 'enableSingleDropSkip'
            enableSingleDropSkip = 1;
        case 'tileSize'
            tileSize = varargin{i+1};
            i = i+1;
    end
end

if ~exist('enableSingleDropSkip','var')
    enableSingleDropSkip = 0;
end

if ~exist('tileSize','var')
    tileSize = 100; %% Read and parse log
end

tossDrop = [];

for i = 1:length(drop)
    fprintf('Progress: %d%%\n',round((i-1)/length(drop)*100));

    % If the number of drops is greater than 1 (and quick parsing is
    % disabled), display all the options in one image and allow user to
    % select correct freeze event.
    if length(drop(i).keep) > 1 || enableSingleDropSkip == 0
        im = [];
        f2 = figure(1);
        for j = 1:length(drop(i).keep)
            im = [im;drop(i).keep{j}];
        end 
        [a,b] = size(im);
        if a == 0 || b == 0
             tossDrop(end+1) = i;
             continue;
        end

        imshow(im);
        text(0, 10, sprintf('\nT = %5.2f', drop(i).T));
        [~,ysub,b] = ginput(1);
        keepSubInd = ceil(ysub/(tileSize*2));
        if b == 3
            tossDrop(end+1) = i;
        end
    else
        keepSubInd = 1;
    end
    fprintf('Selected image %d\n',keepSubInd);
    
    % Finish cleaning out false data
    tossSubInd = 1:length(drop(i).keep);
    tossSubInd(tossSubInd == keepSubInd) = [];
    drop(i).tile(tossSubInd) = []; 
    drop(i).T(tossSubInd) = [];
    drop(i).fileName(tossSubInd) = [];
    drop(i).status(tossSubInd) = [];
    drop(i).keep(tossSubInd) = [];  
end
drop(tossDrop) = [];
    
%% Clean up and store data
% Copy data into final structure
for i = 1:length(drop)
    verifiedDrops(i).x = drop(i).x;
    verifiedDrops(i).y = drop(i).y;
    verifiedDrops(i).T = drop(i).T;
    if ~isempty(drop(i).keep)
        verifiedDrops(i).tile = drop(i).keep{1};
        verifiedDrops(i).fileName = drop(i).fileName{1};
    else
        warning('tile is empty');
    end
end

save([out,'verifiedDrops.mat'], ...
    'drop','verifiedDrops');

close all;
