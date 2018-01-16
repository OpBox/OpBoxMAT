function [ts_on, ts_off] = TimestampsAlignOnOff(ts_on, ts_off)

%% Check that have data
if isempty(ts_on) && isempty(ts_off)
    return;
end

%% Sort events and ts
all_ts = [ts_on(:); ts_off(:)];
[sort_ts, sort_idx] = sort(all_ts);
labels = [true(size(ts_on(:))); false(size(ts_off(:)))]; 
sort_labels = labels(sort_idx);

%% Make sure starts with On and ends with Off
if ~sort_labels(1)
    sort_labels = [true; sort_labels];
    sort_ts = [NaN; sort_ts];
end
if sort_labels(end)
    sort_labels = [sort_labels; false];
    sort_ts = [sort_ts; NaN];
end
    
%% Find doubles
idx_same = find([0 == diff(sort_labels); false]);
% If off and on happen at same time, then will get flagged as out of order
% If a swap fixes everything, then swap
idx_close = find(diff(idx_same) == 2);
for i_close = 1:numel(idx_close)
    idx_temp = idx_same(idx_close(i_close));
    if sort_ts(idx_temp+1) == sort_ts(idx_temp+2)
        sort_labels(idx_temp+(1:2)) = ~sort_labels(idx_temp+(1:2));
    end
end

%% Add in NaNs for remaining gaps
idx_same = find([0 == diff(sort_labels); false]);
for i_same = 1:numel(idx_same)
    sort_labels = [sort_labels(1:idx_same(i_same)); ~sort_labels(idx_same(i_same)); sort_labels(idx_same(i_same)+1:end)];
    sort_ts = [sort_ts(1:idx_same(i_same)); NaN; sort_ts(idx_same(i_same)+1:end)];
    idx_same(i_same+1:end) = idx_same(i_same+1:end) + 1; % Adjust for insertion of one event
end

%% Find median duration between events
sort_ts = reshape(sort_ts, 2, numel(sort_ts)/2);
med_dur = nanmedian(diff(sort_ts));

%% Add in extra time stamps, e.g. replace NaNs
% Extra On's
idx_mask = find(isnan(sort_ts(1, :)));
temp_ts = repmat(sort_ts(1, :), 2, 1);
temp_ts(1, idx_mask) = sort_ts(2, idx_mask) - med_dur; % Could result in negative events at start
temp_other = [0, sort_ts(2, :)];
temp_ts(2, idx_mask) = temp_other(idx_mask) + 1; % Could result in negative events at start
sort_ts(1, :) = max(temp_ts);
% sort_ts(1, idx_mask) = sort_ts(2, idx_mask) - med_dur; % Could result in negative events at start
% Make sure not too far back

% Extra Off's
idx_mask = find(isnan(sort_ts(2, :)));
temp_ts = repmat(sort_ts(2, :), 2, 1);
temp_ts(1, idx_mask) = sort_ts(1, idx_mask) + med_dur;
temp_other = [sort_ts(1, :), inf];
temp_ts(2, idx_mask) = temp_other(idx_mask+1) - 1; % Could result in negative events at start
sort_ts(2, :) = min(temp_ts);

if sum(sort_ts(:) < 0)
    fprintf('Error: Negative events in TimestampsAlignOnOff\n');
%     keyboard;
end


%% Make sure events do not overlap: Should not happen anymore?
margin = 1;
for i_row = 1:size(sort_ts, 1)
    mask_overlap = diff(sort_ts(i_row, :)) < 0;
    if sum(mask_overlap)
        fprintf('Error: Overlap between %d events in TimestampsAlignOnOff\n', sum(mask_overlap));
        keyboard;
    end
end


%% Reassign
ts_on = sort_ts(1, :);
ts_off = sort_ts(2, :);



% %%
% 
% sort_ts
% 
% val = [];
% idx_same = [0; idx_same; numel(all_ts)+1];
% for i_same = 1:numel(idx_same)-1
%     val = [val; sort_ts(idx_same(i_same)+1:idx_same(i_same+1)-1)];
% end
% val = reshape(val, 2, numel(val)/2);
% 
% if nargin < 1
%     med_dur = median(diff(val));
% end
% 
% 
% 
% %% Code
% % margin = median(temp_ts_after([false; mask_more]) - ts_less(mask_more)); % If not known, would have to align first, then calculate and fill in NaNs?
% if numel(ts_on) > numel(ts_off)
%     % Add trial off if missing for a trial on
%     ts_more_before = ts_on;
%     ts_less_after = ts_off;
%     temp_ts_before = [ts_more_before; inf];
%     mask = false(size(ts_more_before));
%     for i_ts = 1:numel(temp_ts_before)-1
%         num_between = sum((temp_ts_before(i_ts) <= ts_less_after) & (ts_less_after <= temp_ts_before(i_ts + 1)));
%         if 0 == num_between
%             % Insert a trial off
%             temp_trial = min(temp_ts_before(i_ts) + max_dur, temp_ts_before(i_ts + 1) - margin);
%             ts_less_after = sort([ts_less_after; temp_trial]); % Easier to code than finding to insert, should not have to run too many times
%         elseif 1 == num_between
%             mask(i_ts) = true; % Keeps track of which were aligned, unlikely to be used
%         else
%             fprintf('%d events found between bookends\n', num_between);
%         end
%     end
%     fprintf('Needed to align %d events\n', sum(~mask));
%     ts_on = ts_more_before;
%     ts_off = ts_less_after;
% elseif numel(ts_on) < numel(ts_off)
%     ts_less_before = ts_on;
%     ts_more_after = ts_off;
%     temp_ts_after = [0; ts_more_after];
%     mask = false(size(ts_more_after));
%     for i_ts = 1:numel(temp_ts_after) - 1
%         num_between = sum((temp_ts_after(i_ts) <= ts_less_before) & (ts_less_before <= temp_ts_after(i_ts + 1)));
%         if 0 == num_between
%             % Insert a trial off
%             temp_trial = max(temp_ts_after(i_ts) + margin, temp_ts_after(i_ts + 1) - max_dur);
%             ts_less_before = sort([ts_less_before; temp_trial]); % Easier to code than finding to insert, should not have to run too many times
%         elseif 1 == num_between
%             mask(i_ts) = true; % Keeps track of which were aligned, unlikely to be used
%         else
%             fprintf('%d events found between bookends\n', num_between);
%         end
%     end
%     fprintf('Needed to align %d events\n', sum(~mask));
%     ts_on = ts_less_before;
%     ts_off = ts_more_after;
% end
% 
% 
