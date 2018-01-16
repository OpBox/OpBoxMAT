function data = BehGoNogoCleanFile(data)

mismatch = false;

%% Check to see that some data exists
if isempty(data) || ~isfield(data, 'ts_stim_on') || isempty(data.ts_stim_on)
    fprintf('Empty file/no stimulus onsets\n');
    % need to create empty fields so as not to crash calling function?
    return;
end

if ~isfield(data, 'response') || ~isfield(data, 'outcome')
    fprintf('Early file without specific responses or outcomes\n');
    data = BehGoNogoResponseOutcomeFromTs(data);
end

%% Calculate data.ts_end if it is not present
if ~isfield(data, 'ts_end') || numel(data.ts_end) == 0
    field_names = fieldnames(data);
    ts_fields = regexp(field_names, 'ts_.*', 'match');
    ts_fields = unique([ts_fields{:}]);
    all_ts = [];
    for i_field = 1:numel(ts_fields)
        all_ts = [all_ts; data.(ts_fields{i_field})];
    end
    data.ts_end = max(all_ts);
end
if ~isfield(data, 'ts_start') || isempty(data.ts_start)
    data.ts_start = 0;
end
data.dur = data.ts_end(1)-data.ts_start(end);

%% Eliminate Bookend Ins/Outs: Could be due to when protocol started or stopped if in middle of an action
if isfield(data, 'ts_np_in') && numel(data.ts_np_in) && numel(data.ts_np_out)
    data.ts_np_out = data.ts_np_out(data.ts_np_out >= data.ts_np_in(1));
    data.ts_np_in = data.ts_np_in(data.ts_np_in <= data.ts_np_out(end));
% else
%     fprintf('No nosepoke data\n'); % Will be missing for all head fix setups
end
if isfield(data, 'ts_lick_in') && numel(data.ts_lick_in) && numel(data.ts_lick_out)
    data.ts_lick_out = data.ts_lick_out(data.ts_lick_out >= data.ts_lick_in(1));
    data.ts_lick_in = data.ts_lick_in(data.ts_lick_in <= data.ts_lick_out(end));
else
    fprintf('No lick data\n');
end

% For bookend stim on & off, may affect stim_class & stim_id
mask_keep = data.ts_stim_off >= data.ts_stim_on(1);
data.ts_stim_off = data.ts_stim_off(mask_keep);
if (sum(mask_keep) ~= numel(mask_keep)) && (numel(mask_keep) == numel(data.response))
    data.response = data.response(mask_keep);
    data.outcome = data.outcome(mask_keep);
end

mask_keep = data.ts_stim_on <= data.ts_stim_off(end);
data.ts_stim_on = data.ts_stim_on(data.ts_stim_on <= data.ts_stim_off(end));
if (sum(mask_keep) ~= numel(mask_keep)) && (numel(mask_keep) == numel(data.stim_class))
    if numel(data.response) == numel(data.stim_class)
        data.response = data.response(mask_keep);
        data.outcome = data.outcome(mask_keep);
    end
    data.stim_class= data.stim_class(mask_keep);
    data.stim_id= data.stim_id(mask_keep);
end

% %% Remove double counted events: Too rapid in & out rarely
% data.ts_np_in = data.ts_np_in([true; diff(data.ts_np_in) > 0]);
% data.ts_np_out = data.ts_np_out([true; diff(data.ts_np_out) > 0]);
% data.ts_lick_in = data.ts_lick_in([true; diff(data.ts_lick_in) > 0]);
% data.ts_lick_out = data.ts_lick_out([true; diff(data.ts_lick_out) > 0]);


%% Check for mismatches: Nosepokes
% Will miss double drops
if numel(data.ts_np_in) ~= numel(data.ts_np_out)
    [data.ts_np_in, data.ts_np_out] = TimestampsAlignOnOff(data.ts_np_in, data.ts_np_out);
end

