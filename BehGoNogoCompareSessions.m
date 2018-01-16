clc;
clear all;

cdMatlab;
cd('..\Research\Behavior\Data\RandIntGoNogoSwitch');


% Select Files
% % temp_date = '20140616';
% % temp_date = datestr(now, 'yyyymmdd');
% temp_date = '*';
% temp_anim = 'kCg';
% 
% file_mask = [temp_anim '-' temp_date '-*.txt'];
% files = dir(file_mask);
% filenames = {files.name};

% file_masks = {'kBd-20140625', 'kBd-20140722'};
% file_masks = {'kBd-20140625', 'kBd-20140708'};
% file_masks = {'kCg-20140710', 'kCg-20140722'};
% file_masks = {'kCh-20140710', 'kCh-20140722'};
file_masks = {'kCd-20140716', 'kCd-20140701'};

filenames = cell(size(file_masks));
for i_file = 1:length(file_masks)
    temp_file = dir([file_masks{i_file} '*.txt']);
    filenames{i_file} = temp_file(1).name;    
end

% filenames = {'kCb-20140721-125705.txt'; 'kCb-20140722-140745.txt'};

num_files = length(filenames);
fprintf('%d files found\n', num_files);


%% Get Data from Files
for i_file = 1:num_files
    filename = filenames{i_file};
    name_dates{i_file} = filename(9:12);
    
    data{i_file} = BehGoNogoSessionSummary(filename);
end

% RandIntGoNogo: <90min: >=85% over 100 trials, >80 reward

%% Plot relevant data from sessions
clf;
hold on;
colors = [ColorPicker('blue'); ColorPicker('red')];

for i_file = 1:num_files
%     ts = data{i_file}.ts_np_in;
    ts = data{i_file}.ts_stim_on;
    ts = double(ts);
    ts = ts/1e3/60;
%     h = plot(ts, 1:length(ts), '.');

%     per = data{i_file}.hit_attempts;
    per = data{i_file}.acc_by_trials;
    per = double(per);
%     h = plot(1:length(per), per, '.');
    
    win_smooth = 50;
    smooth_per = RunningAverage(per, win_smooth);
    h = plot(ts(1:length(smooth_per)), smooth_per, '.-');
        
%     set(h, 'Marker', 'o');
    set(h, 'Marker', '.');
    set(h, 'MarkerSize', 10);
    set(h, 'LineWidth', 0.1);
    set(h, 'Color', colors(i_file, :));
    axis([0 Inf, 0 1]);
    h = legend(filenames);
    set(h, 'Box', 'off');
    set(h, 'Location', 'SouthEast');
end
