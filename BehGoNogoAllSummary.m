% Nosepoke on 6
% Glue acrylic boxes

clc;
clear all;

cdMatlab;
% cd('..\Research\Behavior\Data\RandIntGoNogo');
% cd('..\Research\Behavior\Data\GoNogoTrack');
cd('..\Research\Behavior\Data\RandIntGoNogoSwitch');
% cd('..\Research\Behavior\Data\RandIntGoNogoOnArduino');
% cd('..\Research\Behavior\Data\AnimalFacilityData\RandIntGoNogoSwitch');

% temp_date = '20140616';
% temp_date = datestr(now, 'yyyymmdd');
temp_date = '*';
temp_anim = '*';

file_mask = [temp_anim '-' temp_date '-*.txt'];
files = dir(file_mask);

filenames = vertcat(files.name);
anims = filenames(:, 1:3);
[name_anims, idx_names, idx_anims] = unique(anims, 'rows');
num_anims = length(name_anims);
num_files_per_anim = hist(idx_anims, 1:num_anims);
max_num_files = max(num_files_per_anim);

%%
num_rewards = nan(num_anims, max_num_files);
num_switches = nan(num_anims, max_num_files);
acc = nan(num_anims, max_num_files);

for i_anim = 1:num_anims
    temp_anim = name_anims(i_anim, :);
    file_mask = [temp_anim '-' temp_date '-*.txt'];
    files = dir(file_mask);
    num_files = length(files);

    fprintf('%d files found\n', num_files);
    all_stim_ids = [];
    all_hit_attempts = [];
    for i_file = 1:num_files
        filename = files(i_file).name;
        name_dates{i_file} = filename(9:12);

        [data, per_stimid_lick, name_stim_ids, acc(i_anim, i_file), med_npdur, med_lick] = BehGoNogoSessionSummary(filename);
        all_stim_ids = [all_stim_ids; data.np_stim_id(:)];
        all_hit_attempts = [all_hit_attempts; data.hit_attempts(:)];
        idx_end_session(i_file) = length(all_stim_ids);

        num_rewards(i_anim, i_file) = length(data.ts_reward_on);
        num_switches(i_anim, i_file) = data.num_switches;
        
        switch data.Protocol
            case 'FR1Go'
                temp_name = 'FR1';
            case 'NPGo'
                temp_name = 'FR1';
            case 'RandInt20'
                temp_name = 'RI20';
            case 'RandInt40'
                temp_name = 'RI40';
            case 'RandIntGoNogo'
    %             temp_name = 'GoNogo';
                if isfield(data, 'GoStimIDs')
                    temp_name = sprintf('GN:%c+%c-', data.GoStimIDs, data.NogoStimIDs);
                else
                    temp_name = sprintf('Early');
                end
            case 'RandIntGoNogoSwitch'
    %             temp_name = 'Switch';
                if isfield(data, 'GoStimIDs')
                    temp_name = sprintf('GN:%c+%c-', data.GoStimIDs, data.NogoStimIDs);
                else
                    temp_name = sprintf('Early');
                end
            otherwise
                temp_name = data.Protocol;
        end
        name_protocols{i_file} = temp_name;
    %     name_protocols{i_file} = sprintf('%s\n%s', temp_name, name_dates{i_file});
    end
end
% RandIntGoNogo: <90min: >=85% over 100 trials, >80 reward

%% Plot data
clf;
num_skip = 1;