% [sort_ts, sort_labels] = BehGoNogoTsAll(data);
% token = 'N';
% mask = sort_labels == upper(token) | sort_labels == lower(token);
% crop_ts = sort_ts(mask);
% crop_labels = sort_labels(mask);
% idx_same = find([0 == diff(crop_labels); false]);
% % orig_idx = find(mask);
% % gap_dur = 150; % longer than delay to stim, which is 100ms as of 2015/02/19
% 
% for i = 1:numel(idx_same)
%     fprintf('%c:%d ', crop_labels(idx_same(i)), crop_ts(idx_same(i)));
% %     % Different procedures for entry vs. exit
% %     if sort_labels(orig_idx(idx_same(i))) == upper(token)
% %         % Extra entry event: make corresponding exit
% %         new_ts = sort_ts(orig_idx(idx_same(i)-1)) + gap_dur;
% %         data.ts_np_out = sort([data.ts_np_out; new_ts]);
% %         fprintf('Added new corresponding event: %d\n', new_ts);
% %     else
% %         % Entry exit event: make corresponding entry
% %         new_ts = sort_ts(orig_idx(idx_same(i))) - gap_dur; % Might miss previous stim if not long enough for long RT trial
% %         data.ts_np_in = sort([data.ts_np_in; new_ts]);
% %         fprintf('Added new corresponding event: %d\n', new_ts);
% %     end
% end
% if numel(idx_same)
%     fprintf('\n');
% end
% 
% Possible attempts to get fancier...
%         if sort_labels(orig_idx(idx_same(i))) == sort_labels(orig_idx(idx_same(i))-1)
%             % See if the previous event was of the same type. If so, create a standard gap event. Eliminating may throw off other responses/etc
%             new_ts = sort_labels(orig_idx(idx_same(i))-1) + gap_dur;
%             data.ts_np_out = sort([data.ts_np_out; new_ts]);
%             fprintf('Added new entry for event type %c\n', token);
%         else
%             % Intervening events of different types
%             % Extra exit/missing entry, look for possible previous associated event onsets. If not present, make gap event
%             assoc_token = 'S';
%             prev_labels = sort_labels(orig_idx(idx_same(i)-1)+1:orig_idx(idx_same(i))-1);
%             if sum(pre_labels == assoc_token)
%                 fprintf('Intervening associated event');
%             else
%                 new_ts = sort_labels(orig_idx(idx_same(i))-1) + gap_dur;
%                 data.ts_np_out = sort([data.ts_np_out; new_ts]);
%                 fprintf('Added new entry for event type %c\n', token);
%             end
% %             last_assoc = find(prev_labels(end:-1:1) == upper(assoc_token));
% %             last_assoc_ts = sort_ts(orig_idx(idx_same(i)) - last_assoc + 1);
% %             new_ts = last_assoc_ts + gap_ms;
% %             data.ts_lick_in = [data.ts_lick_in(data.ts_lick_in < new_ts); new_ts; data.ts_lick_in(data.ts_lick_in > new_ts)];
% %             if numel(data.ts_lick_in) == numel(data.ts_lick_out)
% %                 fprintf('Fixed by adding needed ts on associated event\n');
% %             end
%         end
%         
%         
%         % See if the previous event was of the same type. If so, create a standard gap event. Eliminating may throw off other responses/etc
%         
% %         % However, appears that there usually is: USB bus overload?
% %         if sort_labels(orig_idx(idx_same(i))) == sort_labels(orig_idx(idx_same(i))-1)
% %             % Eliminate previous entry
% %             data.ts_np_in = data.ts_np_in(data.ts_np_in < sort_ts(orig_idx(idx_same(i))-1) & sort_ts(orig_idx(idx_same(i))-1) < data.ts_np_in);
% %             fprintf('Removed previous double event for %c\n', token);
% %         else
% %         end
%     else
%         % Exit event
%         if sort_labels(orig_idx(idx_same(i))) == sort_labels(orig_idx(idx_same(i))-1)
%             % See if the previous event was of the same type. If so, create a standard gap event. Eliminating may throw off other responses/etc
%             new_ts = sort_labels(orig_idx(idx_same(i))) - gap_dur;
%             data.ts_np_in = sort([data.ts_np_in; new_ts]);
%             fprintf('Added new entry for event type %c\n', token);
%         end
%     end
%    
% %     % However, appears that there usually is: USB bus overload?
% %     if lower(sort_labels(orig_idx(idx_same(i))-1)) == lower(token)
% %         if sort_labels(orig_idx(idx_same(1))) == lower(token)
% %             % Eliminate current exit
% %             data.ts_np_out = data.ts_np_out(data.ts_np_out < sort_ts(orig_idx(idx_same(i))) & sort_ts(orig_idx(idx_same(i))) < data.ts_np_out);
% %             fprintf('Removed index double event for %c\n', token);
% %         else
% %             fprintf('Error removing extra events\n');
% %         end
% %     else
% %         % Intervening events of different types                fprintf('Intervening event of different types\n');
% %         if 'S' == upper(sort_labels(orig_idx(idx_same(i))-1))
% %             % intervening Stimulus, add a "ts_np_in" just before this stim
% %         end
% % 
% %     end
% 
% end
% fprintf('\n');


%% Check for mismatches: Licks
% Will miss double drops
if numel(data.ts_lick_in) ~= numel(data.ts_lick_out)
    [data.ts_lick_in, data.ts_lick_out] = TimestampsAlignOnOff(data.ts_lick_in, data.ts_lick_out);
end

% token = 'L';
% mask = sort_labels == upper(token) | sort_labels == lower(token);
% crop_ts = sort_ts(mask);
% crop_labels = sort_labels(mask);
% idx_same = find([0 == diff(crop_labels); false]);
% % orig_idx = find(mask);
% % gap_dur = 150; % longer than delay to stim, which is 100ms as of 2015/02/19
% 
% for i = 1:numel(idx_same)
%     fprintf('%c:%d ', crop_labels(idx_same(i)), crop_ts(idx_same(i)));
% %     % Different procedures for entry vs. exit
% %     if sort_labels(orig_idx(idx_same(i))) == upper(token)
% %         % Extra entry event: make corresponding exit
% %         new_ts = sort_ts(orig_idx(idx_same(i)-1)) + gap_dur;
% %         data.ts_lick_out = sort([data.ts_lick_out; new_ts]);
% %         fprintf('Added new corresponding event: %d\n', new_ts);
% %     else
% %         % Entry exit event: make corresponding entry
% %         new_ts = sort_ts(orig_idx(idx_same(i))) - gap_dur; % Might miss previous stim if not long enough for long RT trial
% %         data.ts_lick_in = sort([data.ts_lick_in; new_ts]);
% %         fprintf('Added new corresponding event: %d\n', new_ts);
% %     end
% end
% if numel(idx_same)
%     fprintf('\n');
% end

