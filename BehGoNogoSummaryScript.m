clc;
clear all;

cdMatlab;
cd('..\PostDocResearch\Behavior\Data\RandIntGoNogo');
% cd('..\PostDocResearch\Behavior\Data\GoNogoTrack');

file_mask = 'k*-*-*.txt';
files = dir(file_mask);
cell_filenames = {files.name}'; % files should be sorted alphabetically?
filenames = cell2mat(cell_filenames);
series = unique(filenames(:,2));
subjects = unique(filenames(:, 1:3), 'rows');
num_subjects = size(subjects, 1);

% Analysis by subjects for now, later split by series too
max_files_per_subject = 0;
for i_subject = 1:num_subjects
    subj_name = subjects(i_subject, :);
    num_subj_files = sum(strncmp(subj_name, cell_filenames, 3));
    max_files_per_subject = max(max_files_per_subject, num_subj_files);
end

per_stimid_lick = cell(num_subjects, max_files_per_subject);
name_stim_ids = cell(num_subjects, max_files_per_subject);
acc = nan(num_subjects, max_files_per_subject);
dates = nan(num_subjects, max_files_per_subject);
rate_np = nan(num_subjects, max_files_per_subject);
crit_trial = nan(num_subjects, max_files_per_subject);

for i_subject = 1:num_subjects
    subj_name = subjects(i_subject, :);
    idx_subj_filenames = find(strncmp(subj_name, cell_filenames, 3));
    for i_subj_file = 1:length(idx_subj_filenames)
        filename = filenames(idx_subj_filenames(i_subj_file), :);
%         [per_stimid_lick(i_subject, i_subj_file, :), name_stim_ids, acc, rate_np, ts_np_in, med_npdur, med_lick] = BehGoNogoSessionSummary(filename)
        [per_stimid_lick{i_subject, i_subj_file}, name_stim_ids{i_subject, i_subj_file}, acc(i_subject, i_subj_file), rate_np(i_subject, i_subj_file), ts_np_in, med_npdur, med_lick, crit_trial(i_subject, i_subj_file)] = BehGoNogoSessionSummary(filename);
        dates(i_subject, i_subj_file) = str2double(filename(5:12));
    end
end


%% Right align matrices
dates = RightAlignMatrixNaN(dates);
acc = RightAlignMatrixNaN(acc);
per_stimid_lick = RightAlignCellEmpty(per_stimid_lick);
name_stim_ids = RightAlignCellEmpty(name_stim_ids);

