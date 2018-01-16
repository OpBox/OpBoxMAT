function BehGoNogoInsertStimResp(data, idxs, stim_class, stim_id, response, outcome)

idxs = [1, idxs, numel(data.stim_id)];
num_add = numel(stim_classes);

field_names = {'stim_class', 'stim_id', 'response', 'outcome'};

for i_field = 1:numel(field_names)

    field_name = field_names{i_field};
    fprintf('%s|', field_name);
    for i = 1:num_add
        fprintf('%c,', data.(field_name)(idxs(i):idxs(i+1)-1));
        eval(['fprintf(''%c,'', ', stim_classes(i));
    end
    fprintf('%c,', data.stim_class(idxs(i+1):end));
    fprintf('\n');

    for i = 1:num_remove
        fprintf('%c,', data.(field_name)(idxs(i)+1:idxs(i+1)-1));
    end
    fprintf('%c,', data.(field_name)(idxs(i+1)+1:end));
    fprintf('\n');
end

% fprintf('stim_class|');
% for i = 1:num_add
%     fprintf('%c,', data.stim_class(idxs(i):idxs(i+1)-1));
%     fprintf('%c,', stim_classes(i));
% end
% fprintf('%c,', data.stim_class(idxs(i+1):end));
% fprintf('\n');
% 
% fprintf('stim_id|');
% for i = 1:num_add
%     fprintf('%c,', data.stim_id(idxs(i):idxs(i+1)-1));
%     fprintf('%c,', stim_ids(i));
% end
% fprintf('%c,', data.stim_id(idxs(i+1):end));
% fprintf('\n');
% 
% fprintf('response|');
% for i = 1:num_add
%     fprintf('%c,', data.response(idxs(i):idxs(i+1)-1));
%     fprintf('%c,', responses(i));
% end
% fprintf('%c,', data.response(idxs(i+1):end));
% fprintf('\n');
% 
% fprintf('outcome|');
% for i = 1:num_add
%     fprintf('%c,', data.outcome(idxs(i):idxs(i+1)-1));
%     fprintf('%c,', outcomes(i));
% end
% fprintf('%c,', data.outcome(idxs(i+1):end));
% fprintf('\n');


%% Remove StimResp
idxs = [0, idxs, numel(data.stim_id)];
num_remove = numel(stim_classes);

field_names = {'stim_class', 'stim_id', 'response', 'outcome'};

for i_field = 1:numel(field_names)
    field_name = field_names{i_field};
    fprintf('%s|', field_name);
    for i = 1:num_remove
        fprintf('%c,', data.(field_name)(idxs(i)+1:idxs(i+1)-1));
    end
    fprintf('%c,', data.(field_name)(idxs(i+1)+1:end));
    fprintf('\n');
end

fprintf('stim_class|');
for i = 1:num_remove
    fprintf('%c,', data.stim_class(idxs(i)+1:idxs(i+1)-1));
end
fprintf('%c,', data.stim_class(idxs(i+1)+1:end));
fprintf('\n');

fprintf('stim_id|');
for i = 1:num_remove
    fprintf('%c,', data.stim_id(idxs(i):idxs(i+1)-1));
    fprintf('%c,', stim_ids(i));
end
fprintf('%c,', data.stim_id(idxs(i+1):end));
fprintf('\n');

fprintf('response|');
for i = 1:num_remove
    fprintf('%c,', data.response(idxs(i):idxs(i+1)-1));
    fprintf('%c,', responses(i));
end
fprintf('%c,', data.response(idxs(i+1):end));
fprintf('\n');

fprintf('outcome|');
for i = 1:num_remove
    fprintf('%c,', data.outcome(idxs(i):idxs(i+1)-1));
    fprintf('%c,', outcomes(i));
end
fprintf('%c,', data.outcome(idxs(i+1):end));
fprintf('\n');
