bp = 'level 1/Rain/J3A_1/';

%% Read and parse log
% Read text log, discard first 6 lines
fid = fopen([bp,'log.txt']);
for i = 1:6
    x = fgetl(fid);
end

image_files = [];
TLog = [];
while true
    x = fgetl(fid);
    if x == -1; break; end;
    a = strsplit(x, 'pic');
    if length(a) > 1
        image_files{end+1}= ['pic' a{2}];
        a = strsplit(x)
        TLog(end+1) = (str2double(a{6}) + str2double(a{7}))/2
    end
end
fclose(fid)
