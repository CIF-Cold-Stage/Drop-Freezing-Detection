%% Instructions
%
% (1) Generate a meta(i) input for each sample. These contain
%     the relevant meta data for each sample. 
%
% (2) process the individual samples using process_level1
%     process_level1 will generate the verifiedDrops.mat files
%     and store them in the appropriate level 2/... directories
%
% (3) run process_level2. This will take a number of .mat files
%     that have the same source and overlay them. It will also
%     bin the data in 1K intervals and compute the standard deviation
%     process_level2 produces a .png file and .txt file with the binned 
%     data in the appropriate level 3/... directory
%-

% Check to see if the cicle_hough functions are in the current work path
pathCell = regexp(path, pathsep, 'split');
circle_hough_path = 'circle_hough';
if ispc  % Windows is not case-sensitive
  onPath = any(strcmpi([pwd,filesep,circle_hough_path], pathCell));
else
  onPath = any(strcmp([pwd,filesep,circle_hough_path], pathCell));
end

% Add path if not already there
if ~onPath
    addpath(circle_hough_path);
end

% First example block for meta data. Fill in as known
meta(1).pre = 'Experiment 1';                         % Sample prefix
meta(1).files = {'Experiment 1a'; 'Experiment 1b'};   % Experiment repeats
meta(1).repeats = 2;                                  % Number of repeats
meta(1).sampleType = 'Dust suspension';               % Type of sample
meta(1).dateCollected = 'mm-dd-yyyy (hh:mm - hh:mm)'; % Dates sample collected
meta(1).analyzed = {'mm-dd-yyyy';'mm-dd-yyyy'};       % Date each sample was analyzed
meta(1).validated = {'mm-dd-yyyy';'mm-dd-yyyy'};      % Date data were validated
meta(1).Vdrop = 1e-6;                                 % Drop volume (L)
meta(1).coolingRate = 2;                              % Cooling rate (K min-1)
meta(1).originator = 'Shweta Yadav';                  % Person who analzed the data
meta(1).out = 'level 3/';                             % Output of processed data


%% Level 1 processing
% The following two lines will run the level 1 processing. This needs to be 
% done only once and can also be done from the command line. They are 
% commented out once the processing is done. Note that the second variable 
% sets the processing for the selected repeat
% 'identifyDropsManually', true => uses automatic detection of drops
% 'identifyDropsManually', false => use manually identifies drops
% 'sensitivityAdjust', xx => value to set the contrast for freeze detection

% GUI controls for automatic are given via text prompts. Use left mouse 
% button to select, right mouse button to dismiss. For manual selection use
% left mouse button to place circle, right mouse button to indicate
% completion of the task. For validation, use left mouse 
% button to "approve" correct image, right mouse button to "skip".

m = meta(1); file = m.files{1};
process_level1(['level 1/' file '/'], ['level 2/' file '/'], ...
    'identifyDropsManually', false, 'sensitivityAdjust', 0.9);

%% Level 2 processing
%  Level 2 collates the data from the repeats and bins the data. 
%  This could be setup as a loop. It will be useful to do it in a loop 
%  when somthing is changed in the binning. It will be retroactively 
%  applied to all experiments. For standard analysis you can simply change 
%  the index to select the appropriate meta block. The result will produce
%  two files, a text file containing the resulting IN spectra and a png
%  plot of the result in fraction frozen and IN concentration per picoliter
%  of sample water space. If the experiment contains repeats, the results
%  will be combined together to produce a single data set for reporting.

% Uncomment these lines for level 2 processing. Comment out the
% process_level 1 line above.

% bp = 'level 2/';                       % Path to validated level 1 data
% m = meta(1);                           % Selected Experiment meta block
% process_level2(bp, m)                  % Collate the data




