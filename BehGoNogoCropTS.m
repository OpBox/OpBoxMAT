function [crop_data] = BehGoNogoCropTS(data, crop_sec)

%% Determine boundary edges
crop_ms = crop_sec * 1e3;

% Set subject name as string for error messages
str_subject = data.Subject;
if isnumeric(str_subject)
    str_subject = num2str(str_subject);
end

if isfield(data, 'ts_start') && ~isempty(data.ts_start)
    crop_ms = crop_ms + double(data.ts_start);
%     data.old_ts_start = data.ts_start; % need to preserve this so don't subtract it away before doing all subtractions
end

% What if end is less than requested, need to modify "end"
if isfield(data, 'ts_end')
    if data.ts_end < crop_ms(end)
        fprintf('Session for subject %s, date %s ended at %d before desired crop end %d\n', str_subject, data.DateTimeStart(1:8), data.ts_end, crop_ms(end));
        crop_ms(end) = data.ts_end;
    end
else
    fprintf('No ts_end for subject %s, date %s\n', str_subject, data.DateTimeStart(1:8));
    max_ts = BehGoNogoMaxTS(data);
    crop_ms(end) = min(crop_ms(end), max_ts);
end
data.crop_ms = crop_ms;

%% Go through and crop each ts, but when get to ts_stim make sure to adjust trial arrays as well
crop_data = data;
field_names = fieldnames(data);
stim_field_names = {'stim_class', 'stim_id', 'response', 'outcome'}; % also all_iti
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
                        fprintf('Field %s does not have the right number of entries vs. %s for crop for subject %s, date %s\n', temp_name, temp_field_name, str_subject, data.DateTimeStart(1:8));
                    end
                else
                    fprintf('Field %s does not exist for subject %s, date %s\n', temp_name, str_subject, data.DateTimeStart(1:8));
                end
            end
        end
    end
end

% Reassert boundaries if they have been cropped out
if isempty(crop_data.ts_start)
    crop_data.ts_start = crop_ms(1);
end
if isempty(crop_data.ts_end)
    crop_data.ts_end = crop_ms(end);
end
