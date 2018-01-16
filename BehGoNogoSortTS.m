function [sort_ts, sort_ids] = BehGoNogoSortTS(data)

% rarely, ~once every 2-4 sessions, on one trial NPin & NPout co-occur, e.g. filename = 'kBa-20131207-165916.txt';
% seems to be due to a flicker of instability as
% NPOut is followed by an immediate NPIn with the same timestamp
% Doesn't seem to happen other way, so rearranged before sort[sort_ts, idx_sort] = sort(all_ts);
all_ts = [data.ts_np_out; data.ts_np_in; data.ts_stim_on; data.ts_lick_in];
all_ids = ['n' * ones(size(data.ts_np_out)); 'N' * ones(size(data.ts_np_in)); 'S' * ones(size(data.ts_stim_on)); 'L' * ones(size(data.ts_lick_in))];
[sort_ts, idx_sort] = sort(all_ts);
sort_ids = all_ids(idx_sort);
sort_ts = [-1; sort_ts; sort_ts(end) + 1];
sort_ids = ['X'; sort_ids; 'X'];
