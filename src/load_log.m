function [image_files TLog] = load_log(bp)
% This function generates a list of image files 
% and temperatures corresponding to freezing
% This version parses the image names in the directory
% and uses the temperature from the image string

image_files = []; TLog = [];
listing = dir(bp);
for i = 1:numel(listing)
    a = strsplit(listing(i).name, '.jpg');
    if length(a) > 1
        image_files{end+1}= listing(i).name;
        b = strsplit(a{1}, '_');
        TLog(end+1) = str2double(b{end});
    end
end
