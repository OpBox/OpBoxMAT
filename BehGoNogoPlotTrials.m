function BehGoNogoSessionPlot(data)


%% plot window of responses over session
clf;
hold on;
% ACCuracy for stim trials only -- plot first/in background
if ~isempty(ts_stim_trials)
    hist_data = line([0 ts_stim_trials(end)/MsPerDay()], repmat(per_crit,2,1));
    set(hist_data, 'LineWidth', 0.1');
    set(hist_data, 'Color', ColorPicker('lightgray'));
    set(hist_data, 'LineStyle', ':');
end

% h = line([0 ts_stim_trials(end)/60e3], repmat(0.9,2,1));
% set(h, 'LineWidth', 0.1');
% set(h, 'Color', ColorPicker('lightgray'));
% set(h, 'LineStyle', ':');

win_acc = RunningAverage(data.acc_by_trials, win);
hist_data = plot(ts_stim_trials(win:end)/MsPerDay(), win_acc, '-');
set(hist_data, 'Color', ColorPicker('lightgray'));
set(hist_data, 'LineWidth', 0.1');
temp_ts = ts_stim_trials(win:end)/MsPerDay();
h = plot(temp_ts(win_acc>per_crit), win_acc(win_acc>per_crit), '.');
set(h, 'Color', ColorPicker('lightgray'));
set(h, 'MarkerSize', 5);

% Stim responses, use shorter window
win = 20;

% Now plot responses by stimulus type
all_stim_ids = [0, 'L', 'M', 'H'];
colors = [
    ColorPicker('pink');
    ColorPicker('brown');
    ColorPicker('purple');
    ColorPicker('blue');
];

for i_id = 1:length(all_stim_ids)
    % Stim trials
    sub_trials = data.np_stim_id == all_stim_ids(i_id);
    if sum(sub_trials)
        sub_hit = data.hit_attempts(sub_trials);
        sub_ts = double(data.ts_np_out(sub_trials));
        smooth_hit = RunningAverage(sub_hit, win);
        crop_ts = sub_ts(win:end)/MsPerDay();
        hist_data = plot(crop_ts, smooth_hit, '-');
        set(hist_data, 'LineWidth', 0.1);
        set(hist_data, 'Color', colors(i_id, :));
        % Mark by stim_class
        sub_class = data.np_stim_class(sub_trials);
        % GO trials
        mask_class = find(sub_class == 'G') - win + 1;
        mask_class = mask_class(mask_class > 0);
        if ~isempty(mask_class)
            hist_data = plot(crop_ts(mask_class), smooth_hit(mask_class), '.');
            set(hist_data, 'Marker', '.');
            set(hist_data, 'LineWidth', 0.1);
            set(hist_data, 'Color', colors(i_id, :));
        end
        % NOGO trials
        mask_class = find(sub_class ~= 'G') - win + 1;
        mask_class = mask_class(mask_class > 0);
        if ~isempty(mask_class)
            hist_data = plot(crop_ts(mask_class), smooth_hit(mask_class), '.');
            set(hist_data, 'Marker', 'x');
            set(hist_data, 'LineWidth', 0.1);
            set(hist_data, 'Color', colors(i_id, :));
        end
    end
end

title(filename);
datetick('x');
axis([0 Inf 0 1.01])
% xlabel('Time (min)');
ylabel(sprintf('Probability of Response by Stimulus Type\nRunning Average over %d Trials', win));

% %% Plot timepoints of trials
% clf;
% hist_data = plot(double(data.ts_np_in)/1e3/60, 1:length(data.ts_np_in), '.-k');
% set(hist_data, 'LineWidth', 0.1);
% axis tight;
% % set(gca, 'YDir', 'reverse');
% xlabel('Session Time (min)');
% ylabel('# Nosepokes (Cumulative)');
% set(gca, 'Box', 'off');
% title(filename);
% 
% %% Plot Nosepoke duration
% dur = double(data.ts_np_out - data.ts_np_in);
% h = plot(dur, '.');
% set(h, 'MarkerSize', 1);
% 
% clf;
% bin_edges = 0:1:1000;
% hist_data = histc(dur, bin_edges);
% plot(bin_edges, hist_data, '.-');
% % plot(FFTnorm(hist_data), '.-'); % peaks at 245, 489/514, 758
% title([filename '   NPdur']);
% 
% 
% %% Plot Inter Nosepoke Interval
% ini = double(data.ts_np_in(2:end) - data.ts_np_out(1:end-1));
% h = plot(ini, '.');
% set(h, 'MarkerSize', 1);
% 
% bin_edges = 0:1:1000;
% hist_data = histc(ini,bin_edges);
% plot(bin_edges, hist_data, '.-');
% title(filename);
% 
% % plot(FFTnorm(hist_data), '.-'); % peaks at 245, 489/514, 758
% 
% 
% %% Plot Lick duration 
% dur = double(data.ts_lick_out - data.ts_lick_in);
% h = plot(dur, '.');
% set(h, 'MarkerSize', 1);
% 
% clf;
% bin_edges = 0:1:1000;
% hist_data = histc(dur, bin_edges);
% plot(bin_edges, hist_data, '.-');
% title(filename);
% 
% plot(FFTnorm(hist_data), '.-'); % peaks at 245, 489/514, 758
% 
% %% Plot Inter Lick Interval
% ini = double(data.ts_lick_in(2:end) - data.ts_lick_out(1:end-1));
% h = plot(ini, '.');
% set(h, 'MarkerSize', 1);
% 
% bin_edges = 0:1:1000;
% hist_data = histc(ini,bin_edges);
% plot(bin_edges, hist_data, '.-');
% title(filename);
% 
% plot(FFTnorm(hist_data), '.-'); % peaks at 245, 489/514, 758
% 

%% Num switches: Assuming only 1 Go Stim at a time
stim_id_go = data.stim_id(data.stim_class == 'G');
data.num_switches = sum(abs(diff(stim_id_go))>0);


%% List final stimulus pair
idx_class = find(data.stim_class == 'G');
data.last_go = char(data.stim_id(idx_class(end)));
fprintf('Last stim = %c+', data.last_go);

idx_class = find(data.stim_class == 'N');
if ~isempty(idx_class)
    data.last_nogo = char(data.stim_id(idx_class(end)));
    fprintf(' vs. %c-', data.last_nogo);
else
    data.last_nogo = [];
end
fprintf('\n');

%% Final new line
fprintf('\n');