% %% Check for remaining mismatches: Licks
% if numel(data.ts_lick_in) ~= numel(data.ts_lick_out)
%     fprintf('*Diff lick Ins=%4d vs.=Outs %4d*\n', numel(data.ts_lick_in), numel(data.ts_lick_out));
%     % If still have error counts:
%     if numel(data.ts_lick_in) == numel(data.ts_lick_out)
%         fprintf('Discrepancy resolved by eliminating double counted/identical events.\n');
%     else
%         % Hunt for remaining mismatches by looking for double events
%         [sort_ts, sort_labels] = BehGoNogoTsAll(data);
%         token = 'L';
%         mask = sort_labels == upper(token) | sort_labels == lower(token);
%         crop_ts = sort_ts(mask);
%         crop_labels = sort_labels(mask);
%         idx_same = find([false; 0 == diff(crop_labels)]);
%         orig_idx = find(mask);
%         
%         fprintf('Errant timestamps: ');
%         for i = 1:numel(idx_same)
%             fprintf('%c:%d ', crop_labels(idx_same(i)), crop_ts(idx_same(i)));
%             % See if there was an intervening event of the same type
%             if lower(sort_labels(orig_idx(idx_same(i))-1)) == lower(token)
%                 % Eliminate the timestamp if there were no intervening other events. 
%                 % However, appears that there usually is: USB bus overload?
%                 if sort_labels(orig_idx(idx_same(i))) == upper(token)
%                     data.ts_lick_in = data.ts_lick_in(data.ts_lick_in < sort_ts(orig_idx(idx_same(i))) & sort_ts(orig_idx(idx_same(i))) < data.ts_lick_in);
%                     fprintf('Removed intervening events\n');
%                 elseif sort_labels(orig_idx(idx_same(1))) == lower(token)
%                     data.ts_lick_out = data.ts_lick_out(data.ts_lick_out < sort_ts(orig_idx(idx_same(i))) & sort_ts(orig_idx(idx_same(i))) < data.ts_lick_out);
%                     fprintf('Removed intervening events\n');
%                 else
%                     fprintf('Error removing extra events\n');
%                 end
%             else
%                 % Intervening events of different types
%                 fprintf('Intervening event of different types\n');
%                 if lower(token) == sort_labels(orig_idx(idx_same(i)))
%                     % Extra exit/missing entry, look for possible previous associated event onset and create appropriate event before
%                     assoc_token = 'R';
%                     gap_ms = 100;
%                     prev_labels = sort_labels(orig_idx(idx_same(i)-1):orig_idx(idx_same(i)));
%                     last_assoc = find(prev_labels(end:-1:1) == upper(assoc_token));
%                     last_assoc_ts = sort_ts(orig_idx(idx_same(i)) - last_assoc + 1);
%                     new_ts = last_assoc_ts + gap_ms;
%                     data.ts_lick_in = [data.ts_lick_in(data.ts_lick_in < new_ts); new_ts; data.ts_lick_in(data.ts_lick_in > new_ts)];
%                     if numel(data.ts_lick_in) == numel(data.ts_lick_out)
%                         fprintf('Fixed by adding needed ts on associated event\n');
%                     end
%                 elseif upper(token) == sort_labels(orig_idx(idx_same(i)))
%                     % Extra entry/Missing exit
%                 else
%                     fprintf('Missing unexpected token\n');
%                 end
%             end
%         end
%         fprintf('\n');
%     end
% end

% x = data.ts_np_in;
% y = data.ts_np_out;
% clf; hold on;
% plot(x(x>y), y(x>y), 'r.')
% plot(x(x<y), y(x<y), 'b.')
% plot(x(x==y), y(x==y), 'k.')
% axis square
% min_val = min([x(:); y(:)]);
% max_val = max([x(:); y(:)]);
% line([min_val, max_val], [min_val, max_val]);
% sum(diff(x)==0)
% sum(diff(y)==0)


%% Check for mismatches: Stims
[data.ts_stim_on, data.ts_stim_off] = TimestampsAlignOnOff(data.ts_stim_on, data.ts_stim_off);

% token = 'S';
% mask = sort_labels == upper(token) | sort_labels == lower(token);
% crop_ts = sort_ts(mask);
% crop_labels = sort_labels(mask);
% idx_same = find([0 == diff(crop_labels); false]);
% % orig_idx = find(mask);
% % gap_dur = 150; % longer than delay to stim, which is 100ms as of 2015/02/19
% 
% % data.ts_stim_off = data.ts_lick_out(data.ts_lick_out >= data.ts_lick_in(1));
% % data.ts_stim_on = data.ts_lick_in(data.ts_lick_in <= data.ts_lick_out(end));
% 
% 
% for i = 1:numel(idx_same)
%     fprintf('%c:%d ', crop_labels(idx_same(i)), crop_ts(idx_same(i)));
% %     % Different procedures for entry vs. exit
% %     if sort_labels(orig_idx(idx_same(i))) == upper(token)
% %         % Extra entry event: make corresponding exit
% %         new_ts = sort_ts(orig_idx(idx_same(i)-1)) + gap_dur;
% % %         data.ts_stim_off = sort([data.ts_stim_off; new_ts]);
% %         fprintf('Added new corresponding event: %d\n', new_ts);
% %     else
% %         % Entry exit event: make corresponding entry
% %         new_ts = sort_ts(orig_idx(idx_same(i))) - gap_dur; % Might miss previous stim if not long enough for long RT trial
% % %         data.ts_stim_on = sort([data.ts_stim_on; new_ts]);
% %         fprintf('Added new corresponding event: %d\n', new_ts);
% %     end
% end
% if numel(idx_same)
%     fprintf('\n');
% end


% %% Check for remaining mismatches: stim_class, stim_id, response, outcome
% % ts_stim_on is likely 1 less than stim_class & stim_id due to preparation of next trial
% if numel(data.stim_class) == numel(data.ts_stim_on) + 1
%     data.stim_class = data.stim_class(1:end-1); % data.stim_class is likely 1 longer than stim since it also stores the expected upcoming stimulus. This doesn't seem to throw off this indexing surprisingly
%     data.stim_id = data.stim_id(1:end-1); % data.stim_id is likely 1 longer than stim since it also stores the expected upcoming stimulus. This doesn't seem to throw off this indexing surprisingly
% end
% 
% if numel(data.ts_stim_on) ~= numel(data.stim_class) || numel(data.ts_stim_on) ~= numel(data.stim_id) || numel(data.response) ~= numel(data.stim_class) || numel(data.ts_stim_on) ~= numel(data.outcome) 
%     fprintf('Mismatched trial data\n');
% end


%% Early prep for early files
% For early files that did not have MT limit recorded
if ~isfield(data, 'MaxMT')
    data.MaxMT = NaN;
end

