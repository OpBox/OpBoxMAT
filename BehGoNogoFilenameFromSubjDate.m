function [filename] = BehGoNogoFilenameFromSubjDate(subj, str_date)

% file_mask = sprintf('%s-%s-*.%s', subj, str_date, ext);
file_mask = sprintf('%s-%s-*.%s', subj, str_date, 'txt');
files = dir(file_mask);
if numel(files) > 1
    [val, idx] = sort([files.bytes]);
    filename = files(idx(end)).name;
elseif numel(files) == 1
    filename = files.name;
else
    filename = [];
end
