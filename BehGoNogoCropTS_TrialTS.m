function [crop_data] = BehGoNogoCropTS(data, crop_sec)

%% Determine boundary edges
crop_ms = crop_sec * 1e3;

if isfield(data, 'ts_start')
    crop_ms = crop_ms + double(data.ts_start);
%     data.old_ts_start = data.ts_start; % need to preserve this so don't subtract it away before doing all subtractions
end

% What if end is less than requested, need to modify "end"
if isfield(data, 'ts_end')
    if data.ts_end < crop_ms(end)
        fprintf('Session for subject %s, date %d ended at %d before desired crop end %d\n', data.Subject, data.DateTimeStart(1), data.ts_end, crop_ms(end));
        crop_ms(end) = data.ts_end;
    end
else
    fprintf('No ts_end for subject %s, date %d\n', data.Subject, data.DateTimeStart(1));
    max_ts = BehGoNogoMaxTS(data);
    crop_ms(end) = min(crop_ms(end), max_ts);
end
data.crop_ms = crop_ms;

%% Evaluate for possible trial mismatches
% Is this a mismatch due to earlier files with free rewards?
if numel(data.stim_class) ~= numel(data.stim_id)
    fprintf('Mismatch between stim id & class info.\n');
end

if numel(data.response) ~= numel(data.outcome)
    fprintf('Mismatch between response & outcome info.\n');
end

if numel(data.ts_stim_on) ~= numel(data.stim_class)
    fprintf('Mismatch between stimuli and stim_class.\n');
    1;
end

if numel(data.ts_stim_on) ~= numel(data.response)
    fprintf('Mismatch between stimuli & responses.\n');
    if numel(data.response) == (numel(data.ts_stim_on) - numel(data.ts_free_rwd))
        fprintf('Mismatch accounted for by free rwds.\n');
        [val, idx_a, idx_b] = intersect(data.ts_stim_on, data.ts_free_rwd);
        mask = true(size(data.ts_stim_on));
        mask(idx_a) = false;
        temp_data = nan(size(data.ts_stim_on));
        temp_data(mask) = data.response;
        data.response = temp_data;
        temp_data(mask) = data.outcome;
        data.outcome = temp_data;
    end
end

% %% Make a ts_trial timepoint, to only count stims that were elicited/not free rewards
% % trial_mask = ~ismember(data.ts_stim_on, data.ts_free_rwd);
% % data.ts_trial = data.ts_stim_on(trial_mask);
% data.ts_trial = data.ts_stim_on; % Change Clean file to account for free rewards 2015/03/03


%% Go through and crop each ts, but when get to ts_stim make sure to adjust trial arrays as well
crop_data = data;
field_names = fieldnames(data);
stim_field_names = {'stim_class', 'stim_id'};
trial_field_names = {'response', 'outcome'}; % also all_iti
for i_field = 1:numel(field_names)
    temp_field_name = field_names{i_field};
    if strncmp('ts_', temp_field_name, 3)
        mask = crop_ms(1) <= data.(temp_field_name) & data.(temp_field_name) <= crop_ms(end); % Capture both edges with <=
        crop_data.(temp_field_name) = data.(temp_field_name)(mask);
        if strcmp('ts_stim_on', temp_field_name)
            % Free rewards are not necessarily matched up for response, outcome, & all_iti
            for i_sub_field = 1:numel(stim_field_names)
                temp_name = stim_field_names{i_sub_field};
                if isfield(data, temp_name)
                    if numel(data.(temp_name)) == numel(mask)
                        crop_data.(temp_name) = data.(temp_name)(mask);
                    else
                        fprintf('Field %s does not have the right number of entries vs. %s for crop for subject %s, date %s\n', temp_name, temp_field_name, data.Subject, data.DateTimeStart(1:8));
                    end
                else
                    fprintf('Field %s does not exist for subject %s, date %d\n', temp_name, data.Subject, data.DateTimeStart(1));
                end
            end
        elseif strcmp('ts_trial', temp_field_name)
            % Free rewards are not necessarily matched up for response, outcome, & all_iti
            for i_sub_field = 1:numel(trial_field_names)
                temp_name = trial_field_names{i_sub_field};
                if isfield(data, temp_name)
                    if numel(data.(temp_name)) == numel(mask)
                        crop_data.(temp_name) = data.(temp_name)(mask);
                    else
                        fprintf('Field %s does not have the right number of entries vs. %s for crop for subject %s, date %s\n', temp_name, temp_field_name, data.Subject, data.DateTimeStart(1:8));
                        % Find mismatched stim_class/responses/outcomes/etc
                        min_trials = min([numel(data.ts_trial), numel(data.outcome), numel(data.response)]);
                        err_go = find(data.stim_class(1:min_trials) == 'G' & ~(data.outcome(1:min_trials) == 'H' | data.outcome(1:min_trials) == 'M'));
                        err_nogo = find(data.stim_class(1:min_trials) ~= 'G' & (data.outcome(1:min_trials) == 'H' | data.outcome(1:min_trials) == 'M'));
                        idx_mismatch = min([err_go(:); err_nogo(:)]);
                        fprintf('First mismatched trial = %d, time %d\n', idx_mismatch, data.ts_trial(idx_mismatch));
                        fprintf('Check results to insert\n');
                        ins_response = '?';
                        ins_outcome = '?';
                        corr_response = [data.response(1:idx_mismatch-1); ins_response; data.response(idx_mismatch:end)];
                        corr_outcome = [data.outcome(1:idx_mismatch-1); ins_outcome; data.outcome(idx_mismatch:end)];
                        fprintf('stim_class|');
                        fprintf('%c,', data.stim_class);
                        fprintf('\n');
                        fprintf('response|');
                        fprintf('%c,', corr_response);
                        fprintf('\n');
                        fprintf('outcome|');
                        fprintf('%c,', corr_outcome);
                        fprintf('\n');
                    end
                else
                    fprintf('Field %s does not exist for subject %s, date %d\n', temp_name, data.Subject, data.DateTimeStart(1));
                end
            end
        end
    end
