function [max_ts] = BehGoNogoMaxTS(data)

field_names = fieldnames(data);
num_fields = length(field_names);
temp_ts = [];
for i_field = 1:num_fields
    temp_name = field_names{i_field};
    if strncmp('ts_', temp_name', 3)
         temp_ts = [temp_ts; data.(temp_name)];
    end
end

max_ts = max(temp_ts);