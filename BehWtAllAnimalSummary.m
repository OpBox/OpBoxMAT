clc;
clear all;
% clf;

%% Select Files: Get Excel info to ID sessions
cdDropbox;
cd('Research');

xls_file = 'Projects.xls';
[num,txt,raw] = xlsread(xls_file, 'Rats');

%% Pull out dates
[num_txt_rows, num_txt_cols] = size(txt);

col_dates = 1;
row_first_date = 5;
num_dates = num_txt_rows - row_first_date + 1;

all_dates = nan(num_dates, 1);
for i_row = 1:num_dates
    all_dates(i_row) = datenum(txt{i_row + row_first_date - 1, col_dates}(5:end));
end

%% Pull out subj names
% all_subjs = txt(1, 2:2:end);
all_subjs = unique(txt(1, :));
all_subjs = all_subjs(strncmp(all_subjs, 'kB', 2) | strncmp(all_subjs, 'kC', 2));
num_subjs = numel(all_subjs);
char_subjs = cell2mat(all_subjs');
mask_old = char_subjs(:, 2) == 'C';

%% Pull out weights
idx_wt_cols = [];
for i_subj = 1:num_subjs
    idx_col = find(strcmp(txt(1, :), all_subjs(i_subj))); % Shift 1 as name is over weights, not activity for the day
    idx_col = idx_col - 1; % subtract 1 since first column is not present in num data
    idx_wt_cols = [idx_wt_cols, idx_col];
end

row_first_wt = 4;
all_wts = num(row_first_wt:end, idx_wt_cols);

x_coords = all_dates(1:size(all_wts, 1));
clf;
h = plot(x_coords, all_wts, '.-');
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));
axis([-Inf Inf, 0 Inf]);


%% Plot relative wts
clf
hold on;
h = line(x_coords([1, end]), repmat(0.85, 2, 1));
set(h, 'LineStyle', ':', 'Color', ColorPicker('lightgray'));

start_wts = nan(1, num_subjs);
for i_subj = 1:num_subjs
    temp_wts = all_wts(:, i_subj);
    temp_wts = temp_wts(~isnan(temp_wts));
    if ~isempty(temp_wts)
        start_wts(i_subj) = temp_wts(1);
    end
end

rel_wts = all_wts ./ repmat(start_wts, size(all_wts, 1), 1);
h = plot(x_coords, rel_wts, '.-');
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));


%% Plot Central Tendency & Measure of Variability by Groups
clf;
% PlotMeanErr(rel_wts(:, mask_old)', ColorPicker('brown'), x_coords');
% PlotMeanErr(rel_wts(:, ~mask_old)', ColorPicker('green'), x_coords');
PlotMedIQR(rel_wts(:, mask_old)', ColorPicker('brown'), x_coords');
PlotMedIQR(rel_wts(:, ~mask_old)', ColorPicker('green'), x_coords');

%% Plot trajectory of weight after various events
label = 'Restrict';





%%
if 1
    for i_inj = 1:num_injs
        i_row = find(strncmp(txt(:, idx_col), name_inj{i_inj}, 3));
        if isempty(i_row)
            fprintf('No file found for subject %s for inj %s\n', all_subjs{i_subj}, name_inj{i_inj});
            continue
        else
            num_dates = nan(length(i_row), 1);
            for i_row = 1:numel(i_row)
                num_dates(i_row) = datenum(txt{i_row(i_row), 1}(5:end));
            end
            i_row = i_row(num_dates <= datenum(date)-1);
            if isempty(i_row)
                continue;
            end
            
            i_row = i_row(end);
            
            str_date = txt{i_row, 1};
            [start_mo,end_mo] = regexp(str_date,' [0-9]*/');
            [start_day,end_day] = regexp(str_date,'/[0-9]*/');
%             file_mask = sprintf('%s-20%s%02d%02d-*.txt', subjs{i_subj}, str_date(end-1:end), str2double(str_date(start_mo+1:end_mo-1)), str2double(str_date(start_day+1:end_day-1)));
            file_mask = sprintf('%s-%s-*.txt', all_subjs{i_subj}, datestr(datenum(str_date(5:end)), 'yyyymmdd'));

            files = dir(file_mask);
            filename = files(end).name;
            
            data{i_subj, i_inj} = BehGoNogoSessionSummary(filename);
            
        end
    end