end

%% Align stims & trials
% Num trials and stim_on may be different if there are free rewards
% If so, copy old stim values to backups with free rewards and restrict otherwise to just trials
if numel(crop_data.ts_trial) ~= numel(crop_data.ts_stim_on)
    crop_data.stim_class_all = crop_data.stim_class;
    crop_data.stim_id_all = crop_data.stim_id;
    [ts_vals, trial_mask, stim_mask] = intersect(crop_data.ts_trial, crop_data.ts_stim_on);
    crop_data.stim_class = crop_data.stim_class(stim_mask);
    crop_data.stim_id = crop_data.stim_id(stim_mask);
end

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

% MisMatch NP/Lick In & Out? likely due to when protocol started or stopped if multi-threaded or in middle or trial
% Eliminate orphaned/bookend trials
crop_data.ts_np_in = crop_data.ts_np_in(crop_data.ts_np_in <= crop_data.ts_np_out(end));
crop_data.ts_np_out = crop_data.ts_np_out(crop_data.ts_np_out >= crop_data.ts_np_in(1));
if numel(crop_data.ts_np_in) ~= numel(crop_data.ts_np_out)
    fprintf('*Diff np Ins=%4d vs.=Outs %4d*\n', length(crop_data.ts_np_in), length(crop_data.ts_np_out));
    % Try to remove double counted Ins or Outs
    if sum(diff(crop_data.ts_np_in) == 0)
        fprintf('%d double counted np_ins removed\n', sum(diff(crop_data.ts_np_in) == 0));
        crop_data.ts_np_in = crop_data.ts_np_in([true; diff(crop_data.ts_np_in) > 0]);
    end
    if sum(diff(crop_data.ts_np_out) == 0)
        fprintf('%d double counted np_outs removed\n', sum(diff(crop_data.ts_np_out) == 0));
        crop_data.ts_np_out = crop_data.ts_np_out([true; diff(crop_data.ts_np_out) > 0]);
    end
    % If still have error counts:
    if numel(crop_data.ts_np_in) ~= numel(crop_data.ts_np_out)
        % Hunt for remaining mismatches by looking for double same events
        temp_ts = [crop_data.ts_np_in; crop_data.ts_np_out];
        temp_names = ['i' * ones(numel(crop_data.ts_np_in), 1); 'o' * ones(numel(crop_data.ts_np_out), 1)];
        [sort_vals, sort_idxs] = sort(temp_ts);
        idx_same = find(0 == diff(temp_names(sort_idxs)))+1;
        fprintf('Errant timestamps: ');
        for i = 1:numel(idx_same)
            fprintf('%c:%d ', temp_names(idx_same(i)), sort_vals(idx_same(i)));
        end
        fprintf('\n');
        return; % Return for now %%%
    end
end


% MisMatch NP/Lick In & Out? likely due to when protocol started or stopped if multi-threaded or in middle or trial
% Eliminate orphaned/bookend trials
crop_data.ts_lick_in = crop_data.ts_lick_in(crop_data.ts_lick_in <= crop_data.ts_lick_out(end));
crop_data.ts_lick_out = crop_data.ts_lick_out(crop_data.ts_lick_out >= crop_data.ts_lick_in(1));
if numel(crop_data.ts_lick_in) ~= numel(crop_data.ts_lick_out)
    fprintf('*Diff lick Ins=%4d vs.=Outs %4d*\n', length(crop_data.ts_lick_in), length(crop_data.ts_lick_out));
    % Try to remove double counted Ins or Outs
    if sum(diff(crop_data.ts_lick_in) == 0)
        fprintf('%d double counted lick_ins removed\n', sum(diff(crop_data.ts_lick_in) == 0));
        crop_data.ts_lick_in = crop_data.ts_lick_in([true; diff(crop_data.ts_lick_in) > 0]);
    end
    if sum(diff(crop_data.ts_lick_out) == 0)
        fprintf('%d double counted lick_outs removed\n', sum(diff(crop_data.ts_lick_out) == 0));
        crop_data.ts_lick_out = crop_data.ts_lick_out([true; diff(crop_data.ts_lick_out) > 0]);
    end
    % If still have error counts:
    if numel(crop_data.ts_lick_in) ~= numel(crop_data.ts_lick_out)
        % Hunt for remaining mismatches by looking for double same events
        temp_ts = [crop_data.ts_lick_in; crop_data.ts_lick_out];
        temp_names = ['i' * ones(numel(crop_data.ts_lick_in), 1); 'o' * ones(numel(crop_data.ts_lick_out), 1)];
        [sort_vals, sort_idxs] = sort(temp_ts);
        idx_same = find(0 == diff(temp_names(sort_idxs)))+1;
        fprintf('Errant timestamps: ');
        for i = 1:numel(idx_same)
            fprintf('%c:%d ', temp_names(idx_same(i)), sort_vals(idx_same(i)));
        end
        fprintf('\n');
        return; % Return for now %%%
    end
end