% For early files that did not have PerGoStim recorded
if ~isfield(data, 'ProbGoStim')
    if isfield(data, 'PerGoStim')
        data.ProbGoStim = data.PerGoStim;
    else
        data.ProbGoStim = 1;
    end
end

% For early files that did not have stim_id recorded
if ~isfield(data, 'stim_id') || isempty(data.stim_id)
    data.stim_id = data.stim_class;
end

%% Trial on/off mismatches?
if ~isfield(data, 'ts_trial_on')
    fprintf('No trial_on field, early file.\n');
    if isfield(data, 'MsStimDelay')
        margin = data.MsStimDelay;
    else
        margin = 1; % Should be earlier than stim in order to account for things that may happen before stim, like opto? Most files ~1 sec, will use 1ms for now given free trials
    end
    data.ts_trial_off = data.ts_stim_off + 1; % Rather arbitrary, but for free stim possibility needs to be immediate
    % Ideally needs to be matched to with off to ensure that not overlapping trials
    % But can not overlap with off until align--although stim on and off already aligned so ok in this case
    temp_on = data.ts_stim_on - margin; % Pre stim period gets shortened for free stim trials, so needs to be immediate then
    idx_overlap = find(temp_on < [0, data.ts_trial_off(1:end-1)]);
    temp_on(idx_overlap) = data.ts_trial_off(idx_overlap - 1)+1;
    data.ts_trial_on = temp_on; % Pre stim period gets shortened for free stim trials, so needs to be immediate then
end
[data.ts_trial_on, data.ts_trial_off] = TimestampsAlignOnOff(data.ts_trial_on, data.ts_trial_off);


% if numel(data.ts_trial_on) < numel(data.ts_trial_off)
%     fprintf('Mismatch between ts_trial_on and ts_trial_off: Not enough trial_ons. ');
%     % First look for early free stim trials: stim and trial off but not on
%     field_more_after = 'ts_trial_off';
%     field_less_before = 'ts_trial_on';
%     mask_more = false(size(data.(field_more_after)));
%     ts_more = data.(field_more_after);
%     ts_more = [0; ts_more];
%     for i_more = 1:numel(mask_more)
%         if sum((ts_more(i_more) <= data.(field_less_before)) & (data.(field_less_before) < ts_more(i_more+1)))
%             mask_more(i_more) = true;
%         end
%     end
%     ts_less = nan(size(mask_more));
%     ts_less(mask_more) = data.(field_less_before);
%     margin = median(ts_more([false; mask_more]) - ts_less(mask_more));
%     ts_less(isnan(ts_less)) = data.(field_more_after)(~mask_more) - margin;
%     data.(field_less_before) = ts_less;
%     mismatch = true;
% end
% % if numel(data.ts_trial_on) < numel(data.ts_trial_off)
% %     fprintf('Mismatch between ts_trial_on and ts_trial_off: eliminating trial offs\n');
% %     field_more = 'ts_trial_off';
% %     field_less = 'ts_trial_on';
% %     temp_ts = [0; data.(field_more)];
% %     mask = false(size(temp_ts));
% %     for i_ts = 2:numel(temp_ts)
% %         if sum(temp_ts(i_ts - 1) <= data.(field_less) & data.(field_less) <= temp_ts(i_ts))
% %             mask(i_ts-1) = true;
% %         end
% %     end
% % %     data.(field_more) = data.(field_more)(mask);
% % end
% 
% if numel(data.ts_trial_on) > numel(data.ts_trial_off)
%     fprintf('Mismatch between ts_trial_on and ts_trial_off: Inserting trial offs\n');
%     % Add trial off if missing for a trial on
%     field_more = 'ts_trial_on';
%     field_less = 'ts_trial_off';
%     mask = false(size(data.(field_more)));
%     temp_ts = [data.(field_more); inf];
%     for i_ts = 1:numel(temp_ts)-1
%         if sum(temp_ts(i_ts) <= data.(field_less) & data.(field_less) <= temp_ts(i_ts + 1))
%             mask(i_ts) = true;
%         else
%             % Insert a trial off
%             temp_trial = temp_ts(i_ts + 1) - 1;
%             data.(field_less) = sort([data.(field_less); temp_trial]);
%         end
%     end
% end


%% Other possible mismatches
if numel(data.stim_class) ~= numel(data.stim_id)
    fprintf('Mismatch between stim_class and stim_id\n');
    mismatch = true;
end
if numel(data.response) ~= numel(data.outcome)
    fprintf('Mismatch between response and outcome\n');
    mismatch = true;
end
if (numel(data.ts_stim_on) ~= numel(data.stim_class)) || (numel(data.ts_stim_on) ~= numel(data.stim_id))
    fprintf('Mismatch between ts_stim_on and stim_class or stim_id\n');
    mismatch = true;
end

% Too many trials > stims?
if numel(data.ts_trial_on) > numel(data.ts_stim_on)
    fprintf('Mismatch between ts_stim_on and ts_trial_on: Too many trials\n');
    % Eliminate trials that do not have a ts_stim_on -- due to being interrupted by free rewards
    mask_trial = false(size(data.ts_trial_on));
    for i_trial = 1:numel(data.ts_trial_on)
        if sum((data.ts_trial_on(i_trial) <= data.ts_stim_on) & (data.ts_stim_on <= data.ts_trial_off(i_trial)))
            mask_trial(i_trial) = true;
        end
    end
    data.ts_trial_on = data.ts_trial_on(mask_trial);
    data.ts_trial_off = data.ts_trial_off(mask_trial);
%     data.ts_iti_end = data.ts_iti_end(mask_trial);
%     data.all_iti = data.ts_iti_end(mask_trial);
%     if (numel(data.ts_stim_on) ~= numel(data.ts_trial_on))
        mismatch = true;
%     end
end

