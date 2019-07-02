function [drop] = load_and_tile_images(bp,image_files,TLog,drop,tileSize)
% This function loads all image files in the list
% It also tiles the image based on identified droplet location
% The image tiles are stored in the drop structure

fprintf('Loading images...\n');tic;

x_store = [drop.x];
y_store = [drop.y];

for i = 1:length(image_files)
    imgName = image_files{i};
    im = imread([bp,imgName]);
    for j = 1:length(x_store)
        drop(j).tile{end+1} = ...
            get_tile(im,x_store(j),y_store(j),tileSize,'Center');
        drop(j).T(end+1) = TLog(i);
        drop(j).fileName{end+1} = imgName;
    end
end

fprintf('Images loaded: %0.1f s\n',toc);
