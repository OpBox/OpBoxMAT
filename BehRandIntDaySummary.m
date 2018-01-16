clc;

clear;
cdMatlab;
% cd('..\PostDocResearch\Behavior\Data\RandIntGoNogo');
% cd('..\PostDocResearch\Behavior\Data\RandIntGoNogoSwitch');
% cd('..\PostDocResearch\Behavior\Data\GoNogoTrack');
cd('..\PostDocResearch\Behavior\Data\RandIntGoNogoOnArduino');

% kBc-20131216-153732.txt

% file_mask = 'k*-*-*.txt';
% temp_date = '20140507';
temp_date = datestr(now, 'yyyymmdd');
file_mask = ['k*-' temp_date '-*.txt'];
files = dir(file_mask);
num_files = length(files);

ts_np_in = {};

for i_file = 1:num_files
    filename = files(i_file).name;
    [per_gostim_lick, per_nostim_lick, per_nogostim_lick, acc, rate_np, ts_np_in{i_file}] = BehRandIntSessionSummary(filename);
    pause;
%     BehRandInt_DebounceAnalysis(filename);
end

%% Graph ts_np_in times by absolute and relative scales
clf;
% grid = SubPlotGrid(1,2, [0 1], [0 1]);
grid = SubPlotGrid(1,2);
axes(grid(1));
hold on;
axes(grid(2));
hold on;

colors = [
    ColorPicker('brown');
    ColorPicker('red');
    ColorPicker('burntorange');
    ColorPicker('orange');
    ColorPicker('blue');
    ColorPicker('turquoise');
    ColorPicker('skyblue');
    ColorPicker('green');
];

for i_file = 1:num_files
    data = ts_np_in{i_file};
    data = double(data); % convert from int to double
    data = data/1e3/60; % convert from ms to min
    num = length(data);
    
    axes(grid(1));
    h = plot(data, 1:num, '.-');
    set(h, 'Color', colors(i_file, :));
    
    axes(grid(2));
    h = plot(data/max(data), (1:num)/num, '.-');
    set(h, 'Color', colors(i_file, :));
    
end

axes(grid(1));
axis tight
ylabel('NPs (#)');
xlabel('Time (min)');
legend(files.name, 'Location', 'NorthWest');
legend('boxoff');

axes(grid(2));
ylabel('NPs (fraction)');
xlabel('Time (fraction)');
axis tight square
legend(files.name, 'Location', 'SouthOutside');
legend('boxoff');

%% Look at "instantaneous" NP Rate