% Too many stims > trials?
if numel(data.ts_trial_on) < numel(data.ts_stim_on)
    fprintf('Mismatch between ts_stim_on and ts_trial_on: Not enough trials.\n ');
    % First look for early free stim trials: stim and trial off but not on
    if numel(data.ts_stim_on) == numel(data.ts_trial_off)
        fprintf('stim_on == trial_off, missing due to free stims in early files. ');
        field_more_after = 'ts_trial_off';
        field_less_before = 'ts_trial_on';
        mask_more = false(size(data.(field_more_after)));
        ts_more = data.(field_more_after);
        ts_more = [0; ts_more];
        for i_more = 1:numel(mask_more)
            if sum((ts_more(i_more) <= data.(field_less_before)) & (data.(field_less_before) < ts_more(i_more+1)))
                mask_more(i_more) = true;
            end
        end
        ts_less = nan(size(mask_more));
        ts_less(mask_more) = data.(field_less_before);
        margin = median(ts_more([false; mask_more]) - ts_less(mask_more));
        ts_less(isnan(ts_less)) = data.(field_more_after)(~mask_more) - margin;
        data.(field_less_before) = ts_less;
    end
    % Check if any more mismatches
    if numel(data.ts_trial_on) < numel(data.ts_stim_on)
        fprintf('Mismatch remains after accounting for potential free rewards.\n');
    end
    % Add trial on for trials that have stim but no trial, e.g. 7331-20170228-145716
    [data.ts_trial_on, data.ts_stim_on] = TimestampsAlignOnOff(data.ts_trial_on, data.ts_stim_on);
%     [data.ts_stim_off, data.ts_trial_off] = TimestampsAlignOnOff(data.ts_stim_off, data.ts_trial_off);
    % Match trials off for on
    [data.ts_trial_on, data.ts_trial_off] = TimestampsAlignOnOff(data.ts_trial_on, data.ts_trial_off);

%     field_more_after = 'ts_stim_on';
%     field_less_before = 'ts_trial_on';
%     mask_more = false(size(data.(field_more_after)));
%     ts_more = data.(field_more_after);
%     ts_more = [0; ts_more(:)];
%     for i_more = 1:numel(mask_more)
%         if sum((ts_more(i_more) <= data.(field_less_before)) & (data.(field_less_before) < ts_more(i_more+1)))
%             mask_more(i_more) = true;
%         end
%     end
%     ts_less = nan(size(mask_more));
%     ts_less(mask_more) = data.(field_less_before);
%     ts_less(isnan(ts_less)) = data.(field_more_after)(~mask_more) - margin;
%     fprintf('Added %d trials before stims.\n', sum(~mask_more));
    mismatch = true;
end

if (numel(data.ts_stim_on) ~= numel(data.response)) || (numel(data.ts_stim_on) ~= numel(data.outcome))
    fprintf('Mismatch between ts_stim_on and response or outcome: ');
    % see if this is resolved by the free rewards
    if (numel(data.ts_stim_on) == numel(data.response) + numel(data.ts_free_rwd))
        fprintf('Accounted for by free rewards\n');
        [vals, mask_stim, mask_rwd] = intersect(data.ts_stim_on, data.ts_free_rwd);
        if numel(vals) ~= numel(data.ts_free_rwd)
            fprintf('Only found %d of %d free rewards in ts_stim_on, may have errors\n', numel(vals), numel(data.ts_free_rwd));
        end
        mask_trial = true(size(data.ts_stim_on));
        mask_trial(mask_stim) = false;
        
        temp_response = nan(size(mask_trial));
        temp_response(mask_trial) = data.response;
        data.response = temp_response;
        
        temp_outcome = nan(size(mask_trial));
        temp_outcome(mask_trial) = data.outcome;
        data.outcome = temp_outcome;
    elseif numel(data.response) == numel(data.ts_stim_on) - 1
        % Check for unfinished trial at the end of the session
        % Can confirm this by looking at the ordered behavioral log file (.beh)
        % And or by looking at ts_end and seeing if it is too close to the stimulus onset
        if ((data.ts_end(1) - data.ts_stim_on(end)) < data.MaxMT) || (isfield(data, 'MsPost') && (data.ts_end(1) - data.ts_stim_on(end)) < data.MsPost)
            fprintf('Possible unfinished trial at end of session.\n');
            % Note that this is a rough calculation assuming the Arduino is not delayed in evaluating the end of the trial
            % And that a trial is not missing earlierL: Flag mismatch just in case
            data.response(end+1) = 'Q';
            data.outcome(end+1) = 'Q';
            mismatch = true; % Screen for possible mismatches just in case

            min_trials = numel(data.response);
            mismatch = find((...
                ((data.stim_class(1:min_trials) == 'G' | data.stim_class(1:min_trials) == 'P')& (~isnan(data.outcome(1:min_trials)) & ~(data.outcome(1:min_trials) == 'H' | data.outcome(1:min_trials) == 'X' | data.outcome(1:min_trials) == 'M' | data.outcome(1:min_trials) == 'Q' | data.outcome(1:min_trials) == 'E'))) | ...
                ((data.stim_class(1:min_trials) ~= 'G' & data.stim_class(1:min_trials) ~= 'P') & (~isnan(data.outcome(1:min_trials)) &  (data.outcome(1:min_trials) == 'H' | data.outcome(1:min_trials) == 'M')))));
            if isempty(mismatch)
                % then mismatch was at the end
            else
                mismatch= true;
            end
        end
    elseif numel(data.response) == numel(data.ts_stim_on) + 1
        % Extra exit/quit response at end of session?
        % Can confirm this by looking at the ordered behavioral log file (.beh)
        if data.response(end) == 'E' && data.outcome(end) == 'E'
            fprintf('Extra unfinished trial at end of session.\n');
            data.response = data.response(1:end-1);
            data.outcome = data.outcome(1:end-1);
        else
            fprintf('Unconfirmed unfinished trial at end of session, check log.\n');
            data.response = data.response(1:end-1);
            data.outcome = data.outcome(1:end-1);
        end
    else
        fprintf('Not resolved by free rewards\n');
        mismatch = true;
    end
