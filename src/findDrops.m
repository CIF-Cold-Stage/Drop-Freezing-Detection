function [locations,drop] = findDrops(hUnfrozenIm,hFrozenIm,TLog)
% Takes two images (unfrozen and frozen) and performs a Hough transform for
% circle analysis on the images to find the locations and radius of drops.
%
% Inputs:
%     hUnfrozenIm,hFrozenIm - File names (include paths to file if not in 
%                             current folder) for the unfrozen and frozen
%                             images.
% Returs:
%     locations - Structure with the following memembers
%           x,y - x,y pixel coordinates of the center of the drop
%             r - estimated pixel radius for the drop
% 
%
% This function uses the below algorithm to find the circles, include
% citation in any research publication
%  Young, David (2016). Hough transform for circles v1.2 
%      (http://www.mathworks.com/matlabcentral/fileexchange/26978), 
%      MATLAB Central File Exchange. Retrieved Nov 24, 2017.
% 
%%
warning('off','images:imshow:magnificationMustBeFitForDockedFigure');

% Check for file dependency
neededFiles = {'get_tile',...
    'circle_hough',...
    'circle_houghpeaks',...
    'circlepoints'};
for i = 1:length(neededFiles)
    if ~exist(neededFiles{i},'file')
        error('Missing needed file: %s.m\n',neededFiles{i});
    end
end

% Get unfrozen image and crop image for faster search
fprintf('Create image crop boundaries, by clicking in the upper left and\n');
fprintf('   lower right of the image.\n\n');
im1 = imread(hUnfrozenIm);
f1 = figure;
imshow(im1);
clicks = ginput(2);
close(f1);
clicks = round(clicks);

% Get frozen image
im2 = imread(hFrozenIm);

% Crop images
im1 = im1(clicks(1,2):clicks(2,2),clicks(1,1):clicks(2,1),:);
im2 = im2(clicks(1,2):clicks(2,2),clicks(1,1):clicks(2,1),:);

% Blur images with gaussian filter and convert to gray scale. Blurring the
% image helps the search routine
im1 = rgb2gray(imgaussfilt(im1));
im2 = rgb2gray(imgaussfilt(im2));

% Subtract the unfrozen and frozen image and convert to binary image
im = imbinarize(im1-im2);

%% Begin auto detection
tic

% Find edges of binary image, perform a Hough transform with predicted
% circle sizes (in pixels). The larger the search radii, the longer the
% analysis. Pull the found circle list and store. The 'nhoodxy' and
% 'nhoodr' are exclusion regions to reduce overlapping found circles. See
% sub function for further details
fprintf('Performing first pass Hough transform circle search\n');
e = edge(im, 'canny');
radii = 25:1:38;
h = circle_hough(e, radii, 'same', 'normalise');
peaks = circle_houghpeaks(h, radii, 'nhoodxy', 71, 'nhoodr', 35);

% For each found circle, create a circle, plot it, and store the
% coordinates, radius, and handle to the plotted circle.
f1 = figure;
imshow(im1);hold on;
for i = 1:size(peaks,2)
    [x, y] = circlepoints(peaks(3,i));
    h = plot(x+peaks(1,i), y+peaks(2,i), 'g-','linewidth',1.5);
    locations(i).x = peaks(1,i);
    locations(i).y = peaks(2,i);
    locations(i).r = peaks(3,i);
    locations(i).h = h;
    locations(i).keep = 1;
end

fprintf('Found %d drops in %0.1f s\n\n',length(locations),toc);

%% Add missing drops
% Until the user right clicks, perform the following
fprintf('Add any missing drops by clicking on them.\n');
fprintf('After clicking, a sub-image appears. If the circle is not on\n');
fprintf('the drop, right click to move to next suspected location\n');
fprintf('When drop found, right click to end and move on to adding more\n\n');
while 1
    % Get an approximate drop location
    [xClick,yClick,bClick] = ginput(1);
    
    % If the button was a right click, break out of loop
    if bClick == 3
        break;
    end
    
    % Get a tile centered on where user clicked
    xClick = round(xClick);
    yClick = round(yClick);
    [t1,tileBoundary] = get_tile(im1,xClick,yClick,150,'Center');
    t2 = get_tile(im,xClick,yClick,150,'Center');

    % Perform a Hough circle transform on the tile 
    e = edge(t2, 'canny');
    radii = 25:1:38;
    h = circle_hough(e, radii, 'same', 'normalise');
    peaks = circle_houghpeaks(h, radii, 'nhoodxy', 71, 'nhoodr', 35);
    
    % Display tile, for each possible detected circle, display the circle
    % and let the user decide if it matches the drop. Left click confirms
    % the circle is correct and right click rejects the circle and draws
    % the next one in sequence.
    f2 = figure;
    imshow(t1);
    hold on;
    for i = 1:size(peaks,2)
        [x, y] = circlepoints(peaks(3,i));
        p1 = plot(x+peaks(1,i), y+peaks(2,i), 'g-','linewidth',1.5);
        [~,~,whichButton] = ginput(1);
        if whichButton == 1
            break;
        end
        delete(p1);
    end
    close(f2);
    
    % On original figure, plot the added drops and update the locations
    % strucutre with new drops
    figure(f1);
    if isempty(peaks(1,i))
        warning('Hough transform found no drops in that tile');
        continue;
    end
    h = plot(x+peaks(1,i)+tileBoundary(3), y+peaks(2,i)+tileBoundary(1), 'g-','linewidth',1.5);
    locations(end+1).x = peaks(1,i)+tileBoundary(3);
    locations(end).y = peaks(2,i)+tileBoundary(1);
    locations(end).r = peaks(3,i);
    locations(end).h = h;
    locations(i).keep = 1;
end

%% Remove false positives
% Toggle possible drops from green (keep) to red (discard) to remove false
% positives

fprintf('To remove false positive, left click on a circle and turn it red\n');
fprintf('Toggle between green and red to keep or discard possible drops\n');
fprintf('When complete, right click to end\n\n');
while 1
    % User left clicks circle to toggle it, right clicking ends the loops
    [xClick,yClick,bClick] = ginput(1);
    if bClick == 3
        break;
    end
    xClick = round(xClick);
    yClick = round(yClick);

    % Search for the nearest found circle to where user clicks
    dist = sqrt((xClick-[locations.x]).^2+(yClick-[locations.y]).^2);
    [~,ind] = min(dist);
    
    % If circle is green (keep) toggle it to red (discard) and vice versa
    % if circle is red
    if locations(ind).keep == 1
        set(locations(ind).h,'Color','r');
        locations(ind).keep = 0;
    else
        set(locations(ind).h,'Color','g');
        locations(ind).keep = 1;
    end        
end

% Find all drops that had their keep flag set to discard and remove them
% from the structure
ind = find([locations.keep] == 0);
locations(ind) = [];
fprintf('Found %d drops in %0.1f s\n',length(locations),toc);

%% Correct to main image coordinates and remove unnessary struct members
for i = 1:length(locations)
    locations(i).x = locations(i).x+clicks(1,1);
    locations(i).y = locations(i).y+clicks(1,2);
end
locations = rmfield(locations,'keep');
locations = rmfield(locations,'h');
%% Check
% Display results
close(f1);
figure;imshow(imread(hUnfrozenIm));hold on;
for i = 1:length(locations)
    [x, y] = circlepoints(locations(i).r);
    p1 = plot(x+locations(i).x, y+locations(i).y, 'g-','linewidth',1.5);
end

 for i = 1:length(locations)
    drop(i).x = locations(i).x;
    drop(i).y = locations(i).y;
    drop(i).tile = {};
    drop(i).T = [];
    drop(i).fileName = {};
    drop(i).keep = {};
    drop(i).status = zeros(length(TLog),1);
    drop(i).toss_ind = [];
end