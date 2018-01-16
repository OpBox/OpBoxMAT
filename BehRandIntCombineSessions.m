%% Go to Dir
clc;

clear;
cdMatlab;
cd('..\PostDocResearch\Behavior\Data\RandIntGoNogo\TmpFiles\');

%% get file list
file_mask = ['k*-201*-*.txt'];
files = dir(file_mask);
num_files = length(files);

% Separate out by subject

% How to decide on how much time to add to second, etc file?
% if stay true to time then will have a gap of non-recording btw files, which will make rates look lower
% if introduce a minigap between files, then no longer true to time of day, but rates will be more equal
% this will depend on time elapsed, which in early files was saved in a final line, not caught by BehRandIntLoadFile -- would have to decide on gap time as well
% For 1/6/2014 the gap was about 10min, so will try to use minigap of ~1min instead to combine files
ms_gap = 60*1e3; % Based on diff in time start, round to nearest second

for i_file = 1:num_files
    filename = files(i_file).name;
    struct_data(i_file) = BehRandIntLoadFile(filename);
    
%     % ID start time for this file to compare to previous file
%     temp_start = struct_data(i_file).TimeStart;
%     temp_start('/' == temp_start) = 0;
%     temp_start(':' == temp_start) = 0;
%     temp_start = str2num(temp_start);
%     time_start(i_file) = temp_start(4)*60*60 + temp_start(5)*60 + temp_start(6);
%     % time_start is in seconds since the start of the day
%     % will have to get diff between time starts and then convert to ms

end


%% Merge data
new_data = struct_data(1);

merge_field_names = {'ts_np_in', 'ts_np_out', 'ts_lick_in', 'ts_lick_out', 'ts_fluid_on', 'ts_fluid_off', 'ts_free_rwd', 'ts_stim_on', 'ts_stim_off', 'stim_class', 'all_iti', 'ts_iti_end', 'ts_mt_end'};
num_fields = length(merge_field_names);

for i_file = 2:num_files
    new_data.msElapsed = new_data.msElapsed + ms_gap;
    
    for i_field = 1:num_fields
        field_name = merge_field_names{i_field};
        if strncmp(field_name, 'ts', 2)
            ms_to_add = struct_data(i_file-1).msElapsed;
        else
            ms_to_add = 0;
        end
        new_data.(field_name) = [new_data.(field_name); ms_to_add + struct_data(i_file).(field_name)];
    end
    new_data.msElapsed = new_data.msElapsed + struct_data(i_file).msElapsed;
end


%% save new combined file
filename = files(1).name;
filename = [filename(1:end-4), '-Combined', filename(end-3:end)];

fid = fopen(filename, 'w');
if -1 == fid
    fprintf ('Problem opening file: %s\n', filename)
%     return;
else
    
    all_field_names = fieldnames(new_data);
    num_fields = length(all_field_names);

    for i_field = 1:num_fields
        fprintf(fid, '%s: ', all_field_names{i_field});
        temp_data = new_data.(all_field_names{i_field});
        
%         whos temp_data
        if isa(temp_data, 'char')
            fprintf(fid, '%s', temp_data);
%         elseif isa(temp_data, 'int64')
        else % assume numeric value: double or int
            if 1 == length(temp_data)
                fprintf(fid, '%d', temp_data);
            else
                fprintf(fid, '%d,', temp_data);
            end
        end
        fprintf(fid, '%c%c', 13, 10);
%         fprintf(fid, '\r\n');
%         x = sprintf('\r\n'); int16(x)
    end
end
fclose(fid);
