function [] = process_level2(bp, meta)
% Convert the processed data into a report and figure for analysis

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
   graphics_toolkit('gnuplot')
   warning('off')
end

for i = 1:numel(meta.files)
    load([bp meta.files{i} '/verifiedDrops.mat']);

    T = [verifiedDrops.T];        % T array from validation
    f = (1:numel(T))./numel(T);   % fraction frozen
    I = (-(log(1-f)))./(meta.Vdrop); % IN concentration per Liter H2O
   Cin = I/1;
    % store results in structure
    experiment(i).T = sort(T, 'descend');  
    experiment(i).f = f;
    experiment(i).Cin = Cin;    
end
 
cols = {[0 0 0], [0.8 0.0 0.0], [0 0 0.8], [0.8 0 0.8], [0.5 0.5 0.5]};
bounds = -40.5:1:-0.5;     % temperature bin bounds
mid = -40:1:-1;            % temperature mid points
n = zeros(1,40);           % number of counts per bin
conc = zeros(1,40);        % average concentration per bin
sdev = zeros(1,40);        % standard deviation per bin 
conc_list = cell(1, 40);
for i = 1:numel(bounds)-1
    conc_list{i}.Cin = [];  
end

for k = 1:numel(experiment)    % collate all experiments
    Tx = experiment(k).T;      % get temperature
    Cin = experiment(k).Cin;   % get concentration
    
    % bin the data
    for i = 1:numel(bounds)-1
        for j = 1:numel(Tx)
            if Tx(j) > bounds(i) && Tx(j) < bounds(i+1) && isfinite(Cin(j))
                n(i) = n(i) + 1;
                conc_list{i}.Cin(end+1) = Cin(j);
                
            end
        end
     end
end

% compute mean and standard dev in each bin
for i = 1:numel(conc_list)
    if n(i) >= 3  % ignore bins with fewer than 3 freeze events
        conc(i) = mean(conc_list{i}.Cin);
        sdev(i) = std(conc_list{i}.Cin);
    else 
        conc(i) = NaN;
        sdev(i) = NaN;
        n(i) = NaN;
    end
end

% get a figure
fig = figurehandle(6.5, 3.25, 1);

% plot fraction frozen experiments
for i = 1:numel(experiment)
    plot(experiment(i).T,experiment(i).f, 'o-', ...
        'Color', cols{i}, 'MarkerSize', 3);
    hold on
    xlabel('Temperature (^oC)');
    ylabel('Fraction frozen');
    set(gca, 'YLim', [0 1], 'XLim', [-35 0], 'Box', 'on', ...
        'Position', [0.1 0.15 0.38 0.8], 'TickLength', [0.01, 0.01], ...
        'XMinorTick', 'on', 'YMinorTick', 'on')
end 

% second panel with IN concentration
axis2 = axes(); hold on
for i = 1:numel(experiment)
    semilogy(experiment(i).T, experiment(i).Cin, 'o', ...
            'Color', cols{i}, 'MarkerSize', 3);
    hold on;
    xlabel('Temperature (^oC)');
     ylabel('IN conc (# L^{-1} water)')
end

% add binned data mean
plot(mid, conc, '-sk', 'MarkerFaceColor', 'k', 'MarkerSize', 4, ...
    'Linewidth', 2);   

% add error bars for binned data
for i = 1:numel(mid)
    if isfinite(conc(i))
        plot([mid(i) mid(i)], [conc(i)-sdev(i) conc(i)+sdev(i)], ...
            'LineWidth', 1, 'Color', [0 0 0]);
    end
end

% set axis properties
set(gca, 'YLim', [1e3 1e8], 'XLim', [-35 0], 'YScale', 'log', ...
    'Position', [0.6 0.15 0.38 0.8], 'TickLength', [0.01 0.01], ...
	'Box', 'on', 'XMinorTick', 'on', 'YMinorTick', 'on')
%cleanUpPlot

status = mkdir(meta.out);
print([meta.out meta.pre '.png'], '-dpng', '-r300');

write_txt([meta.out meta.pre '.txt'], bounds, mid, conc, sdev, n, meta);
