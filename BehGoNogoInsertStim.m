function BehGoNogoInsertStim(data, idxs, stim_classes, stim_ids)

idxs = [1, idxs, numel(data.stim_id)];
num_add = numel(stim_classes);

fprintf('stim_class|');
for i = 1:num_add
    fprintf('%c,', data.stim_class(idxs(i):idxs(i+1)-1));
    fprintf('%c,', stim_classes(i));
end
fprintf('%c,', data.stim_class(idxs(i+1):end));
fprintf('\n');

fprintf('stim_id|');
for i = 1:num_add
    fprintf('%c,', data.stim_id(idxs(i):idxs(i+1)-1));
    fprintf('%c,', stim_ids(i));
end
fprintf('%c,', data.stim_id(idxs(i+1):end));
fprintf('\n');
