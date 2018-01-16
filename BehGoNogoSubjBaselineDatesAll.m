function [dates, subjs] = BehGoNogoSubjBaselineDatesAll(txt, subjs)

num_subjs = numel(subjs);

dates = cell(num_subjs, 1);
target_str = 'Beh w/EEG';
% target_str = 'RandIntoGoNogo (Go1Nogo2) w/EEG';

for i_subj = 1:num_subjs
    i_col = find(strcmp(txt(1, :), subjs(i_subj))) + 1; % Shift 1 as name is over weights, not activity for the day
    idx_target = find(strncmp(txt(:, i_col), target_str, numel(target_str)));
    dates{i_subj} = cell(1, numel(idx_target));
    for i = 1:numel(idx_target)
        temp_str = txt{idx_target(i), 1};
        temp_str = temp_str(5:end);
        dates{i_subj}{i} = datestr(datenum(temp_str), 'YYYYmmdd');
    end
end

% Remove empty entries without target sessions
mask_valid = ~cellfun(@isempty, dates);
dates = dates(mask_valid);
subjs = subjs(mask_valid);

% %% Remove empty rows & cols
% for i_subj = 1:num_subjs
%     for i_inj = 1:num_injs
%         temp_empty(i_inj, i_subj) = isempty(dates{i_inj, i_subj});
%     end
% end
% 
% % Eliminate empty rows
% crop_rows = sum(temp_empty, 2) ~= size(temp_empty,2);
% dates = dates(crop_rows, :);
% injs = injs(crop_rows);
% num_injs = numel(injs);
% temp_empty = temp_empty(crop_rows, :);
% 
% % Eliminate empty cols
% crop_cols = sum(temp_empty, 1) ~= size(temp_empty,1);
% dates = dates(:, crop_cols);
% subjs = subjs(crop_cols);
% num_subjs = numel(subjs);
% 
