function PlotSparklineGoNogo(data, stim_class, ts, win, rect_width)

% clf
% clear all
% num_trials = 200;
% p = 0.3;
% temp_class = [(1-p)*ones(num_trials/2,1); p*ones(num_trials/2,1)];
% data = rand(num_trials, 1) < temp_class;
% temp_class = temp_class > 0.5;
% stim_class(temp_class) = 'G';
% stim_class(~temp_class) = 'N';
% % ts = sort(rand(num_trials*2, 1)) * num_trials;
% % ts = ts([1:num_trials/2, end-num_trials/2+1:end]);
% % ts = 1:num_trials;
% ts = sort(rand(num_trials, 1)) * num_trials;
% win = 20;

% Sparkline like plot using rectangles
% rect_width = 2*median(diff(ts));
% rect_width = 0.0001;
rect_height = 0.5;

hold on;
for i = 1:numel(data)
    if data(i)
        h = rectangle('Position', [ts(i)-rect_width/2, 0.5, rect_width, rect_height]);
    else 
        h = rectangle('Position', [ts(i)-rect_width/2, 0.5-rect_height, rect_width, rect_height]);
    end
    set(h, 'EdgeColor', 'none');
    if stim_class(i) == 'G'
        set(h, 'FaceColor', ColorPicker('cyan'));
    else
        set(h, 'FaceColor', ColorPicker('lightred'));
    end
end

% %% Sparkline like plot using squares: Not noticeable enough, especially when there is a reasonable amount of overlap, really need some height to see them
% marker_size = 3;
% margin = 0.1;
% y_center = 0.5;
% 
% clf;
% hold on;
% h = plot(ts(stim_class == 'G'), y_center + margin*(data(stim_class == 'G')-0.5), 's');
% set(h, 'MarkerSize', marker_size);
% set(h, 'MarkerFaceColor', ColorPicker('cyan'));
% set(h, 'MarkerEdgeColor', 'none');
% 
% h = plot(ts(stim_class ~= 'G'), y_center + margin*(data(stim_class ~= 'G')-0.5), 's');
% set(h, 'MarkerSize', marker_size);
% set(h, 'MarkerFaceColor', ColorPicker('pink'));
% set(h, 'MarkerEdgeColor', ColorPicker('lightgray'));
% set(h, 'LineWidth', 0.1);
% axis([0 Inf 0 1]);


%% Now plot RunningAverage
marker_size = 5;

smooth_data = RunningAverage(data, win);
smooth_ts = ts(win:end);
h_plot = plot(smooth_ts, smooth_data, '.');
set(h_plot, 'Color', ColorPicker('gray'));
set(h_plot, 'MarkerSize', marker_size);
% h_plot = plot(smooth_ts, smooth_data, 'o');
% set(h_plot, 'MarkerEdgeColor', ColorPicker('white'));
% set(h_plot, 'LineWidth', 0.001);

% margin = 0.01;
% axis([0 Inf 0-margin 1+margin]);

axis_height = 1;
axis([0 Inf 0.5-axis_height 0.5+axis_height]);
