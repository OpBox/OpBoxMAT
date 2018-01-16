function BehRandInt_DebounceAnalysis(filename)

% clear;
% cdMatlab;
% cd('..\PostDocResearch\Behavior\Data\RandIntGoNogo');
% % filename = 'kCa-20131216-113733.txt';
% % % filename = 'kCb-20131216-113740.txt';
% % filename = 'kCc-20131216-113749.txt';
% % % filename = 'kCd-20131216-113755.txt';
% % cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\CodeProcessing\Archive\RandIntGoNogo_NoDebounceNP');
% % filename = 'Test-20131216-144955.txt';
% % filename = 'Test-20131216-145620.txt';
% cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\CodeProcessing\RandIntGoNogo');
% filename = 'Test-20131216-150106.txt';
% filename = 'Test-20131216-150508.txt';

%% Load file
fprintf('Filename: %s\n', filename');
fid = fopen(filename, 'r');
if fid == -1
    fprintf ('Incorrect file: %s', filename)
    return;
end
file_double = fread(fid, inf, 'uchar'); % faster than fscanf. textread fails on string data
file_char = char(file_double');
clear file_double;
fclose(fid);


%% Parse data
% Make sure session was properly terminated, 
% otherwise for now return w/emtpy values
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

%%% temporary hack for early sessions w/more than 1 stim per trial
% This info may not be saved in this way if the protocol becomes more reliable
flag = 'StimClass: ';
stim_class = StrFlagToLine_NumArray(file_char, flag);


%% Nosepoke data
dur_nps = ts_np_out - ts_np_in;
dur_nps = double(dur_nps);
fprintf('NP Dur (sec): ');
MedIQR(dur_nps/1e3);
ms_cutoff = 5;
fprintf('#NPs = %d\n', length(ts_np_out));
fprintf('NP < %2d ms: %.3f\n', ms_cutoff, mean(dur_nps < ms_cutoff));
fprintf('NP < %2d ms: %.3f\n', 2*ms_cutoff, mean(dur_nps < 2*ms_cutoff));
fprintf('NP < %2d ms: %.3f\n', 3*ms_cutoff, mean(dur_nps < 3*ms_cutoff));
fprintf('NP < %2d ms: %.3f\n', 4*ms_cutoff, mean(dur_nps < 4*ms_cutoff));
% mean(dur_nps < 5)
clf;
bins = [0:5:1e3, Inf];
hist_data = histc(dur_nps, bins);
plot(bins, hist_data, '.-');
axis([bins(1), bins(end-1) 0 400])
% axis tight;

%% Movement/InterNP data
mt_np = ts_np_in(2:end) - ts_np_out(1:end-1);
mt_np = double(mt_np);
fprintf('MT Dur (sec): ');
MedIQR(mt_np/1e3);
ms_cutoff = 5;
fprintf('NP < %2d ms: %.3f\n', ms_cutoff, mean(mt_np < ms_cutoff));
fprintf('NP < %2d ms: %.3f\n', 2*ms_cutoff, mean(mt_np < 2*ms_cutoff));
fprintf('NP < %2d ms: %.3f\n', 3*ms_cutoff, mean(mt_np < 3*ms_cutoff));
fprintf('NP < %2d ms: %.3f\n', 4*ms_cutoff, mean(mt_np < 4*ms_cutoff));
% mean(dur_nps < 5)
% clf;
% bins = [0:5:1e3, Inf];
% hist_data = histc(mt_np, bins);
% plot(bins, hist_data, '.-');
% axis([bins(1), bins(end-1) 0 400])
% axis tight;
fprintf('\n');