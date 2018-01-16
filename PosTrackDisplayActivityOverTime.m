function h = PosTrackDisplayActivityOverTime(x_data, y_data, ts, ts_start, bin_dur_min)

if nargin < 5
    bin_dur_min = 1;
    if nargin < 4
        ts_start = 0;
    end
end
ts_adj = ts - double(ts_start);

num_x = size(x_data,1);
num_y = size(y_data,1);

temp_x = bsxfun(@times, x_data, (1:num_x)');
temp_x(temp_x==0) = NaN;
mean_x = nanmean(temp_x, 1);
% plot(mean_x);

temp_y = bsxfun(@times, y_data, (1:num_y)');
temp_y(temp_y==0) = NaN;
mean_y = nanmean(temp_y, 1);
% plot(mean_y);

% % When data in columns rather than rows:
% num_x = size(x_data,2);
% num_y = size(y_data,2);
% 
% temp_x = bsxfun(@times, x_data, 1:num_x);
% temp_x(temp_x==0) = NaN;
% mean_x = nanmean(temp_x, 2);
% 
% temp_y = bsxfun(@times, y_data, 1:num_y);
% temp_y(temp_y==0) = NaN;
% mean_y = nanmean(temp_y, 2);

x_dist = diff(mean_x);
y_dist = diff(mean_y);
dist = (x_dist.^2 + y_dist.^2).^0.5;

% bin in some fashion to display over time rather than just point by point
bin_dur = bin_dur_min * 60 * 1e3; % in ms
if ts_adj(end) > bin_dur
    bins = 0:bin_dur:ts_adj(end);
else
    bins = [0 ts_adj(end)];
end
% win_minutes = 1;
% bin_minutes = 0:win_minutes:ts_min(end);

% ts_min = ts_adj/1e3/60;
% ts_day = ts_adj/MsPerDay();

ts_adj = ts_adj(2:end); % since looking at ends of bins
temp_data = nan(1, length(bins)-1);
for i_bin = 1:numel(bins)-1
    temp_data(i_bin) = nansum(dist(bins(i_bin) < ts_adj & ts_adj <= bins(i_bin+1))) / bin_dur * 1e3;
end

hold on;
h = line([0 bins(end)]/MsPerDay(), repmat(mean(temp_data), 2, 1));
set(h, 'LineWidth', 0.1, 'LineStyle', '-', 'Color', ColorPicker('lightgray'));
h = plot(bins(2:end)/MsPerDay(), temp_data, '.-');
axis([0 Inf, 0 Inf]);
% xlabel('Time');
% ylabel('Distance (pix/min)');
ylabel('Distance/Time');
% title(sprintf('Bin duration (mins)=%d', bin_dur_min));

%% Smoothed version
% dur_smooth = 10;
% win_smooth = floor(dur_smooth/win_minutes);
% plot(bin_minutes((1+win_smooth):end), RunningAverage(temp_data, win_smooth), '.-')
% axis([0 ts_min(end), 0 Inf]);
% xlabel('Time (min)');
% ylabel('Distance (pixels/min)');
% title(sprintf('Bin duration (mins)=%d, Win smooth (%d bins)=%d min', win_minutes, win_smooth, dur_smooth));
