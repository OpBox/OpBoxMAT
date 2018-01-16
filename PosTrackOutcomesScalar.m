function [summary] = PosTrackOutcomesScalar(data)

if data.num_ts == 0
    summary.dist_per_sec = [];  % or NaN?
    summary.frac_op_loc = [];
    summary.mean_x = [];
    summary.mean_y = [];
    summary.pos_changes_per_sec = [];
    summary.array_x = [];
    summary.array_y = [];
    summary.map = [];
    summary.locomotor = [];
    summary.bin_dur = [];
    return;
end

[x_pos, y_pos] = PosTrackCoords(data.x_data, data.y_data);
dist = (diff(x_pos).^2 + diff(y_pos).^2).^0.5;
intervals = diff(data.ts);
if sum(intervals<0)
    fprintf('NOTE: Negative PosTrack ts interval found for subject %s on %s\n', data.subject_name, data.date_time);
    idx_neg = find(intervals<0);
    for i_neg = 1:numel(idx_neg)
        total_time = sum(intervals(idx_neg(i_neg) + (-1:0)));
        if total_time > 0
            intervals(idx_neg(i_neg) + (-1:0)) = total_time / 2;
        end
    end
end

% Define rectangle/"quadrant" (50% each dimension = 25% total area) for operant devices
op_loc_x = [0 data.num_x/2];
op_loc_y = 9*[0.25 0.75];

% Summary measures
summary.dist_per_sec = nanmean(dist(:) ./ (intervals(:) / 1e3));
summary.frac_op_loc = mean(op_loc_x(1) < x_pos & x_pos <= op_loc_x(2) & op_loc_y(1) < y_pos & y_pos <= op_loc_y(2));
summary.mean_x = nanmean(x_pos);
summary.mean_y = nanmean(y_pos);
summary.pos_changes_per_sec = sum(dist>0) / (max(data.ts) / 1e3);

% The following are not scalars, but actually arrays
summary.array_x = mean(data.x_data, 2);
summary.array_y = mean(data.y_data,2);
% 2D matrix/heat map of average rat position
summary.map = summary.array_y * summary.array_x';


% %% Binned locomotor activity
% % bin in some fashion to display over time rather than just point by point
% tic;
% bin_dur = 60e3; % sec->ms
% bins = data.crop_ms(1):bin_dur:data.crop_ms(end);
% temp_data = nan(1, numel(bins)-1);
% dist = [0 dist];
% for i_bin = 1:numel(bins)-1
%     mask_ts = bins(i_bin) < data.ts & data.ts <= bins(i_bin+1);
%     temp_data(i_bin) = sum(dist(mask_ts));
% %     temp_data(i_bin) = nansum(dist(mask_ts)) / bin_dur * 1e3;
% end
% temp_data = temp_data / bin_dur * 1e3;
% toc
% 
% summary.locomotor = temp_data;
% summary.bin_dur = bin_dur;
