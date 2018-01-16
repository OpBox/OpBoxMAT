function [dates, subjs, injs, col_subjs] = BehGoNogoSubjInjDates(txt, subjs, injs)

num_subjs = numel(subjs);
num_injs = numel(injs);

dates = cell(num_injs, num_subjs);
col_subjs = nan(1, num_subjs);

for i_subj = 1:num_subjs
    i_col = find(strcmp(txt(1, :), subjs(i_subj))) + 1; % Shift 1 as name is over weights, not activity for the day
    col_subjs(i_subj) = i_col;
    for i_inj = 1:num_injs
        idx_row = find(strncmp(txt(:, i_col), injs{i_inj}, length(injs{i_inj})));
        if isempty(idx_row)
%             fprintf('No date entry found for subject %s for inj %s\n', subjs{i_subj}, injs{i_inj});
            continue
        else
            val_dates = nan(length(idx_row), 1);
            for i = 1:numel(idx_row)
                temp_text = txt{idx_row(i), 1}(5:end);
                if ~isempty(str2num(temp_text))
                    val_dates(i) = datenum(temp_text);
%                 else
%                     fprintf('Date %s from %s not formatted correctly.\n', txt{idx_row(i), 1}(5:end), txt{idx_row(i), 1});
                end
            end
            idx_row = idx_row(val_dates <= datenum(date));
%             idx_row = idx_row(val_dates <= datenum(date)-1); % don't include today, since often analyzing while running subjects
            if isempty(idx_row)
                continue;
            else
%                 % Grab middle file
%                 dates{i_inj, i_subj} = datestr(datenum(txt{idx_row(median(1:numel(idx_row))), 1}(5:end)), 'YYYYmmdd');
                % Grab last/most recent file
                dates{i_inj, i_subj} = datestr(datenum(txt{idx_row(end), 1}(5:end)), 'YYYYmmdd');
%                 % Grab first file
%                 dates{i_inj, i_subj} = datestr(datenum(txt{idx_row(1), 1}(5:end)), 'YYYYmmdd');
            end
        end
    end
end

%% Remove empty rows & cols
for i_subj = 1:num_subjs
    for i_inj = 1:num_injs
        temp_empty(i_inj, i_subj) = isempty(dates{i_inj, i_subj});
    end
end

% Eliminate empty rows
crop_rows = sum(temp_empty, 2) ~= size(temp_empty,2);
dates = dates(crop_rows, :);
injs = injs(crop_rows);
% num_injs = numel(injs);
temp_empty = temp_empty(crop_rows, :);

% Eliminate empty cols
crop_cols = sum(temp_empty, 1) ~= size(temp_empty,1);
dates = dates(:, crop_cols);
subjs = subjs(crop_cols);
% num_subjs = numel(subjs);
col_subjs = col_subjs(crop_cols);