end

%% Convert stim & response & outcome to row variables: were cols in early files
data.stim_class = data.stim_class(:)';
data.stim_id = data.stim_id(:)';
data.response = data.response(:)';
data.outcome = data.outcome(:)';

%% Mismatches: Above flagged for miscounts but will also look for class/outcome mismatch/errors
min_trials = min(numel(data.stim_class), numel(data.outcome));  % Exclude last trial since may have X'ed out, which would be flagged for Go trials unfortunately
if ~mismatch
    if numel(find(( ...
        (data.stim_class(1:min_trials) == 'G' | data.stim_class(1:min_trials) == 'P') & ...
        ~isnan(data.outcome(1:min_trials)) & ...
        ~(data.outcome(1:min_trials) == 'H' | data.outcome(1:min_trials) == 'X' | data.outcome(1:min_trials) == 'M' | data.outcome(1:min_trials) == 'Q'  | data.outcome(1:min_trials) == 'E') ...
        ) | ( ...
        (data.stim_class(1:min_trials) ~= 'G' & data.stim_class(1:min_trials) ~= 'P') & ...
        ~isnan(data.outcome(1:min_trials)) & ...
        (data.outcome(1:min_trials) == 'H' | data.outcome(1:min_trials) == 'X' | data.outcome(1:min_trials) == 'M') ...
        )));
            mismatch = 1;
    end
end

if mismatch
    % Likely dropped a packet somewhere, can try to insert if identify problematic trial
    % ID by mismatched stim_class vs. outcome
    % char([data.stim_class(mismatch(1)), data.stim_id(mismatch(1)), data.response(mismatch(1)), data.outcome(mismatch(1))])
    mismatch = find((...
        (data.stim_class(1:min_trials) == 'G' & (~isnan(data.outcome(1:min_trials)) & ~(data.outcome(1:min_trials) == 'H' | data.outcome(1:min_trials) == 'X' | data.outcome(1:min_trials) == 'M' | data.outcome(1:min_trials) == 'E'))) | ...
        (data.stim_class(1:min_trials) ~= 'G' & (~isnan(data.outcome(1:min_trials)) &  (data.outcome(1:min_trials) == 'H' | data.outcome(1:min_trials) == 'X' | data.outcome(1:min_trials) == 'M')))));
    if isempty(mismatch)
        % then mismatch was at the end
        mismatch = min_trials + 1;
    end
    fprintf('First mismatch around trial %d', mismatch(1));
    if mismatch(1) < numel(data.ts_stim_on)
        fprintf(', ts_stim_on %d\n', data.ts_stim_on(mismatch(1)));
    else
        fprintf(', after last ts_stim_on at %d\n', data.ts_stim_on(end));
        if numel(data.response) == numel(data.stim_class) - 1
            data.response = [data.response 'Q'];  % end of session
            data.outcome = [data.outcome 'Q'];  % end of session
        end
    end
    fprintf('\n');
    idx = mismatch(1);
    for idx_trial = max(idx-3,1):min(idx+3, numel(data.ts_stim_on))
%     for idx_trial = mismatch
       fprintf('%d ', data.ts_stim_on(idx_trial));
       fprintf('%c ', data.stim_class(idx_trial));
       fprintf('%c ', data.stim_id(idx_trial));
       fprintf('%c ', data.response(idx_trial));
       fprintf('%c ', data.outcome(idx_trial));
       fprintf('\n');
    end
    fprintf('Inserting extra:\n');
    if numel(data.stim_class) == numel(data.outcome)
        fprintf('Unclear what should be adjusted, ts_stim_on?\n');
    else
        if numel(data.outcome) < numel(data.stim_class)
            adjust = {'response', 'outcome'};
        elseif numel(data.outcome) > numel(data.stim_class)
            adjust = {'stim_class', 'stim_id'};
        end
        for i_adjust = 1:numel(adjust)
            field_name = adjust{i_adjust};
            fprintf('%s|', field_name);
            fprintf('%c,', data.(field_name)(1:mismatch-1));
            if mismatch <= numel(data.(field_name))
                fprintf('%c,', data.(field_name)(mismatch:end));
            end
            fprintf('\n');
        end
    end
    
    % Pull out temporary file and construct table based version of above printout
    if isnumeric(data.Subject)
        data.Subject = num2str(data.Subject);
    end
    temp_filename = [data.Subject '-' data.DateTimeStart '.beh'];
    if ~exist(temp_filename, 'file')
        temp_filename = [data.Subject '-' data.DateTimeStart '.tmp'];  % Earlier files
    end
    temp_data = BehGoNogoLoadTempFileTrials(temp_filename);
    
    fprintf('Temp file based adjustments\n');
    adjust = {'stim_class', 'stim_id', 'response', 'outcome', 'ts_stim_on', 'ts_stim_off'};
    for i_adjust = 1:numel(adjust)
        field_name = adjust{i_adjust};
        
        % Missing data from temp file trials?
        idx_missing = find(cellfun(@isempty, {temp_data.(field_name)}));
        if numel(idx_missing)
            fprintf('Missing %s for trial %d, ts_stim_on %d\n', field_name, idx_missing, temp_data(idx_missing).ts_stim_on);
        end
        fprintf('%s|', field_name);
        if ischar([temp_data.(field_name)])
            fprintf('%c,', temp_data.(field_name));
        else
            fprintf('%d,', temp_data.(field_name));
        end
        fprintf('\n');
    end
    fprintf('\n');
    
%     data.ts_stim_on = [temp_data.ts_stim_on];
%     data.ts_stim_off = [temp_data.ts_stim_off];
%     data.stim_class = [temp_data.stim_class];
%     data.stim_id = [temp_data.stim_id];
%     data.response = [temp_data.response];
%     data.outcome = [temp_data.outcome];
end


