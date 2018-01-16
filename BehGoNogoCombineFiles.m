% Nosepoke on 6
% Glue acrylic boxes

clc;
clear all;

cdMatlab;
cd('..\Research\Behavior\Data\RandIntGoNogoSwitch');
cd('ToCombine');


% temp_date = '*';
% temp_date = datestr(now, 'yyyymmdd');
temp_date = '20140716';
temp_anim = 'kCd';

file_mask = [temp_anim '-' temp_date '-*.txt'];
files = dir(file_mask);
num_files = length(files);

fprintf('%d files found\n', num_files);

for i_file = 1:num_files
    filename = files(i_file).name;
    data(i_file) = BehGoNogoSessionSummary(filename);
%     pause;
end

%% Write a new file
clf;

filename = ['Combo-' files(1).name];

fid = fopen(filename, 'wt');
delim = '|';
fprintf(fid, 'Subject%c%s\n', delim, data(1).Subject);
fprintf(fid, 'DateTimeStart%c%s%s\n', delim, num2str(data(1).DateTimeStart(1)), num2str(data(1).DateTimeStart(2)));
fprintf(fid, 'Box%c%d\n', delim, data(1).Box);
fprintf(fid, 'Protocol%c%s\n', delim, data(1).Protocol);
fprintf(fid, 'MeanITI%c%d\n', delim, data(1).MeanITI);
fprintf(fid, 'ProbGoStim%c%d\n', delim, data(1).ProbGoStim);
fprintf(fid, 'RepeatFalseAlarm%c', delim);
if data(1).RepeatFalseAlarm
    fprintf(fid, 'true\n');
else 
    fprintf(fid, 'false\n');
end
fprintf(fid, 'GoStimIDs%c%s\n', delim, data(1).GoStimIDs);
fprintf(fid, 'NogoStimIDs%c%s\n', delim, data(1).NogoStimIDs);
fprintf(fid, 'SwitchGoStimIDs%c%s\n', delim, data(1).SwitchGoStimIDs);
fprintf(fid, 'SwitchNogoStimIDs%c%s\n', delim, data(1).SwitchNogoStimIDs);
fprintf(fid, 'DowntimeFreeRwd%c%d\n', delim, data(1).DowntimeFreeRwd);
fprintf(fid, 'MaxMT%c%d\n', delim, data(1).MaxMT);
fprintf(fid, 'NumFreeHits%c%d\n', delim, data(1).NumFreeHits);
fprintf(fid, 'WinDur%c%d\n', delim, data(1).WinDur);
fprintf(fid, 'WinCrit%c%d\n', delim, data(1).WinCrit);
fprintf(fid, 'msStart%c%d\n', delim, data(1).msStart);

fprintf(fid, 'msElapsed%c', delim);
temp_ms = data(1).msElapsed;
for i_file = 2:num_files
    temp_ms = temp_ms + data(i_file).msElapsed - data(i_file).msStart;
end
fprintf(fid, '%d\n', temp_ms);

fprintf(fid, 'TimeElapsed%c', delim);
temp_str = data(1).TimeElapsed;
for i_file = 2:num_files
    temp_str = [temp_str ' + ' data(i_file).TimeElapsed];
end
fprintf(fid, '%s\n', temp_str);

fprintf(fid, 'DrawFrameRate%c%d\n', delim, data(1).DrawFrameRate);

% Combine ts data
labels = {'ts_np_in', 'ts_np_out', 'ts_lick_in', 'ts_lick_out', 'ts_reward_on', 'ts_reward_off', 'ts_free_rwd', 'ts_stim_on', 'ts_stim_off'};
for i_label = 1:length(labels)
    temp_data = [];
    ts_running_end = 0;
    for i_file = 1:num_files
        temp_data = [temp_data; data(i_file).(labels{i_label}) + ts_running_end];
        ts_running_end = ts_running_end + data(i_file).ts_end;
    end
    fprintf(fid, '%s%c', labels{i_label}, delim);
    for i = 1:length(temp_data)
        fprintf(fid, '%d,', temp_data(i));
    end
    fprintf(fid, '\n');
end

% Combine char/int data
labels = {'stim_class', 'stim_id', 'all_iti'};
for i_label = 1:length(labels)
    temp_data = [];
    for i_file = 1:num_files
        temp_data = [temp_data; data(i_file).(labels{i_label})];
    end
    fprintf(fid, '%s%c', labels{i_label}, delim);
    for i = 1:length(temp_data)
        fprintf(fid, '%d,', temp_data(i));
    end
    fprintf(fid, '\n');
end

% Combine ts data: Match original order to be able to combine later
labels = {'ts_iti_end', 'ts_mt_end'};
for i_label = 1:length(labels)
    temp_data = [];
    ts_running_end = 0;
    for i_file = 1:num_files
        temp_data = [temp_data; data(i_file).(labels{i_label}) + ts_running_end];
        ts_running_end = ts_running_end + data(i_file).ts_end;
    end
    fprintf(fid, '%s%c', labels{i_label}, delim);
    for i = 1:length(temp_data)
        fprintf(fid, '%d,', temp_data(i));
    end
    fprintf(fid, '\n');
end


fprintf(fid, '%s%c%d\n', 'ts_start', delim, 0); % reset to 0 within session summary
fprintf(fid, '%s%c%d\n', 'ts_end', delim, ts_running_end); % reset to 0 within session summary



fclose(fid);
