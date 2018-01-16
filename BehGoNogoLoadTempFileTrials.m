function data = BehGoNogoLoadTempFileTrials(filename)

file_char = LoadFileText(filename);

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
clear data
num_trials = 0;
data.ts_stim_on = [];
data.ts_stim_off = [];
data.stim_class = [];
data.stim_id = [];
data.response = [];
data.outcome = [];

for i_label = 1:numel(all_labels)
    switch all_labels{i_label}
        case 'N'
%             data.ts_np_in = vertcat(all_data{i_label});
        case 'n'
%             data.ts_np_out = vertcat(all_data{i_label});
        case 'L'
%             data.ts_lick_in = vertcat(all_data{i_label});
        case 'l'
%             data.ts_lick_out = vertcat(all_data{i_label});
        case 'R'
%             data.ts_reward_on = vertcat(all_data{i_label});
        case 'r'
%             data.ts_reward_off = vertcat(all_data{i_label});
        case 'F'
%             data.ts_free_rwd = vertcat(all_data{i_label});
        case 'S'
            num_trials = num_trials + 1;
            data(num_trials).ts_stim_on = all_data{i_label};
        case 'Si'
            num_trials = num_trials + 1;
            data(num_trials).ts_stim_on = all_data{i_label};
        case 's'
            if num_trials == 0 || ~isempty(data(num_trials).ts_stim_off)
                fprintf('Found trial data in temp file before next ts_stim_on after trial %d, ts = %d\n', num_trials, data(num_trials).ts_stim_on);
            end
            data(num_trials).ts_stim_off = all_data{i_label};
        case 'So'
            if num_trials == 0 || ~isempty(data(num_trials).ts_stim_off)
                fprintf('Found trial data in temp file before next ts_stim_on after trial %d, ts = %d\n', num_trials, data(num_trials).ts_stim_on);
            end
            data(num_trials).ts_stim_off = all_data{i_label};
        case 'G'
            if num_trials == 0 || ~isempty(data(num_trials).stim_class)
                fprintf('Found trial data in temp file before next ts_stim_on after trial %d, ts = %d\n', num_trials, data(num_trials).ts_stim_on);
            end
            data(num_trials).stim_class = char(all_data{i_label}(1));
            data(num_trials).stim_id = char(all_data{i_label}(2));
        case 'St'
            if num_trials == 0 || ~isempty(data(num_trials).stim_class)
                fprintf('Found trial data in temp file before next ts_stim_on after trial %d, ts = %d\n', num_trials, data(num_trials).ts_stim_on);
            end
            data(num_trials).stim_class = char(all_data{i_label}(1));
            data(num_trials).stim_id = char(all_data{i_label}(2));
        case 'O'
            if num_trials == 0 || ~isempty(data(num_trials).response)
                fprintf('Found trial data in temp file before next ts_stim_on after trial %d, ts = %d\n', num_trials, data(num_trials).ts_stim_on);
            end
            data(num_trials).response = char(all_data{i_label}(1));
            data(num_trials).outcome = char(all_data{i_label}(2));
        case 'Re'
            if num_trials == 0 || ~isempty(data(num_trials).response)
                fprintf('Found trial data in temp file before next ts_stim_on after trial %d, ts = %d\n', num_trials, data(num_trials).ts_stim_on);
            end
            data(num_trials).response = char(all_data{i_label}(1));
            data(num_trials).outcome = char(all_data{i_label}(2));
        case 'm'
%             data.ts_mt_end = vertcat(all_data{i_label});
        case 'I'
%             data.ts_iti_end = vertcat(all_data{i_label});
        case 'T'
%             data.ts_start = vertcat(all_data{i_label});
        case 't'
%             data.ts_end = vertcat(all_data{i_label});
        case 'U'
%             data.stim_upcoming = vertcat(all_data{i_label});
        case 'W'
%             data.switch = vertcat(all_data{i_label});
        otherwise
%             fprintf('Label %s not recognized\n', all_labels{i_label});
    end
end
fprintf('\n');