% %% Convert stim & response & outcome to row variables: were cols in early files
% data.stim_class = data.stim_class(:)';
% data.stim_id = data.stim_id(:)';
% data.response = data.response(:)';
% data.outcome = data.outcome(:)';
% 
% %% If can identify the error trial from beh file, can use following code to help manually correct
% % Remove extra trial
% ts = 6029440;
% idx = find(data.ts_stim_on == ts);
% labels = {'stim_class', 'stim_id', 'response', 'outcome'};
% for i_label = 1:numel(labels)
%     fprintf('%s|', labels{i_label});
%     fprintf('%c,', [data.(labels{i_label})(1:idx-1), data.(labels{i_label})(idx+1:end)]);
%     fprintf('\n');
% end
% fprintf('\n');
% 
% 
% %% If can identify the error trial from beh file, can use following code to help manually correct
% % Add extra trial
% ts = 1339602;
% temp_stim_class = 'N';
% temp_stim_id = 'H';
% temp_response = 'N';
% temp_outcome = 'R';
% 
% idx = find(data.ts_stim_on == ts);
% 
% labels = {'stim_class', 'stim_id', 'response', 'outcome'};
% for i_label = 1:numel(labels)
%     fprintf('%s|', labels{i_label});
%     fprintf('%c,', [data.(labels{i_label})(1:idx-1), eval(['temp_' labels{i_label}]), data.(labels{i_label})(idx:end)]);
%     fprintf('\n');
% end
% fprintf('\n');

%% Evaluate for possible trial mismatches
% % Is this a mismatch due to earlier files with free rewards?
% if numel(data.stim_class) ~= numel(data.stim_id)
%     fprintf('Mismatch between stim id & class info.\n');
% end
% 
% if numel(data.response) ~= numel(data.outcome)
%     fprintf('Mismatch between response & outcome info.\n');
% end
% 
% if numel(data.ts_stim_on) ~= numel(data.stim_class)
%     fprintf('Mismatch between stimuli and stim_class.\n');
%     1;
% end
% 
% if numel(data.ts_stim_on) ~= numel(data.response)
%     fprintf('Mismatch between stimuli & responses.\n');
%     if numel(data.response) == (numel(data.ts_stim_on) - numel(data.ts_free_rwd))
%         fprintf('Mismatch accounted for by free rwds.\n');
%         [val, idx_a, idx_b] = intersect(data.ts_stim_on, data.ts_free_rwd);
%         mask = true(size(data.ts_stim_on));
%         mask(idx_a) = false;
%         temp_data = nan(size(data.ts_stim_on));
%         temp_data(mask) = data.response;
%         data.response = temp_data;
%         temp_data(mask) = data.outcome;
%         data.outcome = temp_data;
%     end
% end
% 

% %% Align stims & trials
% % Num trials and stim_on may be different if there are free rewards
% % If so, copy old stim values to backups with free rewards and restrict otherwise to just trials
% if numel(crop_data.ts_trial) ~= numel(crop_data.ts_stim_on)
%     crop_data.stim_class_all = crop_data.stim_class;
%     crop_data.stim_id_all = crop_data.stim_id;
%     [ts_vals, trial_mask, stim_mask] = intersect(crop_data.ts_trial, crop_data.ts_stim_on);
%     crop_data.stim_class = crop_data.stim_class(stim_mask);
%     crop_data.stim_id = crop_data.stim_id(stim_mask);
% end

%% Take care of any mismatched NP/Lick In & Out: Operate on already copied crop_data
% MisMatch NP/Lick In & Out? likely due to when protocol started or stopped if multi-threaded or in middle or trial
% Eliminate orphaned/bookend trials
% crop_data.ts_np_out = data.ts_np_out(data.ts_np_out >= data.ts_np_in(1));
% crop_data.ts_np_in = data.ts_np_in(data.ts_np_in <= data.ts_np_out(end));
% % Check for remaining mismatches
% if length(data.ts_np_in) ~= length(data.ts_np_out)
%     fprintf('*Diff NP Ins=%4d vs.=Outs %4d*\n', length(data.ts_np_in), length(data.ts_np_out));
%     % Try to remove double counted Ins or Outs
%     data.ts_np_in = data.ts_np_in([true; diff(data.ts_np_in) > 0]);
%     data.ts_np_out = data.ts_np_out([true; diff(data.ts_np_out) > 0]);
%     % If still have error counts:
%     if length(data.ts_np_in) ~= length(data.ts_np_out)
%         % Hunt for remaining mismatches by looking for double events
%         temp_ts = [data.ts_np_in; data.ts_np_out];
%         temp_names = ['N' * ones(numel(data.ts_np_in), 1); 'n' * ones(numel(data.ts_np_out), 1)];
%         [sort_vals, sort_idxs] = sort(temp_ts);
%         idx_same = find(0 == diff(temp_names(sort_idxs)));
%         fprintf('Errant timestamps: ');
%         for i = 1:numel(idx_same)
%             fprintf('%d ', sort_vals(idx_same));
%         end
%         fprintf('\n');
% 
%         fprintf('Box: %d\t', data.Box);
%         fprintf('# Rewards = %d\n\n', length(data.ts_reward_on));
%         return; % Return for now %%%
%     end
% end

