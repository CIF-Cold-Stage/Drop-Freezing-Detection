function [drop] = parse_drops(drop, sensitivityAdjust)

% These two structure elements are used during image processing
se3 = strel('disk',3, 0);
se5 = strel('disk',5, 0);

%% First pass to find freeze events
% For each drop, do image substraction and filtering to find possible
% freeze events.
fprintf('Parsing %d drops...\n',length(drop));tic;
for i = 1:length(drop)
    for j = 1:length(drop(i).T)-1
        % Retrieve two sequential tiles 
        im1 = drop(i).tile{j};
        im2 = drop(i).tile{j+1};
        
        % Convert tiles to black and white
        im1 = rgb2gray(im1);
        im2 = rgb2gray(im2);

        % Subtract and convert to binary image. Increasing
        % sensitivityAdjust will increase detection and include additional
        % noise for manual filter. Keep value between .1 and .01 (or .9 and
        % .99 as input arguments).
        diff = imsubtract(im1,im2);
        
        im2bwThresh = graythresh(diff)+sensitivityAdjust;

        if im2bwThresh > 1
            im2bwThresh = 1;
        elseif im2bwThresh < 0
            im2bwThresh = 0;
        end
        final_image = im2bw(diff,im2bwThresh);
        
        % Growing and then shrinking the binary image 'blob' will smooth
        % out the edges
        final_image = imerode(final_image,se3);
        final_image = imdilate(final_image,se5);
        
        areas = regionprops(final_image,'area');
        areas = [areas.Area];
        
        % Store any possible freeze events for manual culling
        if ~isempty(areas)
            drop(i).keep{end+1} = [im1,im2;diff,final_image.*255];
            drop(i).status(j) = 1;
        else
            drop(i).status(j) = 0;
            drop(i).toss_ind(end+1) = j;
        end
    end
    
    % Clean up stored data
    drop(i).toss_ind(end+1) = length(drop(i).T);
    drop(i).tile(drop(i).toss_ind) = []; 
    drop(i).T(drop(i).toss_ind) = [];
    drop(i).fileName(drop(i).toss_ind) = [];
    drop(i).status(drop(i).toss_ind) = [];
end
fprintf('Finished parsing: %0.1f\n',toc);
close all;
