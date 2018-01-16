clear all;
clc;

%% Select Files: Get Excel info to ID sessions
cdDropbox;
cd('Research\Behavior\GeneralBehavior');

xls_file = 'RatWeights.xls';
[num,txt,raw] = xlsread(xls_file, 'RatWeights');

%% Identify subjects
subjs = unique(txt(1, :));
subjs = subjs(strncmp(subjs, 'kB', 2) | strncmp(subjs, 'kC', 2));
subjs = {'kBe'    'kBf'    'kBg'    'kBh'    'kCe'    'kCf'    'kCg'    'kCh'};

%% Define session injs
% injs = {'Sal', 'LPS'};
% injs = {'Sal15', 'LPS60 (Dose 500ug/kg)', 'Iso120', 'Scop15 (Dose 5mg/kg)'};
% injs = {'Beh w/EEG', 'Sal15 w/EEG', 'LPS60 (Dose 500ug/kg) w/EEG', 'Iso120 (Dose 2%) w/EEG', 'Scop15 (Dose 5mg/kg) w/EEG'};
% injs = {'Beh w/EEG'; 'Sal15'; 'LPS60 (Dose 500ug/kg)'; 'Iso120'; 'Scop15 (Dose 5mg/kg)'};
% injs = {'Beh w/EEG'; 'Sal15'; 'Scop15 (Dose 5mg/kg)'; 'LPS60 (Dose 500ug/kg)'; 'Iso120'};
% colors = [ColorPicker('gray'); ColorPicker('blue'); ColorPicker('orange'); ColorPicker('green'); ColorPicker('purple')];
% injs = {'Beh w/EEG'; 'Sal15 w/EEG'; 'Scop15 (Dose 5mg/kg) w/EEG'; 'LPS60 (Dose 500ug/kg) w/EEG'; 'Iso120 (Dose 2%) w/EEG'};
% colors = [ColorPicker('gray'); ColorPicker('blue'); ColorPicker('orange'); ColorPicker('green'); ColorPicker('purple')];
injs = {'Beh w/EEG'; 'Scop15 (Dose 5mg/kg) w/EEG'; 'LPS60 (Dose 500ug/kg) w/EEG'; 'Iso120 (Dose 2%) w/EEG'};
colors = [ColorPicker('gray'); ColorPicker('orange'); ColorPicker('green'); ColorPicker('purple')];

% injs = {'NoInj', 'Sal', 'Scop', 'Amm', 'Iso', 'LPS'};
% colors = [ColorPicker('gray'); ColorPicker('blue'); ColorPicker('orange'); ColorPicker('red'); ColorPicker('purple'); ColorPicker('green')];

%% Identify sessions: find dates for each subject
[dates, subjs, injs] = BehGoNogoSubjInjDates(txt, subjs, injs);
num_subjs = numel(subjs);
num_injs = length(injs);

%% Pull up session data for each session
cdDropbox;
cd('Research\Behavior\Data\RandIntGoNogoSwitch');

beh_data = cell(num_injs, num_subjs);
pos_data = cell(num_injs, num_subjs);

% grid_axes = AxesGrid(num_injs, num_subjs);
font_size = 6;

crop_hr = 5;

for i_subj = 1:num_subjs
    fprintf('Subject %s (%d/%d)\n', subjs{i_subj}, i_subj, num_subjs);
    grid_axes = AxesGrid(2, 2);
    for i_inj = 1:num_injs
        if numel(dates{i_inj, i_subj})
            % Behavioral file
            file_mask = sprintf('%s-%s-*.txt', subjs{i_subj}, dates{i_inj, i_subj});
            files = dir(file_mask);
            if ~isempty(files)
                filename = files(end).name;
                fprintf('%s\n', filename);
%                 axes(grid_axes(i_inj, i_subj));
                axes(grid_axes(i_inj));
                BehGoNogoSessionSummary(filename);
                set(gca, 'FontSize', font_size);
                axis([0 crop_hr/24 0 1.01]);
                datetick('x', 'keeplimits');
                set(gca, 'YTickMode', 'auto');
                ylabel(injs(i_inj));

                
                if i_inj == 1
                    title(subjs(i_subj));
                else
                    title('');
                end
                if i_subj == 1
                    ylabel(injs(i_inj));
                end
            end
        end
    end
    pause;
