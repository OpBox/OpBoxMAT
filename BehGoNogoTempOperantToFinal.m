% function struct_data = BehGoNogoTempOperantToFinal(filename)

cdData;
cd('Behavior\RandIntGoNogoSwitch');
cd('temp');
filename = 'kCj-20150512-094758.beh';
% fprintf('Filename: %s\n', filename');
 
%% Load file
fid = fopen(filename, 'r');
if fid == -1
    fprintf ('Problem opening file: %s\n', filename)
    return;
end
file_char = fread(fid, inf, 'uchar=>char'); % faster than fscanf. textread fails on string data. Returns as double for some weird reason
fclose(fid);
% file_char = file_char'; % for strfind below

%% Parse data
% Field name from newline to | pipe-space, data from space to end of line which is \13\10

idx_newlines = find(file_char==13);
idx_newlines = [-1; idx_newlines];
idx_delim = find(file_char == '|');
post_delim = 1;

%% Process text looking for fields
num_newlines = length(idx_newlines);
all_labels = cell(num_newlines-1, 1);
all_data = cell(num_newlines-1, 1);
for i_line = 1:num_newlines-1
    label = file_char(idx_newlines(i_line)+2:idx_delim(i_line)-1); % +2 to account for /13/10 end of line. -1 to end right before delimiter
    label = label(:)'; % comes in as col vector, convert to row

    data = file_char(idx_delim(i_line)+post_delim:idx_newlines(i_line+1)-1); % +1 if only delim, +2 if delim & space. -1 to end before new line
    if sum(isletter(data)) || sum(':' == data)
        % text data, change to row from column vector
        data = data(:)';
    else
        % numerical data, pull it out
        data(',' == data) = 0;
        data = sscanf(data, '%ld');
    end
    
    all_labels{i_line} = label;
    all_data{i_line} = data;
end

%% Switch and process each label
clear data;
data.ts_free_rwd = [];

name_labels = unique(all_labels);
for i_label = 1:numel(name_labels)
    idx_labels = find(strcmp(all_labels, name_labels{i_label}));
    switch name_labels{i_label}
        case 'N'
            data.ts_np_in = vertcat(all_data{idx_labels});
        case 'n'
            data.ts_np_out = vertcat(all_data{idx_labels});
        case 'L'
            data.ts_lick_in = vertcat(all_data{idx_labels});
        case 'l'
            data.ts_lick_out = vertcat(all_data{idx_labels});
        case 'R'
            data.ts_reward_on = vertcat(all_data{idx_labels});
        case 'r'
            data.ts_reward_off = vertcat(all_data{idx_labels});
        case 'F'
            data.ts_free_rwd = vertcat(all_data{idx_labels});
        case 'S'
            data.ts_stim_on = vertcat(all_data{idx_labels});
        case 's'
            data.ts_stim_off = vertcat(all_data{idx_labels});
        case 'G'
            stim_data = vertcat(all_data{idx_labels});
            data.stim_class = int16(stim_data(:, 1));
            data.stim_id = int16(stim_data(:, 2));
        case 'O'
            stim_data = vertcat(all_data{idx_labels});
            data.response = int16(stim_data(:, 1));
            data.outcome = int16(stim_data(:, 2));
        case 'm'
            data.ts_mt_end = vertcat(all_data{idx_labels});
        case 'I'
            data.ts_iti_end = vertcat(all_data{idx_labels});
        case 'T'
            data.ts_start = vertcat(all_data{idx_labels});
        case 't'
            data.ts_end = vertcat(all_data{idx_labels});
        case 'U'
            % Upcoming stim info, ignore
        otherwise
            fprintf('Label %s not recognized\n', name_labels{i_label});
    end
end
fprintf('\n');

% all_iti not saved initially
% Su: Upcoming stimulus "planned/intended" (may be different if give free reward, etc)
% Re: Result, not in final file

%% Now export to final operant file
delim = '|';
final_filename = [filename(1:end-3) 'txt'];
fid = fopen(final_filename, 'w');
fprintf(fid, 'Subject%c%s\r\n', delim, filename(1:3));
fprintf(fid, 'DateTimeStart%c%s\r\n', delim, filename(5:end-4));
% From other settings: e.g. Subjects.csv
% fprintf(fid, 'Box%c%d\r\n', delim, 0);
% fprintf(fid, 'Protocol%c%s\r\n', delim, 'RandIntGoNogoSwitch');
% fprintf(fid, 'MeanITI%c%d\r\n', delim, 8);
% Box|0
% Protocol|RandIntGoNogoSwitch
% MeanITI|8
% ProbGoStim|20
% RepeatFalseAlarm|true
% GoStimIDs|M
% NogoStimIDs|H
% SwitchGoStimIDs|L
% SwitchNogoStimIDs|M
% DowntimeFreeRwd|900000
% MaxMT|5000
% NumFreeHits|3
% WinDur|85
% WinCrit|100
% DrawFrameRate|10
fprintf(fid, 'msStart%c%s\r\n', delim, NaN);
fprintf(fid, 'msElapsed%c%s\r\n', delim, NaN);
fprintf(fid, 'TimeElapsed%c%s\r\n', delim, NaN);
% msStart|136845
% msElapsed|11875681
% TimeElapsed|03:17:55

% Now output each data field
field_names = fieldnames(data);
for i_field = 1:numel(field_names)
    fprintf(fid, '%s%c', field_names{i_field}, delim);
    fprintf(fid, '%d,', data.(field_names{i_field}));
    fprintf(fid, '\r\n');
end

fclose(fid);