end


%% Plot relevant data from sessions over time
clf;
grid_axes = SubPlotGrid(4, 4);
max_minutes = 240;

for i_subj = 1:length(all_subjs)
    axes(grid_axes(i_subj));
    set(gca, 'FontSize', 6)
    title(all_subjs{i_subj});
    hold on;
    for i_inj = 1:num_injs
        if ~isempty(data{i_subj, i_inj})

%             ts = data{i_subj, i_inj}.ts_np_in;
            ts = data{i_subj, i_inj}.ts_stim_on;
            ts = double(ts);
            ts = ts/1e3/60;
            
%             % Plot ts related data
% %             h = plot(ts, 1:length(ts), '.-');
%             % NPs over time (binned)
%             bin_minutes = 1;
%             hist_data = histc(ts, 0:bin_minutes:max_minutes);
% %             h = plot(bin_minutes:bin_minutes:max_minutes, hist_data(1:end-1), '.-');
%             win_smooth = 10;
%             smooth_hist = RunningAverage(hist_data, win_smooth);
%             h = plot((win_smooth-1)*bin_minutes:bin_minutes:max_minutes, smooth_hist, '.-');
            
            % Plot Percentage data
%             per = data{i_subj, i_inj}.hit_attempts;
            per = data{i_subj, i_inj}.acc_by_trials;
            per = double(per);
%             % Plot unsmoothed data
%             h = plot(1:length(per), per, '.');

            win_smooth = 40;
            smooth_per = RunningAverage(per, win_smooth);
            h = plot(ts(end-length(smooth_per)+1:end), smooth_per, '.-');

            set(h, 'Marker', '.');
            set(h, 'MarkerSize', 10);
            set(h, 'LineWidth', 0.1);
            set(h, 'Color', colors(i_inj, :));
        end
    end
%     axis([0 240, 0 1]);
    axis([0 max_minutes, 0 Inf]);
%     axis tight;

%     h = legend(name_inj);
%     set(h, 'Box', 'off');
%     set(h, 'Location', 'SouthEast');
end


%% Collect summary data from sessions: e.g. acc over session, ___ trials, ___ time, etc
summary = nan(length(all_subjs), num_injs);
clf;
num_trials_crop = 100;
ts_crop = 2 * 60 * 60 * 1e3; % x hr * 60 min/hr * 60 sec/min * 1000 ms/min

for i_subj = 1:length(all_subjs)
    for i_inj = 1:num_injs
        if ~isempty(data{i_subj, i_inj})
            per = data{i_subj, i_inj}.acc_by_trials;
            per = double(per);
%             % Crop by trials
%             per = per(1:num_trials_crop);
            % Crop by time
            idx_crop = data{i_subj, i_inj}.ts_stim_on < ts_crop;
            per = per(idx_crop);
            summary(i_subj, i_inj) = mean(per);
            
            % Trial to first criteria
            summary(i_subj, i_inj) = data{i_subj, i_inj}.crit_trial;

            % Time to first criteria
            if ~isnan(data{i_subj, i_inj}.crit_trial)
                summary(i_subj, i_inj) = data{i_subj, i_inj}.ts_stim_on(data{i_subj, i_inj}.crit_trial);
            end

%             % Check # switches, but need to correct for time
%             summary(i_subj, i_inj) = data{i_subj, i_inj}.num_switches;

        end
    end
end

h = plot(summary', '.-');
axis([0.5 num_injs+0.5, 0 max(1, max(summary(:)))]);
set(gca, 'XTick', 1:num_injs, 'XTickLabel', name_inj);
char_subjs = cell2mat(all_subjs');
mask_old = char_subjs(:, 2) == 'C';
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));