end
fprintf('\n');

%% Crop and summarize session data for each session
crop_beh_data = cell(num_injs, num_subjs);
beh_summary = cell(num_injs, num_subjs);
pos_summary = cell(num_injs, num_subjs);

% Define window of interest & bin lengths/edges
crop_hr = [0 4];
crop_sec = crop_hr * 60 * 60;
crop_ms = crop_sec *1e3;
win_min = 15;
win_ms = win_min * 60 * 1e3;
win_edges_ms = crop_ms(1):win_ms:crop_ms(end);

for i_subj = 1:num_subjs
    fprintf('Subject %s (%d/%d)\n', subjs{i_subj}, i_subj, num_subjs);
    for i_inj = 1:num_injs
        if ~isempty(beh_data{i_inj, i_subj})
            fprintf('Subject %s, Date %d\n', beh_data{i_inj, i_subj}.Subject, beh_data{i_inj, i_subj}.DateTimeStart(1));
            crop_beh_data{i_inj, i_subj} = BehGoNogoCropTS(beh_data{i_inj, i_subj}, crop_sec);
            beh_summary{i_inj, i_subj} = BehGoNogoOutcomesScalar(crop_beh_data{i_inj, i_subj} );
%         end
        % Assume have corresponding pos_data file for now
%         if ~isempty(pos_data{i_inj, i_subj})
            temp_pos_data = PosTrackCropTS(pos_data{i_inj, i_subj}, temp_beh_data.crop_ms);
            pos_summary{i_inj, i_subj} = PosTrackOutcomesScalar(temp_pos_data);
        end
    end
end

