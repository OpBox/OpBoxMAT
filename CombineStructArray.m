function [combined_struct] = CombineStructArray(struct1, struct2)

[num_rows, num_cols] = size(struct1);

combined_struct = cell(size(struct1));

for i_row = 1:num_rows
    for i_col = 1:num_cols
        num_array = numel(struct1{i_row, i_col});
        for i_pos = 1:num_array
            struct2cell(struct1{i_row, i_col}(i_pos), 
            summary_data{i_sum} = cell2struct(temp_data, field_names, 1);
        end
    end
end


