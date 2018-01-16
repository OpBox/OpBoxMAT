function [crop_data] = PosTrackCropTS(data, crop_ms)

% initial PosTrack binary files were whole sessions, even before/after behavior
% therefore, crop_ms is derived from the function BehGoNogoCropTS and 
% depends on ts_start & ts_end in parts, 
% which are not saved in the PosTrack binary file as of 2015/02/08

mask = crop_ms(1) <= data.ts & data.ts <= crop_ms(end); % Ok to use = on both ends since this is about position rather than a new event that could be counted twice. Can have same position in different blocks

crop_data = data; % to copy over all other field quickly
crop_data.ts = data.ts(mask) - double(crop_ms(1));  % crop_ms may come in as int64
crop_data.num_ts = numel(crop_data.ts);
crop_data.x_data = data.x_data(:, mask);
crop_data.y_data = data.y_data(:, mask);
crop_data.crop_ms = crop_ms - crop_ms(1);