% % MisMatch NP/Lick In & Out? likely due to when protocol started or stopped if multi-threaded or in middle or trial
% % Eliminate orphaned/bookend trials
% crop_data.ts_np_in = crop_data.ts_np_in(crop_data.ts_np_in <= crop_data.ts_np_out(end));
% crop_data.ts_np_out = crop_data.ts_np_out(crop_data.ts_np_out >= crop_data.ts_np_in(1));
% if numel(crop_data.ts_np_in) ~= numel(crop_data.ts_np_out)
%     fprintf('*Diff np Ins=%4d vs.=Outs %4d*\n', length(crop_data.ts_np_in), length(crop_data.ts_np_out));
%     % Try to remove double counted Ins or Outs
%     if sum(diff(crop_data.ts_np_in) == 0)
%         fprintf('%d double counted np_ins removed\n', sum(diff(crop_data.ts_np_in) == 0));
%         crop_data.ts_np_in = crop_data.ts_np_in([true; diff(crop_data.ts_np_in) > 0]);
%     end
%     if sum(diff(crop_data.ts_np_out) == 0)
%         fprintf('%d double counted np_outs removed\n', sum(diff(crop_data.ts_np_out) == 0));
%         crop_data.ts_np_out = crop_data.ts_np_out([true; diff(crop_data.ts_np_out) > 0]);
%     end
%     % If still have error counts:
%     if numel(crop_data.ts_np_in) ~= numel(crop_data.ts_np_out)
%         % Hunt for remaining mismatches by looking for double same events
%         temp_ts = [crop_data.ts_np_in; crop_data.ts_np_out];
%         temp_names = ['i' * ones(numel(crop_data.ts_np_in), 1); 'o' * ones(numel(crop_data.ts_np_out), 1)];
%         [sort_vals, sort_idxs] = sort(temp_ts);
%         idx_same = find(0 == diff(temp_names(sort_idxs)))+1;
%         fprintf('Errant timestamps: ');
%         for i = 1:numel(idx_same)
%             fprintf('%c:%d ', temp_names(idx_same(i)), sort_vals(idx_same(i)));
%         end
%         fprintf('\n');
%         return; % Return for now %%%
%     end
% end
% 
% 
% % MisMatch NP/Lick In & Out? likely due to when protocol started or stopped if multi-threaded or in middle or trial
% % Eliminate orphaned/bookend trials
% crop_data.ts_lick_in = crop_data.ts_lick_in(crop_data.ts_lick_in <= crop_data.ts_lick_out(end));
% crop_data.ts_lick_out = crop_data.ts_lick_out(crop_data.ts_lick_out >= crop_data.ts_lick_in(1));
% if numel(crop_data.ts_lick_in) ~= numel(crop_data.ts_lick_out)
%     fprintf('*Diff lick Ins=%4d vs.=Outs %4d*\n', length(crop_data.ts_lick_in), length(crop_data.ts_lick_out));
%     % Try to remove double counted Ins or Outs
%     if sum(diff(crop_data.ts_lick_in) == 0)
%         fprintf('%d double counted lick_ins removed\n', sum(diff(crop_data.ts_lick_in) == 0));
%         crop_data.ts_lick_in = crop_data.ts_lick_in([true; diff(crop_data.ts_lick_in) > 0]);
%     end
%     if sum(diff(crop_data.ts_lick_out) == 0)
%         fprintf('%d double counted lick_outs removed\n', sum(diff(crop_data.ts_lick_out) == 0));
%         crop_data.ts_lick_out = crop_data.ts_lick_out([true; diff(crop_data.ts_lick_out) > 0]);
%     end
%     % If still have error counts:
%     if numel(crop_data.ts_lick_in) ~= numel(crop_data.ts_lick_out)
%         % Hunt for remaining mismatches by looking for double same events
%         temp_ts = [crop_data.ts_lick_in; crop_data.ts_lick_out];
%         temp_names = ['i' * ones(numel(crop_data.ts_lick_in), 1); 'o' * ones(numel(crop_data.ts_lick_out), 1)];
%         [sort_vals, sort_idxs] = sort(temp_ts);
%         idx_same = find(0 == diff(temp_names(sort_idxs)))+1;
%         fprintf('Errant timestamps: ');
%         for i = 1:numel(idx_same)
%             fprintf('%c:%d ', temp_names(idx_same(i)), sort_vals(idx_same(i)));
%         end
%         fprintf('\n');
%         return; % Return for now %%%
%     end
% end
% 

%% Realign vs. ts_start: If ts_start was recorded, subtract ts_start from ts_ variables
if isfield(data, 'ts_start')
    data.old_ts_start = data.ts_start; % need to preserve this so don't subtract it away before doing all subtractions
    if isfield(data, 'ts_end')
        data.old_ts_end = data.ts_end; % need to preserve this so don't subtract it away before doing all subtractions
    end
    field_names = fieldnames(data);
    for i_field = 1:numel(field_names)
        temp_name = field_names{i_field};
        if strncmp('ts_', temp_name', 3)
             data.(temp_name) = data.(temp_name)- data.old_ts_start;
        end
    end
end

%% Align structs
field_names = {'SwitchGoStimIDs', 'SwitchNogoStimIDs'};
for i_field = 1:numel(field_names)
    if ~isfield(data, field_names{i_field})
        data.(field_names{i_field}) = NaN;
    end
end

%% Change new fields to old if exist: 2017/02/23
if isfield(data, 'MsRTDelay')
    data.MinRT = data.MsRTDelay - data.MsStimDelay;
    data.MaxRT = data.MsRTDur;
end

%% Adapt few fields that evolved: 2017/02/22 (old -> new)
field_names = {
    'MsFluidDelay', 'MsReinfDelay';
    'MsTrialReinfDelay', 'MsReinfDelay';
    'MinRT', 'MsRTDelay';
    'MaxRT', 'MsRTDur';
};

for i_field = 1:size(field_names, 1)
    if isfield(data, field_names{i_field, 1}) && ~isfield(data, field_names{i_field, end})
        data.(field_names{i_field, end}) = data.(field_names{i_field, 1});
    end
end

% %% Add fields as empty if do not exist
% field_names = {
%     'MsGoDur'
%     'MsNogoDur'
% };
% 
% for i_field = 1:size(field_names, 1)
%     if ~isfield(data, field_names{i_field})
%         data.(field_names{i_field}) = [];
%     end
% end
