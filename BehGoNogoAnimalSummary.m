clc;
clear all;

dir_name = [cdData '\Behavior\RandIntGoNogoSwitch'];
% dir_name = [cdData '\Behavior\RandIntGoNogoSwitch\MouseDelirium'];
cd(dir_name);

temp_anim = 'kBn';
% temp_anim = 'MD06';
% temp_date = '20140616';
% temp_date = datestr(now, 'yyyymmdd');
temp_date = '2016*';

file_mask = [temp_anim '-' temp_date '-*.txt'];
files = dir(file_mask);
num_files = length(files);

fprintf('%d files found\n', num_files);
data = [];
% all_stim_class = [];
% all_stim_ids = [];
% all_hit_attempts = [];
% num_switches = [];

for i_file = 1:num_files
    filename = files(i_file).name;
    name_dates{i_file} = filename(9:12);
    
    temp_data = BehGoNogoSessionDots(filename);
    if isfield(temp_data, 'acc') && ~isempty(temp_data.acc)
        data = [data, temp_data];
    end
end

% RandIntGoNogo: <90min: >=85% over 100 trials, >80 reward

%% Plot data
figure(1);
clf;
num_skip = 5;
num_files = numel(data);

subplot(3, 1, 1);
hold on;
h = line([0.5 num_files+0.5], [0.8 0.8]);
set(h, 'LineStyle', ':', 'Color', ColorPicker('lightgray'));
plot([data.acc], 'k.-');
axis([0.5 num_files+0.5, 0 1]);
title(temp_anim);
ylabel('Acc');
% xlabel('Sessions');
set(gca, 'XTick', 1:num_skip:num_files);
% set(gca, 'XTickLabel', name_dates(1:num_skip:end));
set(gca, 'XTickLabel', {data(1:num_skip:end).Protocol});

subplot(3, 1, 2);
hold on;
h = line([0.5 num_files+0.5], [80 80]);
set(h, 'LineStyle', ':', 'Color', ColorPicker('lightgray'));
plot([data.num_hits], 'k.-');
axis([0.5 num_files+0.5, 0 300]);
ylabel('# Rewards');
% xlabel('Sessions');
set(gca, 'XTick', 1:num_skip:num_files);
% set(gca, 'XTickLabel', name_dates(1:num_skip:end));
set(gca, 'XTickLabel', {data(1:num_skip:end).Protocol});

subplot(3, 1, 3);
hold on;
plot([data.num_switches], 'k.-');
% axis([0.5 num_files+0.5, 0 5]);
axis([0.5 num_files+0.5, 0 10]);
ylabel('# Switches');
% xlabel('Sessions');
set(gca, 'XTick', 1:num_skip:num_files);
set(gca, 'XTickLabel', {data(1:num_skip:end).Protocol});


% %% Plot acc & stims & hit attempts
% figure(2);
% clf;
% hold on;
% 
% all_acc = nan(size(all_stim_class));
% all_acc(all_stim_class == 'G') = all_hit_attempts(all_stim_class == 'G');
% all_acc(all_stim_class == 'N') = ~all_hit_attempts(all_stim_class == 'N');
% 
% sub_trials = find(~isnan(all_acc));
% per_crit = 0.85-eps;
% win = 100;
% if ~isempty(sub_trials)
%     hist_data = line([0 sub_trials(end)], repmat(per_crit,2,1));
%     set(hist_data, 'LineWidth', 0.1');
%     set(hist_data, 'Color', ColorPicker('lightgray'));
%     set(hist_data, 'LineStyle', ':');
% 
%     win_acc = RunningAverage(all_acc(sub_trials), win);
%     hist_data = plot(sub_trials(win:end), win_acc, '-');
%     set(hist_data, 'Color', ColorPicker('lightgray'));
%     set(hist_data, 'LineWidth', 0.1', 'MarkerSize', 5);
% end
% 
% % plot points for >crit
% idx_pts = find(win_acc > per_crit);
% temp_sub_trials = sub_trials(win:end);
% h = plot(temp_sub_trials(idx_pts), win_acc(idx_pts), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% 
% % Now plot responses by stimulus type
% win = 20;
% name_stim_ids = [0, 'L', 'M', 'H'];
% colors = [
%     ColorPicker('pink');
%     ColorPicker('brown');
%     ColorPicker('purple');
%     ColorPicker('blue');
% ];
% 
% for i_session = 1:length(idx_end_session)
%     h = line(repmat(idx_end_session(i_session),2,1), [0 1]);
%     set(h, 'LineStyle', ':', 'LineWidth', 0.1, 'Color', ColorPicker('lightgray'));
% end
% 
% for i_id = 1:length(name_stim_ids)
%     idx_trials = find(all_stim_ids == name_stim_ids(i_id));
%     if ~isempty(idx_trials)
%         sub_hit = all_hit_attempts(idx_trials);
%         smooth_hit = RunningAverage(sub_hit, win);
%         hist_data = plot(idx_trials(win:end), smooth_hit, '-');
%         set(hist_data, 'LineWidth', 0.1);
%         set(hist_data, 'Color', colors(i_id, :));
%         
%         % Mark by stim_class
%         % GO trials
%         sub_class = all_stim_class(idx_trials) == 'G';
%         sub_class = sub_class(win:end);
%         if ~isempty(sub_class)
%             temp_trials = idx_trials(win:end);
%             h_markers = plot(temp_trials(sub_class), smooth_hit(sub_class), '.');
%             set(h_markers, 'Marker', '.');
%             set(h_markers, 'LineWidth', 0.1);
%             set(h_markers, 'Color', colors(i_id, :));
%         end
%         % GO trials
%         sub_class = all_stim_class(idx_trials) == 'N';
%         sub_class = sub_class(win:end);
%         if ~isempty(sub_class)
%             temp_trials = idx_trials(win:end);
%             h_markers = plot(temp_trials(sub_class), smooth_hit(sub_class), '.');
%             set(h_markers, 'Marker', 'x');
%             set(h_markers, 'LineWidth', 0.1);
%             set(h_markers, 'Color', colors(i_id, :));
%         end
%     end
% end
% 
% title(filename);
% axis([0 Inf 0 1.01])
% xlabel('Trials (Nosepokes)');
% ylabel(sprintf('Probability of Response by Stimulus Type\nRunning Average over %d Trials', win));
% 
% set(gca, 'XTick', RunningAverage([0 idx_end_session],2));
% set(gca, 'FontSize', 7);
% % set(gca, 'XTickLabel', name_dates(1:num_skip:end));
% set(gca, 'XTickLabel', name_protocols(1:num_skip:end));
% 