%% Plot summary scalar variables: Behavior
field_names = fieldnames(beh_summary{1});
for i_field = 1:numel(field_names)
    field_name = field_names{i_field};
    vals = StructMatFieldScalar(beh_summary, field_name);
    % replace infs for graphing purposes with max of all other values
    vals(vals==Inf) = max(vals(vals~=Inf));
    
    clf;
    h = bar(vals');
    for i_inj = 1:num_injs
        set(h(i_inj), 'FaceColor', colors(i_inj, :));
    end
%     legend(injs, 'Location', 'NorthEast');
    set(gca, 'XTick', 1:num_subjs);
    set(gca, 'XTickLabel', subjs);
    axis tight;
    title(field_name, 'Interpreter','none');
    pause;
end

%% Plot summary scalar variables: Behavior: Pairwise comparisons
field_names = fieldnames(beh_summary{1});
% for i_field = 1:numel(field_names)
for i_field = 8
    field_name = field_names{i_field};
    vals = StructMatFieldScalar(beh_summary, field_name);
    % replace infs for graphing purposes with max of all other values
    vals(vals==Inf) = max(vals(vals~=Inf));
    
    idx_injs = [1 4];
    vals = vals(idx_injs, :);

    clf;
    h = bar(vals');
    for i_inj = 1:numel(idx_injs)
        set(h(i_inj), 'FaceColor', colors(idx_injs(i_inj), :));
    end
%     legend(injs, 'Location', 'NorthEast');
    set(gca, 'XTick', 1:num_subjs);
    set(gca, 'XTickLabel', subjs);
    axis tight;
%     title(field_name, 'Interpreter','none');
    axis([-Inf Inf 0 1]);
    ylabel('Accuracy')
end


%% Plot summary array/map variables: PosTrack Heat maps
font_size = 10;
grid_axes = AxesGrid(num_injs, num_subjs, 1);
for i_inj = 1:num_injs
    for i_subj = 1:num_subjs
        axes(grid_axes(i_inj, i_subj));
        if ~isempty(pos_data{i_inj, i_subj})
            [heat_map, h_map] = PosTrackDisplayHeatMap(pos_data{i_inj, i_subj}.x_data, pos_data{i_inj, i_subj}.y_data);
%             axes(grid_axes(i_inj, i_subj));
%             image(postrack_summary{i_inj, i_subj}.array_y * postrack_summary{i_inj, i_subj}.array_x');
        end
        if i_subj == 1
            % h = ylabel(injs{i_inj});
            h = ylabel(injs{i_inj}(1:3));
            set(h, 'FontSize', font_size);
        end
        if i_inj == 1
            h = title(subjs{i_subj});
            set(h, 'FontSize', font_size);
        end
    end
end

%% Plot summary scalar variables: PosTrack
field_names = fieldnames(pos_summary{1});
% for i_field = 1:numel(field_names)
for i_field = 1
    field_name = field_names{i_field};
    vals = StructMatFieldScalar(pos_summary, field_name);
    idx_injs = [1 4];
    vals = vals(idx_injs, :);
    clf;
    h = bar(vals');
    for i_inj = 1:numel(idx_injs)
        set(h(i_inj), 'FaceColor', colors(idx_injs(i_inj), :));
    end
%     for i_inj = 1:num_injs
%         set(h(i_inj), 'FaceColor', colors(i_inj, :));
%     end
%     legend(injs, 'Location', 'NorthEast');
    set(gca, 'XTick', 1:num_subjs);
    set(gca, 'XTickLabel', subjs);
    axis tight;
%     title(field_name, 'Interpreter','none');
    ylabel('Speed: inches/sec');
%     pause;
end

%% Plot relative summary scalar variables: PosTrack
field_names = fieldnames(pos_summary{1});
for i_field = 1:numel(field_names)
    field_name = field_names{i_field};
    vals = StructMatFieldScalar(pos_summary, field_name);
    vals = vals ./ repmat(vals(1, :), num_injs, 1);
    clf;
    h = bar(vals');
    for i_inj = 1:num_injs
        set(h(i_inj), 'FaceColor', colors(i_inj, :));
    end
    legend(injs, 'Location', 'NorthEast');
    set(gca, 'XTick', 1:num_subjs);
    set(gca, 'XTickLabel', subjs);
    axis tight;
    title(field_name, 'Interpreter','none');
    pause;
end

%% Plot summary array variables: PosTrack
clf;
grid_axes = AxesGrid(num_subjs/2, 2, 1);
field_names = fieldnames(pos_summary{1});
for i_field = 1:numel(field_names)
    field_name = field_names{i_field};
    vals = StructMatFieldArray(pos_summary, field_name);
    for i_subj = 1:num_subjs
        axes(grid_axes(i_subj));
        temp_data = squeeze(vals(:, i_subj, :));
        h = plot(win_edges_ms(2:end)/1e3/60/60/24, temp_data', '.-');
        set(h, 'LineWidth', 2);
        for i_inj = 1:num_injs
            set(h(i_inj), 'Color', colors(i_inj, :));
        end
        axis tight;
        title(sprintf('%s: %s', field_name, subjs{i_subj}), 'Interpreter','none');
        datetick;
%         legend(injs, 'Location', 'NorthWest');
    end
    pause;
end

%% Plot summary matrix variables: PosTrack
clf;
grid_axes = AxesGrid(num_subjs/2, 2, 1);
field_names = fieldnames(pos_summary{1});
for i_field = 1:numel(field_names)
    field_name = field_names{i_field};
    vals = StructMatFieldArray(pos_summary, field_name);
    for i_subj = 1:num_subjs
        axes(grid_axes(i_subj));
        temp_data = squeeze(vals(:, i_subj, :));
        h = plot(win_edges_ms(2:end)/1e3/60/60/24, temp_data', '.-');
        set(h, 'LineWidth', 2);
        for i_inj = 1:num_injs
            set(h(i_inj), 'Color', colors(i_inj, :));
        end
        axis tight;
        title(sprintf('%s: %s', field_name, subjs{i_subj}), 'Interpreter','none');
        datetick;
%         legend(injs, 'Location', 'NorthWest');
    end
    pause;
end


%% Plot relevant behavioral data from sessions over time
clf;
grid_axes = SubPlotGrid(num_injs, num_subjs);
max_minutes = 240;

for i_subj = 1:num_subjs
    for i_inj = 1:num_injs
        axes(grid_axes(i_inj, i_subj));
        set(gca, 'FontSize', 6)
        title(subjs{i_subj});
        hold on;
        if ~isempty(beh_data{i_inj, i_subj})

%             ts = data{i_subj, i_inj}.ts_np_in;
            ts = beh_data{i_inj, i_subj}.ts_stim_on;
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
            per = beh_data{i_inj, i_subj}.acc_by_trials;
            per = double(per);
%             % Plot unsmoothed data
%             h = plot(1:length(per), per, '.');

            win_smooth = 40;
            smooth_per = RunningAverage(per, win_smooth);
            h = plot(ts(end-length(smooth_per)+1:end), smooth_per, '.-');

            set(h, 'Marker', '.');
            set(h, 'MarkerSize', 3);
            set(h, 'LineWidth', 0.1);
            set(h, 'Color', colors(i_inj, :));
        end
    end
%     axis([0 240, 0 1]);
    axis([0 max_minutes, 0 Inf]);
%     axis tight;

%     h = legend(injs);
%     set(h, 'Box', 'off');
%     set(h, 'Location', 'SouthEast');
end

%% Plot relevant PosTrack data from sessions over time
clf;
grid_axes = SubPlotGrid(num_injs, num_subjs);
max_minutes = 240;

for i_subj = 1:length(subjs)
    axes(grid_axes(i_inj, i_subj));
    set(gca, 'FontSize', 6)
    title(subjs{i_subj});
    hold on;
    for i_inj = 1:num_injs
        if ~isempty(pos_data{i_inj, i_subj})
            ts = pos_data{i_inj, i_subj}.ts;
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
            set(h, 'MarkerSize', 3);
            set(h, 'LineWidth', 0.1);
            set(h, 'Color', colors(i_inj, :));
        end
    end
%     axis([0 240, 0 1]);
    axis([0 max_minutes, 0 Inf]);
%     axis tight;

%     h = legend(injs);
%     set(h, 'Box', 'off');
%     set(h, 'Location', 'SouthEast');
end


%% Collect summary data from sessions: e.g. acc over session, ___ trials, ___ time, etc
beh_summary = nan(length(subjs), num_injs);
clf;
% num_trials_crop = 100;
ts_crop = 1 * 60 * 60 * 1e3; % x hr * 60 min/hr * 60 sec/min * 1000 ms/min
% ts_crop = 4 * 60 * 60 * 1e3; % x hr * 60 min/hr * 60 sec/min * 1000 ms/min

for i_subj = 1:length(subjs)
    for i_inj = 1:num_injs
        if ~isempty(data{i_subj, i_inj})

            % Accuracy over time
            per = data{i_subj, i_inj}.acc_by_trials;
            per = double(per);

%             % Crop by trials
%             per = per(1:num_trials_crop);

            % Crop by time
            idx_crop = data{i_subj, i_inj}.ts_stim_on < ts_crop;
            per = per(idx_crop);

            beh_summary(i_subj, i_inj) = mean(per);
            
%             % Number of nosepokes over time period
%             summary(i_subj, i_inj) = sum(data{i_subj, i_inj}.ts_np_in < ts_crop);
            
%             % Trial to first criteria
%             summary(i_subj, i_inj) = data{i_subj, i_inj}.crit_trial;
% 
%             % Time to first criteria
%             if ~isnan(data{i_subj, i_inj}.crit_trial)
%                 time_to_first_criteria = data{i_subj, i_inj}.ts_stim_on(data{i_subj, i_inj}.crit_trial);
%                 summary(i_subj, i_inj) = time_to_first_criteria/1e3/60; % from ms to sec, from sec to min
%             end

%             % Check # switches, but need to correct for time
%             summary(i_subj, i_inj) = data{i_subj, i_inj}.num_switches;

        end
    end
end

% imagesc(summary); caxis([0 1]);

h = plot(beh_summary', '.-');
axis([0.5 num_injs+0.5, 0 max(1, max(beh_summary(:)))]);
set(gca, 'XTick', 1:num_injs, 'XTickLabel', injs);
char_subjs = cell2mat(subjs');
mask_old = char_subjs(:, 2) == 'C';
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));

%% Reexpress as a relative percentage of Saline or Other (column 1): Line graph
clf; hold on;
% ref_inj = 'NoInj';
ref_inj = 'Sal';
idx_col = strmatch(ref_inj, injs);

h = line([0.5 num_injs+0.5], [1 1]);
set(h, 'Color', ColorPicker('lightgray'));
rel_summary = beh_summary ./ repmat(beh_summary(:, idx_col), 1, size(beh_summary, 2));
h = plot(rel_summary', '.-');
set(gca, 'XTick', 1:num_injs, 'XTickLabel', injs);
char_subjs = cell2mat(subjs');
mask_old = char_subjs(:, 2) == 'C';
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));
axis([0.5 num_injs+0.5, 0 Inf]);

% %% Reexpress as a relative percentage of Saline or Other (column 1): Bar Graph

young_vals = rel_summary(~mask_old, :);
old_vals = rel_summary(mask_old, :);

clf; hold on;
margin = 0.05;
h = plot((1:size(rel_summary,2))-margin, young_vals', '.');
set(h, 'Color', ColorPicker('green'));
h = plot((1:size(rel_summary,2))+margin, old_vals', '.');
set(h, 'Color', ColorPicker('brown'));

% idx_col = strmatch('Sal', injs);
% rel_summary = summary ./ repmat(summary(:, idx_col), 1, size(summary, 2));
% char_subjs = cell2mat(subjs');
% mask_old = char_subjs(:, 2) == 'C';

% h = plot(rel_summary', '.-');
% set(gca, 'XTick', 1:num_injs, 'XTickLabel', injs);
% set(h(mask_old), 'Color', ColorPicker('brown'));
% set(h(~mask_old), 'Color', ColorPicker('green'));

axis([0.5 num_injs+0.5, 0 Inf]);
set(gca, 'XTick', 1:num_injs, 'XTickLabel', injs);

% Multiple comparison ttests for young vs. old
p_val = nan(1, num_injs);
for test_col = 1:num_injs
    p_val(test_col) = ttest2(young_vals(:, test_col), old_vals(:, test_col));
    % does this account for NaNs? -- yes seems to ignore them
end
p_val





%% Collect summary data from sessions: # nosepokes within ___ time
beh_summary = nan(length(subjs), num_injs);
clf;
ts_crop = 2 * 60 * 60 * 1e3; % x hr * 60 min/hr * 60 sec/min * 1000 ms/min
for i_subj = 1:length(subjs)
    for i_inj = 1:num_injs
        if ~isempty(data{i_subj, i_inj})
            temp_data = data{i_subj, i_inj}.ts_np_in;
            beh_summary(i_subj, i_inj) = sum(temp_data < ts_crop);
        end
    end
end

h = plot(beh_summary', '.-');
axis([0.5 num_injs+0.5, 0 1]);
set(gca, 'XTick', 1:num_injs, 'XTickLabel', injs);
char_subjs = cell2mat(subjs');
mask_old = char_subjs(:, 2) == 'C';
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));

% %% Reexpress as a relative percentage of Saline (column 1)
clf; hold on;
h = line([0.5 num_injs+0.5], [1 1]);
set(h, 'Color', ColorPicker('lightgray'));
rel_summary = beh_summary ./ repmat(beh_summary(:, 1), 1, size(beh_summary, 2));
h = plot(rel_summary', '.-');
axis([0.5 num_injs+0.5, -Inf Inf]);
set(gca, 'XTick', 1:num_injs, 'XTickLabel', injs);
set(h(mask_old), 'Color', ColorPicker('brown'));
set(h(~mask_old), 'Color', ColorPicker('green'));



%% Overlay plots on each other
clf;
grid_axes = SubPlotGrid(num_injs, 1);
max_minutes = 240;
    
for i_inj = 1:num_injs
    axes(grid_axes(i_inj));
    set(gca, 'FontSize', 6)
    title(injs{i_inj});
    hold on;
    for i_subj = 1:length(subjs)
        
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

%     h = legend(injs);
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