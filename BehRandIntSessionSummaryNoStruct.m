function [per_gostim_lick, per_nostim_lick, per_nogostim_lick, acc, rate_np, ts_np_in] = BehRandIntSessionSummary(filename)

% clear all;
% cdMatlab;
% cd('..\PostDocResearch\Behavior\Data\RandIntGoNogo');
% filename = 'kBb-20140106-133749.txt';
% % % cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\CodeProcessing\RandIntGoNogo');
% % % filename = 'Test-20140107-113212.txt';


%% Load file
fprintf('Filename: %s\n', filename');
fid = fopen(filename, 'r');
if fid == -1
    fprintf ('Problem opening file: %s\n', filename)
    return;
end
file_double = fread(fid, inf, 'uchar'); % faster than fscanf. textread fails on string data
file_char = char(file_double');
clear file_double;
fclose(fid);


%% Parse data
% Make sure session was properly terminated, 
% otherwise for now return w/empty values
flag = 'msElapsed: ';
ms_elapsed = StrFlagToLine(file_char, flag);
if isempty(ms_elapsed)
    fprintf('Session not terminated properly. Exiting Session Summary.\n\n')
    per_gostim_lick = NaN;
    per_nostim_lick = NaN;
    per_nogostim_lick = NaN;
    acc = NaN;
    return
end

flag = 'Subject: ';
subject = StrFlagToLine(file_char, flag);

flag = 'Protocol: ';
protocol = StrFlagToLine(file_char, flag);

flag = 'PerGoStim: ';
per_go_stim = StrFlagToLine(file_char, flag);

flag = 'TimeStart: ';
datetime = StrFlagToLine(file_char, flag);
date_start = str2num(datetime([1:4, 6:7, 9:10]));
hour_start = str2num(datetime(12:13)) + str2num(datetime(15:16))/60 + str2num(datetime(18:19))/3600;

flag = 'MaxMT: ';
max_mt = StrFlagToLine(file_char, flag);
if ~isempty(max_mt)
    max_mt = str2num(max_mt);
    max_mt = max_mt / 1e3; % ms to sec
else
    max_mt = NaN;
end

% process timestamps and convert to numbers
flags = {'ts_np_in', 'ts_np_out', 'ts_lick_in', 'ts_lick_out', 'ts_fluid_on', 'ts_fluid_off', 'ts_free_rwd', 'ts_stim_on', 'ts_stim_off', 'stim_class', 'all_iti', 'ts_iti_end'};
num_flags = length(flags);
for i_flag = 1:num_flags
    flag = [flags{i_flag} ': '];
    temp_str = StrFlagToLine(file_char, flag);
    temp_str(temp_str == ',') = 0;
    temp_num = sscanf(temp_str, '%ld'); % 64 bit integers
    eval([flags{i_flag} ' = temp_num;']);
end


%% Print basic file info
% calc nosepoke durations
fprintf('Protocol: %s', protocol);
fprintf('%% Go Stim: %s', per_go_stim);
fprintf('# Stims = %d', length(ts_stim_on));
fprintf('  # Fluids = %d', length(ts_fluid_on));
fprintf('  # Free = %d\n', length(ts_free_rwd));

num_nps = length(ts_np_in);
fprintf('# NPs = %d', num_nps);
rate_np = num_nps / double(ts_np_out(end) - ts_np_in(1));
fprintf('\tNP Rate: %.3f/sec -> %.3f/min', rate_np*1e3, rate_np*1e3*60);
fprintf('\n');
dur_nps = ts_np_out - ts_np_in;
dur_nps = double(dur_nps);
fprintf('NP Dur (sec): ');
MedIQR(dur_nps/1e3);
fprintf('Total NP time: %.3f sec -> %.3f min\n', sum(dur_nps)/1e3, sum(dur_nps)/1e3/60);

num_licks = length(ts_lick_in);
fprintf('# Licks = %d', num_licks);
rate_lick = num_licks / double(ts_np_out(end) - ts_np_in(1));
fprintf('\tLick Rate: %.3f/sec -> %.3f/min', rate_lick*1e3, rate_lick*1e3*60);
fprintf('\n');
dur_licks = ts_lick_out - ts_lick_in;
dur_licks = double(dur_licks);
% Lick duration w/fluid vs. w/out
fprintf('Lick Dur (sec): ');
MedIQR(dur_licks/1e3);
fprintf('Total Lick time: %.3f sec -> %.3f min\n', sum(dur_licks)/1e3, sum(dur_licks)/1e3/60);

% %% Graph timestamps
% % Plots nosepoke times over hour
% clf;
% plot(double(ts_np_in-ts_np_in(1))/1e3/3600, '.')
% axis tight

% clf;
% PlotCDF(dur_nps);

% clf;
% PlotCDF(dur_licks);
% inter_licks = ts_lick_in(2:end) - ts_lick_out(1:end-1);
% inter_licks = double(inter_licks);
% PlotCDF(inter_licks);

% % Plot lick timepoints
% clf;
% hold on;
% h = plot(double(ts_lick_in)/1e3/60, 1:length(ts_lick_in), '.b');
% set(h, 'MarkerSize', 5);
% h= plot(double(ts_lick_out)/1e3/60, 1:length(ts_lick_out), '.r');
% set(h, 'MarkerSize', 5);
% axis tight;
% set(gca, 'YDir', 'reverse');
% title(filename);

% %% MT Empirical calculation for Accuracy
% % have to know "Hit" responses:
% % attempted to lick within required time frame, i.e. before MT expired
% % did not record this explicitly in early sessions
% % can compare MT for longest successful lick as max MT for that session
% % look for Lick preceeded by NPOut and followed by Fluid On
% 
% % Sort all timestamps and reorganize ids
% all_ts = [ts_np_out; ts_lick_in; ts_fluid_on];
% all_ids = ['n' * ones(size(ts_np_out)); 'L' * ones(size(ts_lick_in)); 'F' * ones(size(ts_fluid_on))];
% [sort_ts, idx_sort] = sort(all_ts);
% sort_ids = all_ids(idx_sort);
% sort_ts = [-1; sort_ts; sort_ts(end) + 1];
% sort_ids = ['X'; sort_ids; 'Z'];
% idx_lick = find(sort_ids == 'L');
% 
% seqs = [sort_ids(idx_lick-1), sort_ids(idx_lick), sort_ids(idx_lick+1)];
% mask = seqs(:,1) == 'n' & seqs(:,3) == 'F';
% fluid_mt = sort_ts(idx_lick(mask)) - sort_ts(idx_lick(mask)-1);
% max_fluid_mt = max(fluid_mt);
% % hist(double(fluid_mt), );
% % char([sort_ids(idx_lick-1), sort_ids(idx_lick), sort_ids(idx_lick+1)])
% fprintf('MaxMT = %4d ms\n', max_fluid_mt);

%% Stim Responses: Attempts to collect, RT, MT
% currently structured as timestamps, 
% both in dump (which will hopefully be removed in future files) 
% and in collections by event
%
% Can search in for loop 1 by 1 or can try to 
% create longer strings of chars for all events 
% and look for char patterns. may be faster
%
% ie. % of NPout preceded by stim of which are followed by lick or fluid
% similar to previous matlab analyses

% Collect following "trial info" for each NP Out
% np_dur = np_out - np_in; collected above
% rt is not paricularly meaningful given np_dur and fixed foreperiod
% preceding stimulus? no, go, or nogo
% following resp
% following resp time

% Sort all timestamps and reorganize ids
all_ts = [ts_np_out; ts_np_in; ts_stim_on; ts_lick_in];
all_ids = ['n' * ones(size(ts_np_out)); 'N' * ones(size(ts_np_in)); 'S' * ones(size(ts_stim_on)); 'L' * ones(size(ts_lick_in))];
[sort_ts, idx_sort] = sort(all_ts);
sort_ids = all_ids(idx_sort);
sort_ts = [-1; sort_ts; sort_ts(end) + 1];
sort_ids = ['X'; sort_ids; 'X'];

% ACCOUNT FOR PROBLEMS W/FREE REWARDS
% Subtract free rewards from ts_stim_on
% otherwise don't match in trials which are based on peri-NPout
% Can do this by finding timestamps that intersect between ts_stim_on & ts_free_rwd
% But this seems to miss trials in filename = 'kCb-20140105-132919.txt';
% there is no clear stim on at the time of free reward even though the total numbers add up...
% can also just eliminate stims that are not preceded by npin & followed by npout -- more reliable sync
idx_stim = find(sort_ids == 'S');
idx_stim_peri_np = sort_ids(idx_stim - 1) == 'N' & sort_ids(idx_stim + 1) == 'n';
if length(idx_stim_peri_np) <= length(stim_class)
    stim_class = stim_class(idx_stim_peri_np); % stim_class is likely 1 longer than stim since it also stores the expected upcoming stimulus. This doesn't seem to throw off this indexing surprisingly
else
    fprintf('Error!: Stim class likely not complete due to early protocols. Pulling running data dump info.\n');
    %%% temporary hack for early sessions w/more than 1 stim per trial
    % This info may not be saved in this way if the protocol becomes more reliable
    flag = 'StimClass: ';
    stim_class = StrFlagToLine_NumArray(file_char, flag);
    stim_class = stim_class(idx_stim_peri_np); % stim_class is likely 1 longer than stim since it also stores the expected upcoming stimulus. This doesn't seem to throw off this indexing surprisingly
end



% Currently unused:
% ts_stim_on = ts_stim_on(idx_stim_peri_np);
% ts_stim_off = ts_stim_off(idx_stim_peri_np);
% [ts_free_stims, IA, IB] = intersect(ts_stim_on, ts_free_rwd);
% mask = true(size(ts_stim_on));
% mask(IA) = false;
% ts_stim_on = ts_stim_on(mask);
% stim_class = stim_class(mask);

% Find np's preceded by stimulus
idx_npout = find(sort_ids == 'n');
stim_trials = zeros(size(ts_np_out));
stim_trials(sort_ids(idx_npout - 1) == 'S') = char(stim_class);
% rarely, ~once every 2-4 sessions, on one trial NPin & NPout co-occur, e.g. filename = 'kBa-20131207-165916.txt';
% seems to be due to a flicker of instability as
% NPOut is followed by an immediate NPIn with the same timestamp
% Doesn't seem to happen other way, so rearranged before sort as above
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
lick_trials = zeros(size(ts_np_out));
lick_trials(sort_ids(idx_npout + 1) == 'L') = 'L';
% RT: Has mixed responses of Lick and re-np
mt = sort_ts(idx_npout+1) - sort_ts(idx_npout);
mt = double(mt)/1e3;
% fprintf('MT-Lick (sec): ');
% mask = lick_trials > 0;
% MedIQR(mt(mask));

% "Choice" "Accuracy"
per_gostim_lick = mean(lick_trials(stim_trials == 'G') > 0);
per_nogostim_lick = mean(lick_trials(stim_trials == 'N') > 0);
per_nostim_lick = mean(lick_trials(stim_trials<=0) > 0);
fprintf('%%Lick|Go  Stim = %.2f\n', per_gostim_lick);
fprintf('%%Lick|NogoStim = %.2f\n', per_nogostim_lick);
fprintf('%%Lick|No  Stim = %.2f\n', per_nostim_lick);


% Hit rates:
% Go stim: number followed by fluid (or lick before next NP and MT < Max_MT)
% Nogo stim: number followed by lick before next NP and MT < Max_MT
% max_fluid_mt can be measured as max time for Go trials (calculated above) 
% or as <MT limit (which sets error correction)
% max_fluid_mt = double(max_fluid_mt)/1000;
sub_trials = stim_trials=='G';
go_hits = (lick_trials(sub_trials) == 'L') & (mt(sub_trials) <= max_mt);
sub_trials = stim_trials=='N';
nogo_hits = (lick_trials(sub_trials) == 'L') & (mt(sub_trials) <= max_mt);
acc = mean([go_hits; ~nogo_hits]);
fprintf('%%Acc           = %.2f\n', acc);
per_gostim_lick = mean(go_hits);
per_nogostim_lick = mean(nogo_hits);
fprintf('%%Hit |Go  Stim = %.2f\n', per_gostim_lick);
fprintf('%%Hit |NogoStim = %.2f\n', per_nogostim_lick);


% exclude Nogo (& Go?) correction trials
% error trials: need to account for when MT expires?
% error_trials = lick_trials

% Calc NP Durs
mask = stim_trials == 'G';
fprintf('NP Dur|Go  Stim = ');
MedIQR(dur_nps(mask));
mask = stim_trials == 'N';
fprintf('NP Dur|NogoStim = ');
MedIQR(dur_nps(mask));
mask = stim_trials == 0;
fprintf('NP Dur|No  Stim = ');
MedIQR(dur_nps(mask));

% Calc MTs from NP->Lick|xStim
mask = lick_trials > 0 & stim_trials == 'G';
fprintf('MT Lick|Go  Stim = ');
MedIQR(mt(mask));
mask = lick_trials > 0 & stim_trials == 'N';
fprintf('MT Lick|NogoStim = ');
MedIQR(mt(mask));
mask = lick_trials > 0 & stim_trials == 0;
fprintf('MT Lick|No  Stim = ');
MedIQR(mt(mask));
% clf;
% hold on;
% h = plot(ts_np_out(mask), mt(mask), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% h = plot(ts_np_out(mask), mt(mask), '.');
% set(h, 'Color', ColorPicker('blue'));
% % axis ([-Inf Inf, 0 1e3]);


% Plot NP Durs
% clf;
% hold on;
% mask = stim_trials == 'G';
% h = plot(ts_np_out(mask), dur_nps(mask), '.');
% set(h, 'Color', ColorPicker('blue'));
% mask = stim_trials <= 0;
% fprintf('NP Dur|NoStim = ');
% MedIQR(dur_nps(mask));
% h = plot(ts_np_out(mask), dur_nps(mask), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% axis ([-Inf Inf, 0 1e3]);
% 
% % Plot RTs
% clf;
% hold on;
% mask = stim_trials <= 0;
% h = plot(ts_np_out(mask), rt(mask), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% mask = ~mask;
% h = plot(ts_np_out(mask), rt(mask), '.');
% set(h, 'Color', ColorPicker('blue'));
% axis ([-Inf Inf, 0 1e3]);
% 
% % Plot MTs
% clf;
% hold on;
% mask = lick_trials <= 0;
% h = plot(ts_np_out(mask), mt(mask), '.');
% set(h, 'Color', ColorPicker('lightgray'));
% mask = ~mask;
% h = plot(ts_np_out(mask), mt(mask), '.');
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
% % h = plot(ts_np_out(mask), mt(mask), '.');
% % set(h, 'Color', ColorPicker('lightgray'));
% mask = lick_trials > 0 & stim_trials > 0;
% fprintf('MT Lick|GoStim = ');
% MedIQR(mt(mask));
% % h = plot(ts_np_out(mask), mt(mask), '.');
% % set(h, 'Color', ColorPicker('blue'));
% % % axis ([-Inf Inf, 0 1e3]);

fprintf('\n');

% %% plot window of responses over session
% clf;
% hold on;
% win = 20;
% 
% nostim_lick = lick_trials(stim_trials <= 0) > 0;
% ts_nostim_trials = double(ts_np_out(stim_trials <= 0));
% h = plot(ts_nostim_trials(win:end)/60e3, RunningAverage(nostim_lick, win), '.-');
% set(h, 'Color', ColorPicker('lightgray'));
% 
% gostim_lick = lick_trials(stim_trials == 'G') > 0;
% ts_gostim_trials = double(ts_np_out(stim_trials == 'G'));
% h = plot(ts_gostim_trials(win:end)/60e3, RunningAverage(gostim_lick, win), '.-');
% set(h, 'Color', ColorPicker('turquoise'));
% 
% nogostim_lick = lick_trials(stim_trials == 'N') > 0;
% ts_nogostim_trials = double(ts_np_out(stim_trials == 'N'));
% h = plot(ts_nogostim_trials(win:end)/60e3, RunningAverage(nogostim_lick, win), '.-');
% set(h, 'Color', ColorPicker('red'));
% 
% title(filename);
% axis([0 Inf 0 1.01])
% xlabel('Time (min)');
% ylabel(sprintf('Probability of Response by Stimulus Type (Running Average of %d Trials)', win));


%% Plot timepoints of trials
clf;
h = plot(double(ts_np_in)/1e3/60, 1:length(ts_np_in), '.-k');
set(h, 'LineWidth', 0.1);
axis tight;
% set(gca, 'YDir', 'reverse');
xlabel('Session Time (min)');
ylabel('# Nosepokes (Cumulative)');
set(gca, 'Box', 'off');
title(filename);