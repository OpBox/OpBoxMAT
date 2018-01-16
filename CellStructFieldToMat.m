function [vals] = CellStructFieldToMat(struct_data, fieldname)

[num_rows, num_cols, num_layers] = size(struct_data);
vals = nan(size(struct_data));
for i_row = 1:num_rows
    for i_col = 1:num_cols
        for i_layer = 1:num_layers
           if ~isempty(struct_data{i_row, i_col, i_layer}) && ~isempty(struct_data{i_row, i_col, i_layer}.(fieldname))
                vals(i_row, i_col, i_layer) = struct_data{i_row, i_col, i_layer}.(fieldname);
           end
        end
    end
end
