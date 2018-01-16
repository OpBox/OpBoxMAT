function [summary] = BehGoNogoOutcomesScalar(data)

dur_sec = diff(data.crop_ms);

if ~isempty(data)
    % NP Rate
    summary.np_per_sec = numel(data.ts_lick_in) / dur_sec;
    
    % Median NP duration for all trial types
    % May be off by 1 due to cropping effects, if edge falls between NPin & NPout
    if numel(data.ts_np_out) > numel(data.ts_np_in)
        summary.med_np_dur = median(data.ts_np_out(2:end) - data.ts_np_in);
    elseif numel(data.ts_np_out) < numel(data.ts_np_in)
        summary.med_np_dur = median(data.ts_np_out - data.ts_np_in(1:end-1));
    else
        summary.med_np_dur = median(data.ts_np_out - data.ts_np_in);
    end
%     summary.med_np_dur = median(data.ts_np_out(1:min(numel(data.ts_np_in), numel(data.ts_np_out))) - data.ts_np_in(1:min(numel(data.ts_np_in), numel(data.ts_np_out))));
    
    % Time to first NP
    if ~isempty(data.ts_np_in)
        summary.time_first_np = data.ts_np_in(1);
    else
        summary.time_first_np = NaN;
    end
    
    % Lick Rate
    summary.lick_per_sec = numel(data.ts_lick_in) / dur_sec;
    
    % Median Lick duration for all trial types
    % Probably not reliable due to rapid relicks
    summary.med_lick_dur = median(data.ts_lick_out(1:min(numel(data.ts_lick_in), numel(data.ts_lick_out))) - data.ts_lick_in(1:min(numel(data.ts_lick_in), numel(data.ts_lick_out))));
%     summary.med_lick_dur = median(data.ts_lick_out - data.ts_lick_in);
    
    % Time to first Lick
    if ~isempty(data.ts_lick_in)
        summary.time_first_lick = data.ts_lick_in(1);
    else
        summary.time_first_lick = NaN;
    end

    % Reward Rate
    summary.rwd_per_sec = numel(data.ts_reward_on) / dur_sec;

    % Accuracy
    trial_mask = ~ismember(data.ts_stim_on, data.ts_free_rwd);
    data.acc_by_trials = (data.stim_class(trial_mask) == 'G' & data.response(trial_mask) == 'L') | (data.stim_class(trial_mask) == 'N' & data.response(trial_mask) ~= 'L');
    summary.acc = mean(data.acc_by_trials);
    
%     % Time/Trials to first Hit
%     hits = find(data.stim_class == 'G' & data.acc_by_trials);
%     summary.stims_first_hit = hits(1);
%     summary.time_first_hit = data.ts_stim_on(hits(1));
%     
%     % Time/Trials to first Correct Rejection
%     correct_rejections = find(data.stim_class == 'N' & data.acc_by_trials);
%     summary.nogo_stims_first_correct_rejection = sum(data.stim_class(1:correct_rejections(1)) == 'N');
%     summary.time_first_correct_rejection = data.ts_stim_on(correct_rejections(1));
    
    % Number of "switches": Only counts if started next block, not if reach criteria. Assuming only 1 Go Stim at a time
    stim_id_go = double(data.stim_id(data.stim_class == 'G'));
    summary.num_switches = sum(abs(diff(stim_id_go))>0);

    % Time/Trials to first "switch" criteria
    go_trials = find(data.stim_class == 'G');
    if ~isempty(go_trials)
        first_go_stimid = data.stim_id(go_trials(1));
    else
        first_go_stimid = [];
    end
    nogo_trials = find(data.stim_class == 'N');
    if ~isempty(nogo_trials)
        first_nogo_stimid = data.stim_id(nogo_trials(1));
    else
        first_nogo_stimid = [];
    end
    
    if ~isempty(first_go_stimid) && ~isempty(first_nogo_stimid)
        switch_trials = find((data.stim_class == 'G' & data.stim_id ~= first_go_stimid) | (data.stim_class == 'N' & data.stim_id ~= first_nogo_stimid));
    else
        switch_trials = [];
    end
    % FYI: will miss meeting criteria, but not performing first switch trial
    if ~isempty(switch_trials)
        summary.trial_crit = switch_trials(1)-1;
        summary.time_crit = data.ts_stim_on(summary.trial_crit); % change from ms to sec or min/etc?
    else
        summary.trial_crit = Inf;
        summary.time_crit = Inf;
    end

%     % Movement Times:
%     [sort_ts, sort_ids] = BehGoNogoSortTS(data);
% 	% Analyze by NPs so that can account for trials without stimuli
%     idx_npout = find(sort_ids == 'n');
%     % Find np's followed by Lick
%     np_lick_trials = false(size(idx_npout));
%     np_lick_trials(sort_ids(idx_npout + 1) == 'L') = true;
%     % MT: Has mixed responses of Lick and re-np
%     mt = sort_ts(idx_npout+1) - sort_ts(idx_npout);
%     mt = double(mt);
% 
%     % Movement time to Lick
%     summary.med_mt_lick = median(mt(np_lick_trials));
% 
%     % Movement time to re-NP
%     summary.med_mt_np = median(mt(~np_lick_trials));
% 
%     % Hit by stims
%     % NPDur by stims
%     % MT NP/Lick by stims

end
