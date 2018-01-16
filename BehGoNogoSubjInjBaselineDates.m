function [pre_dates, post_dates] = BehGoNogoSubjInjBaselineDates(txt, subjs, dates)

[num_injs, num_subjs] = size(dates);

pre_dates = cell(size(dates));
post_dates = cell(size(dates));
target_str = 'Beh w/E'; % leave unspecified for ephys & EEG?
% target_str = 'RandIntoGoNogo (Go1Nogo2) w/EEG';

for i_subj = 1:num_subjs
    i_col = find(strcmp(txt(1, :), subjs(i_subj))) + 1; % Shift 1 as name is over weights, not activity for the day
    for i_inj = 1:num_injs
        if ~isempty(dates{i_inj, i_subj})
            date_str = datestr(datenum(dates{i_inj, i_subj}, 'yyyymmdd'), 'ddd mm/dd/yy');
            date_str = regexprep(date_str, ' [0]', ' ');
            date_str = regexprep(date_str, '/[0]', '/');
            idx_row = find(strcmp(txt(:, 1), date_str));
            if isempty(idx_row)
                fprintf('No date entry found for subject %s for inj %s\n', subjs{i_subj}, injs{i_inj});
                continue
            else
                if numel(idx_row) > 1
                    idx_row = idx_row(end);
                end
                for i_row = idx_row:-1:1
                    if strncmpi(txt(i_row, i_col), target_str, numel(target_str))
%                         txt{i_row, 1}
%                         try
                            pre_dates{i_inj, i_subj} = datestr(datenum(txt{i_row, 1}(5:end)), 'YYYYmmdd');
                            break;
%                         catch
%                             keyboard
%                         end
                    end
                end
                for i_row = idx_row:size(txt,1)
                    if strncmpi(txt(i_row, i_col), target_str, numel(target_str))
                        post_dates{i_inj, i_subj} = datestr(datenum(txt{i_row, 1}(5:end)), 'YYYYmmdd');
                        break;
                    end
                end
            end
        end
    end
end

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
