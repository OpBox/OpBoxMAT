% Nosepoke on 6
% Glue acrylic boxes

clc;
clear all;

cdMatlab;
% cd('..\Research\Behavior\Data\RandIntGoNogo');
% cd('..\Research\Behavior\Data\GoNogoTrack');
cd('..\Research\Behavior\Data\RandIntGoNogoSwitch');
% cd('..\Research\Behavior\Data\RandIntGoNogoOnArduino');
% cd('..\Research\Behavior\Data\AnimalFacilityData\RandIntGoNogoSwitch');

% temp_date = '20140616';
% temp_date = datestr(now, 'yyyymmdd');
temp_date = '*';
temp_anim = '*';

file_mask = [temp_anim '-' temp_date '-*.txt'];
files = dir(file_mask);

%%
num_files = length(files);
ts_start_comp = nan(num_files, 1);
ts_start_arduino = nan(num_files, 1);
ts_end_comp = nan(num_files, 1);
ts_end_arduino = nan(num_files, 1);

for i_file = 1:num_files
    filename = files(i_file).name;
    [data] = BehGoNogoSessionSummary(filename);
    ts_start_arduino(i_file) = data.ts_start;
    if isfield(data, 'ts_end') && any(data.ts_end)
        ts_end_arduino(i_file) = data.ts_end(1);
    end
    if isfield(data, 'msStart')
        ts_start_comp(i_file) = data.msStart;
    end
    ts_end_comp(i_file) = data.msElapsed;
end

%% Plot results
plot(ts_end_arduino, ts_end_comp, '.');
axis equal;
axis([0 Inf 0 Inf]);
diff_ts = ts_end_comp - ts_end_arduino;
hist(diff_ts/1e3);
plot(ts_end_arduino/1e3/60, diff_ts, '.');
mask = ~isnan(diff_ts);
corrcoef(ts_end_arduino(mask), diff_ts(mask));
