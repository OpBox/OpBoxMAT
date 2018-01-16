function [sort_ts, sort_labels] = BehGoNogoTsAll(data)

all_ts = [];
all_labels = [];

field_names = fieldnames(data);
for i_field = 1:numel(field_names)
    field = field_names{i_field};
    
    if strncmp(field, 'ts_', 3)
        temp_ts = data.(field);
        all_ts = [all_ts; temp_ts(:)];
        switch field
            case 'ts_trial_on'
                token = 'A';
            case 'ts_trial_off'
                token = 'a';
            case 'ts_np_in'
                token = 'N';
            case 'ts_np_out'
                token = 'n';
            case 'ts_lick_in'
                token = 'L';
            case 'ts_lick_out'
                token = 'l';
            case 'ts_reward_on'
                token = 'R';
            case 'ts_reward_off'
                token = 'r';
            case 'ts_free_rwd'
                token = 'F';
            case 'ts_stim_on'
                token = 'S';
            case 'ts_stim_off'
                token = 's';
            case 'ts_iti_end'
                token = 'i';
            case 'ts_mt_end'
                token = 'm';
            case 'ts_start'
                token = 'T';
            case 'ts_end'
                token = 't';
            case 'ts_servo_on'
                token = 'E';
            case 'ts_servo_off'
                token = 'e';
            case 'ts_opto_on'
                token = 'P';
            case 'ts_opto_off'
                token = 'p';
            case 'ts_distract_on'
                token = 'D';
            case 'ts_distract_off'
                token = 'd';
            otherwise
                fprintf('Unrecognized timestamp field %s\n', field);
                token = 'X';
        end
        all_labels = [all_labels;  token * ones(numel(data.(field)), 1)];
    end
end

% Now sort the timestamps and labels into session order
[sort_ts, sort_idx] = sort(all_ts);
sort_labels = all_labels(sort_idx);
