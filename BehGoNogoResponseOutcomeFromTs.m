function [data] = BehGoNogoResponseOutcomeFromTs(data)

% Convert event timestamps into a trial based structure
% Can determine response and outcome by what happend after each stim event
[sort_ts, sort_ids] = BehGoNogoSortTS(data);

sort_ids = [sort_ids(:); 'X'];  % Add second X to end since ts_stim may end before npout and response

idx_stim = find(sort_ids == 'S');

data.response = sort_ids(idx_stim + 2); % +1 will be npout. Does not consider too slow responses: RT window or MT window--or missed packets

data.outcome = data.response;
data.outcome(data.stim_class == 'G' & data.response == 'L') = 'H';
data.outcome(data.stim_class ~= 'G' & data.response == 'L') = 'F';
data.outcome(data.stim_class == 'G' & data.response ~= 'L') = 'M';
data.outcome(data.stim_class ~= 'G' & data.response ~= 'L') = 'R';

