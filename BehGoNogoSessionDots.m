function [data, per_stimid_lick, name_stim_ids, acc, med_npdur, med_lick] = BehGoNogoSessionDots(filename, crop_sec)

%% Load file
fprintf('Filename: %s\n', filename');
data = BehGoNogoLoadFile(filename);

if nargin == 2
    data = BehGoNogoCleanFile(data);
    if numel(crop_sec) == 1
        crop_sec = [0, crop_sec];
    end
    data = BehGoNogoCropTS(data, crop_sec);
end

data = BehGoNogoCleanFile(data);
if isempty(data) || ~isfield(data, 'ts_stim_on') || isempty(data.ts_stim_on)
    fprintf('Empty file/no stimulus onsets\n');
    % need to create empty fields so as not to crash calling function?
    return;
end

%% Print basic file info
fprintf('Protocol: %s\t', data.Protocol);
fprintf('Box: %d\t', data.Box);
fprintf('Dur: %d min', round(data.dur/1e3/60));
fprintf('\n');
fprintf('%% Go Stim: %d', data.ProbGoStim);
fprintf('   Go stim: %s', unique(char(data.stim_id(data.stim_class=='G'))));
fprintf('   Nogo stim: %s\n', unique(char(data.stim_id(data.stim_class=='N'))));
fprintf('# Stims = %d', length(data.ts_stim_on));
fprintf('   # Rewards = %d', length(data.ts_reward_on));
fprintf('   # Free = %d\n', length(data.ts_free_rwd));

%% Calc nosepoke & lick durations
if isempty(data.ts_np_in)
    fprintf('No nosepoke data, returning\n\n');
    return;
end

num_nps = numel(data.ts_np_in);
fprintf('# NPs = %d', num_nps);
rate_np = num_nps / data.dur;
fprintf('\tNP Rate: %.3f/sec -> %.3f/min', rate_np*1e3, rate_np*1e3*60);
fprintf('\n');
dur_nps = data.ts_np_out - data.ts_np_in;
dur_nps = double(dur_nps);
fprintf('NP Durs (ms):   ');
MedIQR_NoDec(dur_nps);
fprintf('Total NP time:  %.3f sec -> %.3f min\n', sum(dur_nps)/1e3, sum(dur_nps)/1e3/60);

num_licks = length(data.ts_lick_in);
fprintf('# Licks = %d', num_licks);
rate_lick = num_licks / data.dur;
fprintf('\tLick Rate: %.3f/sec -> %.3f/min', rate_lick*1e3, rate_lick*1e3*60);
fprintf('\n');
dur_licks = data.ts_lick_out - data.ts_lick_in;
dur_licks = double(dur_licks);
% Lick duration w/reward vs. w/out
fprintf('Lick Durs (ms): ');
MedIQR_NoDec(dur_licks);
fprintf('Total Lick time: %.3f sec -> %.3f min\n', sum(dur_licks)/1e3, sum(dur_licks)/1e3/60);

% %% Graph timestamps
% % Plots nosepoke times over hour
% clf;
% plot(double(data.ts_np_in-data.ts_np_in(1))/1e3/3600, '.')
% axis tight

% clf;
% PlotCDF(dur_nps);

% clf;
% PlotCDF(dur_licks);
% inter_licks = data.ts_lick_in(2:end) - data.ts_lick_out(1:end-1);
% inter_licks = double(inter_licks);
% PlotCDF(inter_licks);

% % Plot lick timepoints
% clf;
% hold on;
% h = plot(double(data.ts_lick_in)/1e3/60, 1:length(data.ts_lick_in), '.b');
% set(h, 'MarkerSize', 5);
% h= plot(double(data.ts_lick_out)/1e3/60, 1:length(data.ts_lick_out), '.r');
% set(h, 'MarkerSize', 5);
% axis tight;
% set(gca, 'YDir', 'reverse');
% title(filename);

% %% MT Empirical calculation for Accuracy
% % have to know "Hit" responses:
% % attempted to lick within required time frame, i.e. before MT expired
% % did not record this explicitly in early sessions
% % can compare MT for longest successful lick as max MT for that session
% % look for Lick preceeded by NPOut and followed by reward On
% 
% % Sort all timestamps and reorganize ids
% all_ts = [data.ts_np_out; data.ts_lick_in; data.ts_reward_on];
% all_ids = ['n' * ones(size(data.ts_np_out)); 'L' * ones(size(data.ts_lick_in)); 'F' * ones(size(data.ts_reward_on))];
% [sort_ts, idx_sort] = sort(all_ts);
% sort_ids = all_ids(idx_sort);
% sort_ts = [-1; sort_ts; sort_ts(end) + 1];
% sort_ids = ['X'; sort_ids; 'Z'];
% idx_lick = find(sort_ids == 'L');
% 
% seqs = [sort_ids(idx_lick-1), sort_ids(idx_lick), sort_ids(idx_lick+1)];
% mask = seqs(:,1) == 'n' & seqs(:,3) == 'F';
% reward_mt = sort_ts(idx_lick(mask)) - sort_ts(idx_lick(mask)-1);
% max_reward_mt = max(reward_mt);
% % hist(double(reward_mt), );
% % char([sort_ids(idx_lick-1), sort_ids(idx_lick), sort_ids(idx_lick+1)])
% fprintf('MaxMT = %4d ms\n', max_reward_mt);

%% Analyze Responses to Stimuli: Attempts to collect, RT, MT, ...
% Events are currently structured as timestamps
% Can anazlye by searching via for loop 1 by 1 (slow) or
% Can analyze by creating a string of chars for all events and searching for patterns
% ie. % of NPout preceded by stim of which are followed by lick or reward

% Sort all timestamps and reorganize ids (takes ~3ms at command line, <1ms as function)
[sort_ts, sort_ids] = BehGoNogoSortTS(data);

% % ACCOUNT FOR PROBLEMS W/FREE REWARDS
% % Subtract free rewards from data.ts_stim_on, stim_class, etc.
% % Can eliminate stims that are not preceded by npin & followed by npout -- more reliable sync
% % Could do this by finding timestamps that intersect between data.ts_stim_on & data.ts_free_rwd
% % But this seems to miss trials in filename = 'kCb-20140105-132919.txt'; there is no clear stim on at the time of free reward even though the total numbers add up...
% idx_stim = find(sort_ids == 'S');
% mask_stim_peri_np = sort_ids(idx_stim - 1) == 'N' & sort_ids(idx_stim + 1) == 'n';
% % [sort_ids(idx_stim-1), sort_ids(idx_stim), sort_ids(idx_stim+1)]
% % [sort_ts(idx_stim-1), sort_ts(idx_stim), sort_ts(idx_stim+1)]
% if sum(mask_stim_peri_np) < length(data.stim_class)
%     data.ts_stim_on = data.ts_stim_on(mask_stim_peri_np);
%     data.stim_class = data.stim_class(mask_stim_peri_np);
%     data.stim_id = data.stim_id(mask_stim_peri_np);
%     % need to remove from sort_ids & sort_ts as well
%     [sort_ts, sort_ids] = BehGoNogoSortTS(data);
% elseif length(data.stim_class) < sum(mask_stim_peri_np)
%     fprintf('Error!: Stim class likely not complete due to early protocols. Pulling running data dump info.\n');
%     %%% temporary hack for early sessions w/more than 1 stim per trial
%     % This info may not be saved in this way if the protocol becomes more reliable
%     flag = 'StimClass: ';
%     data.stim_class = StrFlagToLine_NumArray(file_char, flag);
%     data.stim_class = data.stim_class(mask_stim_peri_np); % data.stim_class is likely 1 longer than stim since it also stores the expected upcoming stimulus. This doesn't seem to throw off this indexing surprisingly
%     [sort_ts, sort_ids] = BehGoNogoSortTS(data);
% end


% Analyze by NPs so that can account for trials without stimuli
% Find np's preceded by stimulus and match to data from stims followed by NP out
idx_npout = find(sort_ids == 'n');
idx_stim = find(sort_ids == 'S');
data.np_stim_class = zeros(size(idx_npout));
data.np_stim_class(sort_ids(idx_npout - 1) == 'S') = data.stim_class(sort_ids(idx_stim+1) == 'n');
data.np_stim_id = zeros(size(idx_npout));
data.np_stim_id(sort_ids(idx_npout - 1) == 'S') = data.stim_id(sort_ids(idx_stim+1) == 'n');

% idx_stim = find(sort_ids == 'S');
% patterns = char(sort_ids([idx_stim-1, idx_stim, idx_stim+1]));
% [c, ia, ib] = intersect(patterns, 'NSN', 'rows');
% sort_ts([idx_stim(ia)-1, idx_stim(ia), idx_stim(ia)+1]);

% % RT: not so meaningful given fixed FP and trials without stim, but will pull out rt anyway
% rt = sort_ts(idx_npout) - sort_ts(idx_npout-1);
% rt = double(rt)/1e3;
% % fprintf('RT-Stim (sec): ');
% % mask = stim_trials > 0;
% % MedIQR(rt(mask));

% Find np's followed by Lick
np_lick_trials = zeros(size(idx_npout));
np_lick_trials(sort_ids(idx_npout + 1) == 'L') = 'L';
% MT: Has mixed responses of Lick and re-np
mt = sort_ts(idx_npout+1) - sort_ts(idx_npout);
mt = double(mt);
% fprintf('MT-Lick (sec): ');
% mask = lick_trials > 0;
% MedIQR(mt(mask));

% % "Choice" "Accuracy" by Stim Class
% per_gostim_lick = mean(lick_trials(stim_trials == 'G') > 0);
% per_nogostim_lick = mean(lick_trials(stim_trials == 'N') > 0);
% per_nostim_lick = mean(lick_trials(stim_trials<=0) > 0);
% fprintf('%%Lick|Go  Stim = %.2f\n', per_gostim_lick);
% fprintf('%%Lick|NogoStim = %.2f\n', per_nogostim_lick);
% fprintf('%%Lick|No  Stim = %.2f\n', per_nostim_lick);

% "Choice" "Accuracy" (Lick response) by Stim ID. Current version does not account for MT limit
name_stim_ids = unique(char(data.np_stim_id));
% name_stim_ids = ['LMH' 0];
per_stimid_lick = nan(1, length(name_stim_ids));
for i_id = 1:length(name_stim_ids)
    per_stimid_lick(i_id) = mean(np_lick_trials(data.np_stim_id == name_stim_ids(i_id)) == 'L');
    if name_stim_ids(i_id) == 0
        temp_id = '0';
    else
        temp_id = name_stim_ids(i_id);
    end
    fprintf('%%Lick|Stim %1c = %.2f\n', temp_id, per_stimid_lick(i_id));
end


% Hit rates:
% Go stim: number followed by reward (or lick before next NP and MT < Max_MT)
% Nogo stim: number followed by lick before next NP and MT < Max_MT
% max_reward_mt can be measured as max time for Go trials (calculated above) 
% or as <MT limit (which sets error correction)
% max_reward_mt = double(max_reward_mt)/1000;
sub_trials = data.np_stim_class=='G';
go_hits = (np_lick_trials(sub_trials) == 'L') & (mt(sub_trials) <= data.MaxMT);
sub_trials = data.np_stim_class=='N';
nogo_hits = (np_lick_trials(sub_trials) == 'L') & (mt(sub_trials) <= data.MaxMT);
acc = mean([go_hits; ~nogo_hits]);
fprintf('%%Acc           = %.2f\n', acc);
per_gostim_lick = mean(go_hits);
per_nogostim_lick = mean(nogo_hits);
fprintf('%%Hit |Go  Stim = %.2f\n', per_gostim_lick);
fprintf('%%Hit |NogoStim = %.2f\n', per_nogostim_lick);
data.num_hits = sum(go_hits);

% exclude Nogo (& Go?) correction trials
% error trials: need to account for when MT expires?
% error_trials = lick_trials


%% Calc NP Durs
mask = data.np_stim_class == 'G';
fprintf('NP Dur|Go  Stim =  ');
med = MedIQR_NoDec(dur_nps(mask));
med_npdur.gostim = med;

mask = data.np_stim_class == 'N';
fprintf('NP Dur|NogoStim =  ');
med = MedIQR_NoDec(dur_nps(mask));
med_npdur.nogostim = med;

mask = data.np_stim_class == 0;
fprintf('NP Dur|No  Stim =  ');
med = MedIQR_NoDec(dur_nps(mask));
med_npdur.nostim = med;

% % Graph histograms of NP dur by stim
% clf;
% hold on;
% bin_edges = [0:10:1000 Inf];
% 
% mask = data.np_stim_class == 'G';
% hist_dur = histc(dur_nps(mask), bin_edges);
% hist_dur = hist_dur ./ sum(mask);
% h = plot(bin_edges, hist_dur);
% set(h, 'Color', ColorPicker('turquoise'));
% 
% mask = data.np_stim_class == 'N';
% hist_dur = histc(dur_nps(mask), bin_edges);
% hist_dur = hist_dur ./ sum(mask);
% h = plot(bin_edges, hist_dur);
% set(h, 'Color', ColorPicker('red'));
% 
% mask = data.np_stim_class == 0;
% hist_dur = histc(dur_nps(mask), bin_edges);
% hist_dur = hist_dur ./ sum(mask);
% h = plot(bin_edges, hist_dur);
% set(h, 'Color', ColorPicker('lightgray'));
% 
% axis([0 bin_edges(end), 0 Inf]);
% title(filename);
% pause;


%% Calc MTs from NP->Lick|xStim
mask = np_lick_trials > 0 & data.np_stim_class == 'G';
fprintf('MT Lick|Go  Stim = ');
med = MedIQR_NoDec(mt(mask));
med_lick.gostim = med;
mask = np_lick_trials > 0 & data.np_stim_class == 'N';
fprintf('MT Lick|NogoStim = ');
med = MedIQR_NoDec(mt(mask));
med_lick.nogostim = med;
mask = np_lick_trials > 0 & data.np_stim_class == 0;
fprintf('MT Lick|No  Stim = ');
med = MedIQR_NoDec(mt(mask));
med_lick.nostim = med;
% clf;
% hold on;
% h = plot(data.ts_np_out(mask), mt(mask), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% h = plot(data.ts_np_out(mask), mt(mask), '.');
% set(h, 'Color', ColorPicker('blue'));
% % axis ([-Inf Inf, 0 1e3]);


% Plot NP Durs
% clf;
% hold on;
% mask = stim_trials == 'G';
% h = plot(data.ts_np_out(mask), dur_nps(mask), '.');
% set(h, 'Color', ColorPicker('blue'));
% mask = stim_trials <= 0;
% fprintf('NP Dur|NoStim = ');
% MedIQR(dur_nps(mask));
% h = plot(data.ts_np_out(mask), dur_nps(mask), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% axis ([-Inf Inf, 0 1e3]);
% 
% % Plot RTs
% clf;
% hold on;
% mask = stim_trials <= 0;
% h = plot(data.ts_np_out(mask), rt(mask), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% mask = ~mask;
% h = plot(data.ts_np_out(mask), rt(mask), '.');
% set(h, 'Color', ColorPicker('blue'));
% axis ([-Inf Inf, 0 1e3]);
% 
% % Plot MTs
% clf;
% hold on;
% mask = lick_trials <= 0;
% h = plot(data.ts_np_out(mask), mt(mask), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% mask = ~mask;
% h = plot(data.ts_np_out(mask), mt(mask), '.');
% set(h, 'Color', ColorPicker('blue'));
% % axis ([-Inf Inf, 0 1e3]);
% 
% 
% % % Plot MTs from NP->Lick|GoStim vs. NP->Lick|NoStim
% mask = lick_trials > 0 & stim_trials <= 0;
% fprintf('MT Lick|NoStim = ');
% MedIQR(mt(mask));
% % clf;
% % hold on;
% % h = plot(data.ts_np_out(mask), mt(mask), '.');
% % set(h, 'Color', ColorPicker('lightgray'));
% mask = lick_trials > 0 & stim_trials > 0;
% fprintf('MT Lick|GoStim = ');
% MedIQR(mt(mask));
% % h = plot(data.ts_np_out(mask), mt(mask), '.');
% % set(h, 'Color', ColorPicker('blue'));
% % % axis ([-Inf Inf, 0 1e3]);


%% Sparkline plots
% Now plot responses by stimulus type
% all_stim_ids = ['L', 'M', 'H'];
% all_stim_ids = char(unique(data.stim_id));

% Order stims by constant Go -> switch -> constant NoGo
if sum('G' == char(unique(data.stim_class(data.stim_id == 'H')))) || sum('N' == char(unique(data.stim_class(data.stim_id == 'L'))))
    all_stim_ids = 'HML';
% elseif 'G' == char(unique(data.stim_class(data.stim_id == 'L')))
else
    all_stim_ids = 'LMH';
end

win = 20;
clf;
grid_axes = AxesGrid(numel(all_stim_ids)+1, 1);
% rect_width = 2*median(diff(double(data.ts_stim_on)))/MsPerDay(); % based on ITI
rect_width = (data.ts_end(1) - data.ts_start(end))/MsPerDay()/1e3; % Based on overall length (will be somewhat more consistent across sessions)
for i_id = 1:numel(all_stim_ids)
    axes(grid_axes(i_id));
    set(gca, 'Box', 'on');
    % Stim trials
    sub_trials = data.stim_id == all_stim_ids(i_id);
    if sum(sub_trials)
        sub_class = double(data.stim_class(sub_trials));
        sub_resp = 'L' == data.response(sub_trials);
        sub_ts = double(data.ts_stim_on(sub_trials));
        sub_ts = sub_ts/MsPerDay();
        PlotSparklineGoNogo(sub_resp, sub_class, sub_ts, win, rect_width)
    end
    margin = 0.05;
    axis([0 double(data.ts_end(1))/MsPerDay(), 0-margin 1+margin]);
    ylabel(sprintf('Stim %c', all_stim_ids(i_id)));
    datetick('x', 'keeplimits');
end

% for i_id = 1:numel(all_stim_ids)
%     axes(grid_axes(i_id));
%     set(gca, 'Box', 'on');
%     % Stim trials
%     sub_trials = data.np_stim_id == all_stim_ids(i_id);
%     if sum(sub_trials)
%         sub_class = data.stim_class(sub_trials);
%         sub_id = data.stim_id(sub_trials);
%         sub_resp = data.response(sub_trials);
%         char([sub_class sub_id sub_resp])'
% 
%         sub_hit = data.hit_attempts(sub_trials);
%         sub_ts = double(data.ts_np_out(sub_trials));
%         sub_ts = sub_ts/MsPerDay();
%         sub_class = data.np_stim_class(sub_trials);
%         PlotSparklineGoNogo(sub_hit, sub_class, sub_ts, win, rect_width)
%     end
%     margin = 0.05;
%     axis([0 double(data.ts_end)/MsPerDay(), 0-margin 1+margin]);
%     ylabel(sprintf('Stim %c', all_stim_ids(i_id)));
%     datetick('x', 'keeplimits');
% end

%% Learning criteria
axes(grid_axes(end));
hold on;

% ACCuracy for stim trials only -- plot first/in background
data.acc_by_trials = data.outcome == 'H' | data.outcome == 'R';
win = 100;
per_crit = 0.85-eps;

hist_data = line([0 data.ts_stim_on(end)/MsPerDay()], repmat(per_crit,2,1));
set(hist_data, 'LineWidth', 0.1');
set(hist_data, 'Color', ColorPicker('lightgray'));
set(hist_data, 'LineStyle', ':');

win_acc = RunningAverage(data.acc_by_trials, win);
hist_data = plot(data.ts_stim_on(win:end)/MsPerDay(), win_acc, '-');
set(hist_data, 'Color', ColorPicker('lightgray'));
set(hist_data, 'LineWidth', 0.1');
temp_ts = data.ts_stim_on(win:end)/MsPerDay();
h = plot(temp_ts(win_acc>per_crit), win_acc(win_acc>per_crit), '.');
set(h, 'Color', ColorPicker('lightgray'));
set(h, 'MarkerSize', 5);
datetick('x', 'keeplimits');
axis([0 double(data.ts_end(1))/MsPerDay(), 0-margin 1+margin]);


%% Num switches: Assuming only 1 Go Stim at a time
stim_id_go = double(data.stim_id(data.stim_class == 'G'));
data.num_switches = sum(abs(diff(stim_id_go))>0);
data.acc = mean(data.acc_by_trials);

%% List final stimulus pair
idx_class = find(data.stim_class == 'G');
data.last_go = char(data.stim_id(idx_class(end)));
fprintf('Last stim = %c+', data.last_go);

idx_class = find(data.stim_class == 'N');
if ~isempty(idx_class)
    data.last_nogo = char(data.stim_id(idx_class(end)));
    fprintf(' vs. %c-', data.last_nogo);
else
    data.last_nogo = [];
end
fprintf('\n');

%% Final new line
fprintf('\n');

% %% Plot position tracking data if available
% dir([filename(1:end-4) '.*'])
