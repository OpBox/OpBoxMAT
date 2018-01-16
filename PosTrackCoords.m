function [mean_x, mean_y] = PosTrackCoords(x_data, y_data)

num_x = size(x_data,1);
num_y = size(y_data,1);

% tic;
score_x = bsxfun(@times, x_data, (1:num_x)'); % Faster than repmat first time, not with repeated checks
score_x = sum(score_x);
sum_bins = sum(x_data);
mean_x = score_x ./ sum_bins;

score_y = bsxfun(@times, y_data, (1:num_y)'); % Faster than repmat first time, not with repeated checks
score_y = sum(score_y);
sum_bins = sum(y_data);
mean_y = score_y ./ sum_bins;

% toc;
% tic;
% temp_x = x_data .* repmat((1:num_x)', 1, size(x_data, 2));
% toc;

% temp_x(temp_x==0) = NaN;
% mean_x = nanmean(temp_x, 1);
% plot(mean_x);

% tic;
% temp_y = bsxfun(@times, y_data, (1:num_y)');
% toc;
% tic;
% temp_y = y_data .* repmat((1:num_y)', 1, size(y_data, 2));
% toc;


% temp_y = bsxfun(@times, y_data, (1:num_y)');
% temp_y(temp_y==0) = NaN;
% mean_y = nanmean(temp_y, 1);
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

% % Distance calculation
% x_dist = diff(mean_x);
% y_dist = diff(mean_y);
% dist = (x_dist.^2 + y_dist.^2).^0.5;
