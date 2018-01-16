function struct_data = BehRandIntLoadFile_StructuredFields_ColonDelimOnly(filename)

% takes about 12ms per file as of 2014/01/24 as script, 5-6ms as function

% clear all;
% cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\Data\RandIntGoNogo\TmpFiles')
% filename = 'kBa-20140106-120250.txt';
% % fprintf('Filename: %s\n', filename');

%% Load file
fid = fopen(filename, 'r');
if fid == -1
    fprintf ('Problem opening file: %s\n', filename)
    return;
end
file_char = fread(fid, inf, 'uchar=>char'); % faster than fscanf. textread fails on string data. Returns as double for some weird reason
fclose(fid);
file_char = file_char'; % for strfind below

%% Parse data
flags = {'Subject', 'Protocol', 'TimeStart', 'PerGoStim', 'MaxMT', 'ts_np_in', 'ts_np_out', 'ts_lick_in', 'ts_lick_out', 'ts_fluid_on', 'ts_fluid_off', 'ts_free_rwd', 'ts_stim_on', 'ts_stim_off', 'stim_class', 'all_iti', 'ts_iti_end', 'ts_mt_end', 'msElapsed'};

num_flags = length(flags);

% idx_newlines = find(file_char==13 | );
idx_newlines = find(13 == file_char | ';' == file_char); % new line or semi colon may serve as delimiter (at least in earliest files)

for i_flag = 1:num_flags
    label = flags{i_flag};
    flag = [label ': '];
    idx_flag = strfind(file_char, flag);

    if isempty(idx_flag)
        data = NaN;
    else
        eol = min(idx_newlines(idx_newlines>idx_flag(1)));

        data = file_char(idx_flag(1)+length(flag):eol-1);

        if ~sum(isletter(data)) && ~sum(':' == data)
            data(',' == data) = 0;
            data = sscanf(data, '%ld');
        end
    end
    struct_data.(label) = data;
end