subplot(3, 1, 1);
hold on;
h = line([0.5 max_num_files+0.5], repmat(0.85, 2, 1));
set(h, 'LineStyle', ':', 'Color', ColorPicker('lightgray'));
plot(acc', '.-');
% PlotMedIQR(acc');
axis([0.5 max_num_files+0.5, 0 1]);
ylabel('Acc');
% xlabel('Sessions');
set(gca, 'XTick', 1:num_skip:max_num_files);
% set(gca, 'XTickLabel', name_dates(1:num_skip:end));
set(gca, 'XTickLabel', name_protocols(1:num_skip:end));

subplot(3, 1, 2);
hold on;
h = line([0.5 max_num_files+0.5], [80 80]);
set(h, 'LineStyle', ':', 'Color', ColorPicker('lightgray'));
plot(num_rewards', '.-');
% PlotMedIQR(num_rewards');
axis([0.5 max_num_files+0.5, 0 Inf]);
ylabel('#Rewards');
% xlabel('Sessions');
set(gca, 'XTick', 1:num_skip:max_num_files);
set(gca, 'XTickLabel', name_dates(1:num_skip:end));

subplot(3, 1, 3);
hold on;
h = line([0.5 max_num_files+0.5], [80 80]);
set(h, 'LineStyle', ':', 'Color', ColorPicker('lightgray'));
num_subj = size(num_switches, 1);
% x_coords = repmat(1:max_num_files, num_subj, 1) + repmat(linspace(0, 1, size(num_switches, 1)), size(num_switches, 2), 1)';
% plot(x_coords', num_switches', '.-');
plot(num_switches', '.-');
% PlotMedIQR(num_switches');
axis([0.5 max_num_files+1, 0 6]);
ylabel('#Switches');
% xlabel('Sessions');
set(gca, 'XTick', 1:num_skip:max_num_files);
set(gca, 'XTickLabel', name_dates(1:num_skip:end));

%% Plot data by animal in different subplot
clf;
grid_axes = SubPlotGrid(ceil(num_subj/4), 4);
num_skip = floor(max_num_files/6);

for i_subj = 1:num_subj
    axes(grid_axes(i_subj));
    plot(num_switches(i_subj, :), '.-');
    axis([0.5 max_num_files+0.5, 0 max(num_switches(:))]);
    set(gca, 'FontSize', 6);
    set(gca, 'XTick', 1:num_skip:max_num_files);
    set(gca, 'XTickLabel', name_dates(1:num_skip:end));
    h = title(name_anims(i_subj, :));
    set(h, 'FontSize', 6);
end

for i_plot = i_subj+1:length(grid_axes(:))
    axes(grid_axes(i_plot));
    set(gca, 'Visible', 'off');
end



%% Plot all animal data
clf
markers = ['.ox+*sdv^<>ph']';
% markers = {'.', 'o', 'x', '+', '*', 's', 'd', 'v', '^', '<', '>', 'p', 'h'};
hold on;

% h = plot(num_rewards', '.-');
h = plot(num_switches', '.-');
% h = plot(acc', '.-');

temp_anims = name_anims(:,2)=='B';
set(h(temp_anims), 'LineStyle', ':');
temp_anims = name_anims(:,2)=='C';
set(h(temp_anims), 'LineStyle', '-');

temp_anims = name_anims(:,3)<'e';
set(h(temp_anims), 'Color', ColorPicker('darkgreen'));
temp_anims = name_anims(:,3)>='e';
set(h(temp_anims), 'Color', ColorPicker('brown'));

for i = 1:length(h)
    set(h(i), 'Marker', markers(1+(mod(i-1, length(markers)))));
end

axis([0.5 max_num_files+0.5, 0 Inf]);
xlabel('Sessions');
ylabel('# Rewards');
legend(name_anims, 'Location', 'West');

% % Criteria of sorts line
% h = line([0.5 max_num_files+0.5], repmat(80, 2, 1));
% set(h, 'LineStyle', ':', 'Color', ColorPicker('lightgray'));


% clf
% data = num_rewards>50;
% data = data+1;
% data(isnan(num_rewards)) = 0;
% imagesc(data);
% set(gca, 'YTick', 1:num_anims);
% set(gca, 'YTickLabel', name_anims);

%% Plot stims & hit attempts
clf;
hold on;

% Now plot responses by stimulus type
win = 20;
name_stim_ids = [0, 'L', 'M', 'H'];
colors = [
    ColorPicker('pink');
    ColorPicker('brown');
    ColorPicker('purple');
    ColorPicker('blue');
];

for i_session = 1:length(idx_end_session)
    h = line(repmat(idx_end_session(i_session),2,1), [0 1]);
    set(h, 'LineStyle', ':', 'LineWidth', 0.1, 'Color', ColorPicker('lightgray'));
end

for i_id = 1:length(name_stim_ids)
    idx_trials = find(all_stim_ids == name_stim_ids(i_id));
    if ~isempty(idx_trials)
        sub_hit = all_hit_attempts(idx_trials);
%         sub_ts = double(data.ts_np_out(sub_trials));
        smooth_hit = RunningAverage(sub_hit, win);
%         crop_ts = sub_ts(win:end)/60e3;
%         hist_data = plot(crop_ts, smooth_hit, '-');
          hist_data = plot(idx_trials(win:end), smooth_hit, '.-');
        set(hist_data, 'LineWidth', 0.1);
        set(hist_data, 'Color', colors(i_id, :));
%         % Mark by stim_class
%         sub_class = np_stim_class(idx_trials);
%         % GO trials
%         mask_class = find(sub_class == 'G') - win + 1;
%         mask_class = mask_class(mask_class > 0);
%         if ~isempty(mask_class)
%             hist_data = plot(crop_ts(mask_class), smooth_hit(mask_class), '.');
%             set(hist_data, 'Marker', '.');
%             set(hist_data, 'LineWidth', 0.1);
%             set(hist_data, 'Color', colors(i_id, :));
%         end
%         % NOGO trials
%         mask_class = find(sub_class ~= 'G') - win + 1;
%         mask_class = mask_class(mask_class > 0);
%         if ~isempty(mask_class)
%             hist_data = plot(crop_ts(mask_class), smooth_hit(mask_class), '.');
%             set(hist_data, 'Marker', 'x');
%             set(hist_data, 'LineWidth', 0.1);
%             set(hist_data, 'Color', colors(i_id, :));
%         end
    end
end

title(filename);
axis([0 Inf 0 1.01])
xlabel('Trials (Nosepokes)');
ylabel(sprintf('Probability of Response by Stimulus Type\nRunning Average over %d Trials', win));

set(gca, 'XTick', RunningAverage([0 idx_end_session],2));
set(gca, 'FontSize', 7);
% set(gca, 'XTickLabel', name_dates(1:num_skip:end));
set(gca, 'XTickLabel', name_protocols(1:num_skip:end));