%% Reexpress as a relative percentage of Saline (column 1)
clf; hold on;
h = line([0.5 num_injs+0.5], [1 1]);
set(h, 'Color', ColorPicker('lightgray'));
rel_summary = summary ./ repmat(summary(:, 1), 1, size(summary, 2));
h = plot(rel_summary', '.-');
axis([0.5 num_injs+0.5, -Inf Inf]);
set(gca, 'XTick', 1:num_injs, 'XTickLabel', name_inj);
char_subjs = cell2mat(all_subjs');
mask_old = char_subjs(:, 2) == 'C';
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));

%% Collect summary data from sessions: # nosepokes within ___ time
summary = nan(length(all_subjs), num_injs);
clf;
ts_crop = 2 * 60 * 60 * 1e3; % x hr * 60 min/hr * 60 sec/min * 1000 ms/min
for i_subj = 1:length(all_subjs)
    for i_inj = 1:num_injs
        if ~isempty(data{i_subj, i_inj})
            temp_data = data{i_subj, i_inj}.ts_np_in;
            summary(i_subj, i_inj) = sum(temp_data < ts_crop);
        end
    end
end

h = plot(summary', '.-');
axis([0.5 num_injs+0.5, 0 1]);
set(gca, 'XTick', 1:num_injs, 'XTickLabel', name_inj);
char_subjs = cell2mat(all_subjs');
mask_old = char_subjs(:, 2) == 'C';
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));

% %% Reexpress as a relative percentage of Saline (column 1)
clf; hold on;
h = line([0.5 num_injs+0.5], [1 1]);
set(h, 'Color', ColorPicker('lightgray'));
rel_summary = summary ./ repmat(summary(:, 1), 1, size(summary, 2));
h = plot(rel_summary', '.-');
axis([0.5 num_injs+0.5, -Inf Inf]);
set(gca, 'XTick', 1:num_injs, 'XTickLabel', name_inj);
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));



%% Overlay plots on each other
clf;
grid_axes = SubPlotGrid(num_injs, 1);
max_minutes = 240;
    
for i_inj = 1:num_injs
    axes(grid_axes(i_inj));
    set(gca, 'FontSize', 6)
    title(name_inj{i_inj});
    hold on;
    for i_subj = 1:length(all_subjs)
        
        if ~isempty(data{i_subj, i_inj})

%             ts = data{i_subj, i_inj}.ts_np_in;
            ts = data{i_subj, i_inj}.ts_stim_on;
            ts = double(ts);
            ts = ts/1e3/60;
            
%             % Plot ts related data
% %             h = plot(ts, 1:length(ts), '.-');
%             % NPs over time (binned)
%             bin_minutes = 1;
%             hist_data = histc(ts, 0:bin_minutes:max_minutes);
% %             h = plot(bin_minutes:bin_minutes:max_minutes, hist_data(1:end-1), '.-');
%             win_smooth = 5;
%             smooth_hist = RunningAverage(hist_data, win_smooth);
%             h = plot((win_smooth-1)*bin_minutes:bin_minutes:max_minutes, smooth_hist, '.-');

            % Plot Percentage data
%             per = data{i_subj, i_inj}.hit_attempts;
            per = data{i_subj, i_inj}.acc_by_trials;
            per = double(per);
%             % Plot unsmoothed data
%             h = plot(1:length(per), per, '.');

            win_smooth = 20;
            smooth_per = RunningAverage(per, win_smooth);
            h = plot(ts(end-length(smooth_per)+1:end), smooth_per, '.-');

            set(h, 'Marker', '.');
            set(h, 'MarkerSize', 10);
            set(h, 'LineWidth', 0.1);
            if mask_old(i_subj)
                set(h, 'Color', ColorPicker('brown'));
            else 
                set(h, 'Color', ColorPicker('green'));
            end
        end
    end
%     axis([0 240, 0 1]);
%     axis tight;

%     h = legend(name_inj);
%     set(h, 'Box', 'off');
%     set(h, 'Location', 'SouthEast');
end


% Standardize y_limits
max_y = 0;
for i_inj = 1:num_injs
    axes(grid_axes(i_inj));
    max_y = max([max_y, get(gca, 'YTick')]);
end

for i_inj = 1:num_injs
    axes(grid_axes(i_inj));
    axis([0 max_minutes, 0 max_y]);
end