%% Plot accuracy
clf;
plot(acc', '.-');
axis([4.5 size(acc,2)+0.5, 0 1]);
legend(subjects, 'Location', 'SouthWest');

%% Plot Crit Trials
clf;
plot(crit_trial', '.-');
axis([4.5 size(acc,2)+0.5, 0 Inf]);
legend(subjects, 'Location', 'SouthWest');




%% Temporary cropping
temp_per_stimid_lick = per_stimid_lick(:, end-2:end);
temp_name_stim_ids = name_stim_ids(:, end-2:end);
temp_dates = dates(:, end-2:end);

clf;
hold on;
data = temp_per_stimid_lick;
for i_row = 1:size(data,1)
    temp_data = vertcat(data{i_row, :});
    h = plot(temp_data, '.-');
    set(h, 'MarkerSize', 15);
end

axis([0.5, size(data,2)+0.5, 0 1]);


%% Plot total data
% Color = stim type
% line = group
% symbol = subject
% .     point
% o     circle
% x     x-mark
% +     plus
% *     star
% s     square
% d     diamond
% v     triangle (down)
% ^     triangle (up)
% <     triangle (left)
% >     triangle (right)
% p     pentagram
% h     hexagram
symbols = 'ox+*sdv^<>ph.';
                               
                               
clf;
hold on;
set(gca, 'Color', ColorPicker('lightgray'))
idx_young = subjects(:,2) == 'B';
idx_aged = subjects(:,2) == 'C';

h = plot(per_nostim_lick', '.-');
set(h, 'Color', ColorPicker('yellow'));
set(h(idx_young), 'LineStyle', ':');
set(h(idx_aged), 'LineStyle', '-');
for i = 1:length(h)
    set(h(i), 'Marker', symbols(i));
    set(h(idx_aged), 'MarkerSize', 10);
end

h = plot(per_gostim_lick', '.-');
set(h, 'Color', ColorPicker('turquoise'));
set(h(idx_young), 'LineStyle', ':');
set(h(idx_aged), 'LineStyle', '-');
for i = 1:length(h)
    set(h(i), 'Marker', symbols(i));
    set(h(idx_aged), 'MarkerSize', 10);
end

h = plot(per_nogostim_lick', '.-');
set(h, 'Color', ColorPicker('red'));
set(h(idx_young), 'LineStyle', ':');
set(h(idx_aged), 'LineStyle', '-');
for i = 1:length(h)
    set(h(i), 'Marker', symbols(i));
    set(h(idx_aged), 'MarkerSize', 10);
end

axis([0.5 size(per_gostim_lick,2)+0.5 0 1]);
set(gca, 'XTick', 1:size(per_gostim_lick,2));
xlabel('Sessions');
set(gca, 'YTick', 0:0.2:1);
ylabel('Fraction of Responses to each Stim');
h = line([0.5 size(per_gostim_lick,2)+0.5], [0.5 0.5]);
set(h, 'LineWidth', 0.1, 'LineStyle', ':', 'Color', ColorPicker('darkgray'));
h = legend(subjects);
set(h, 'Box', 'off');

% %% Scatter Go vs. Nogo resps
% clf;
% plot(per_gostim_lick', per_nogostim_lick', '.-');
% xlabel('Go stim');
% ylabel('Nogo stim');
% axis equal
% axis([0 1 0 1]);

%% Only use sessions with Nogo Stimuli
mask = ~isnan(per_nogostim_lick);
% crop_data = per_nogostim_lick(crop);
num_sessions = sum(mask, 2);
crop_data = nan(num_subjects, max(num_sessions), 3);

for i_subject = 1:num_subjects
    crop_data(i_subject, 1:num_sessions(i_subject), 1) = per_gostim_lick(i_subject, mask(i_subject, :));
    crop_data(i_subject, 1:num_sessions(i_subject), 2) = per_nogostim_lick(i_subject, mask(i_subject, :));
    crop_data(i_subject, 1:num_sessions(i_subject), 3) = per_nostim_lick(i_subject, mask(i_subject, :));
end


% %% Plot total data
% Color = stim type
% line = group
% symbol = subject
% .     point
% o     circle
% x     x-mark
% +     plus
% *     star
% s     square
% d     diamond
% v     triangle (down)
% ^     triangle (up)
% <     triangle (left)
% >     triangle (right)
% p     pentagram
% h     hexagram
symbols = 'ox+*sdv^<>ph.';
                               
                               
clf;
hold on;
% set(gca, 'Color', ColorPicker('lightgray'))
idx_young = subjects(:,2) == 'B';
idx_aged = subjects(:,2) == 'C';

colors = [
    ColorPicker('turquoise');
    ColorPicker('red');
    ColorPicker('lightgray');
    ];

for i_stim = 1:2
    h = plot(squeeze(crop_data(:,:,i_stim))', '.-');
    set(h, 'Color', colors(i_stim, :));
    set(h(idx_young), 'LineStyle', ':');
    set(h(idx_aged), 'LineStyle', '-');
    for i = 1:length(h)
        set(h(i), 'Marker', symbols(i));
        set(h(idx_aged), 'MarkerSize', 10);
    end
end

axis([0.5 size(crop_data,2)+0.5 0 1]);
set(gca, 'XTick', 1:size(per_gostim_lick,2));
xlabel('Sessions');
set(gca, 'YTick', 0:0.2:1);
ylabel('Probability of Lick Response by Stimulus Type');
% h = line([0.5 size(crop_data,2)+0.5], [0.5 0.5]);
% set(h, 'LineWidth', 0.1, 'LineStyle', ':', 'Color', ColorPicker('darkgray'));
h = legend(subjects);
set(h, 'Box', 'off');

%% Plot NP Rate/min
clf;

rate_np_min = rate_np * 1e3 * 60;
% h = plot(rate_np_min', '.-');
% h = plot(dates', rate_np_min', '.-');

% dates = unique(dates);
dates = dates(:);
days = mod(dates,100);
months = mod(floor(dates/100),100);
years = floor(dates/1e4);
serial_dates = datenum(years, months, days);
serial_dates = reshape(serial_dates, size(rate_np_min));
h = plot(serial_dates', rate_np_min', '.-');
% Graph by date using serial dates, shows vacation days for better & worse
datetick('x', 6);

idx_young = subjects(:,2) == 'B';
idx_aged = subjects(:,2) == 'C';
set(h(idx_young), 'LineStyle', ':');
set(h(idx_aged), 'LineStyle', '-');

% axis([0.5 size(rate_np, 2)+0.5 0 Inf]);
axis tight
% set(gca, 'XTick', 1:size(per_gostim_lick,2));
xlabel('Date');
% set(gca, 'YTick', 0:0.2:1);
ylabel('Rate NP / min');

h = legend(subjects);
set(h, 'Box', 'off');
set(h, 'Location', 'SouthEast');

% hold on;
% set(gca, 'Color', ColorPicker('lightgray'))
% idx_young = subjects(:,2) == 'B';
% idx_aged = subjects(:,2) == 'C';

%% Plot accuracy
mask = ~isnan(per_nogostim_lick);
% crop_data = per_nogostim_lick(crop);
num_sessions = sum(mask, 2);
crop_data = nan(num_subjects, max(num_sessions));

for i_subject = 1:num_subjects
    crop_data(i_subject, 1:num_sessions(i_subject)) = acc(i_subject, mask(i_subject, :));
end

clf;
hold on;
set(gca, 'Color', ColorPicker('lightgray'))
idx_young = subjects(:,2) == 'B';
idx_aged = subjects(:,2) == 'C';

h = plot(crop_data', '.-');
set(h, 'Color', ColorPicker('black'));
set(h(idx_young), 'LineStyle', ':');
set(h(idx_aged), 'LineStyle', '-');
for i = 1:length(h)
    set(h(i), 'Marker', symbols(i));
    set(h(idx_aged), 'MarkerSize', 10);
end

axis([0.5 size(crop_data,2)+0.5 0 1]);
set(gca, 'XTick', 1:size(per_gostim_lick,2));
xlabel('Sessions');
set(gca, 'YTick', 0:0.2:1);
ylabel('Accuracy');
h = line([0.5 size(crop_data,2)+0.5], [0.8 0.8]);
set(h, 'LineWidth', 0.1, 'LineStyle', ':', 'Color', ColorPicker('darkgray'));
h = legend(subjects);
set(h, 'Box', 'off');
set(h, 'Location', 'SouthEast');


