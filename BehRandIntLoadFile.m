function struct_data = BehRandIntLoadFile(filename)

% takes ~12ms per file as of 2014/01/24 as script, 5-6ms as function

% clear all;
% % cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\Data\RandIntGoNogo\TmpFiles')
% cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\Data\GoNogoTrack');
% filename = 'kCb-20140130-105537.txt';
% % % fprintf('Filename: %s\n', filename');

%% Load file
fid = fopen(filename, 'r');
if fid == -1
    fprintf ('Problem opening file: %s\n', filename)
    struct_data = [];
    return;
end
file_char = fread(fid, inf, 'uchar=>char'); % faster than fscanf. textread fails on string data. Returns as double for some weird reason
fclose(fid);
% file_char = file_char'; % for strfind below

%% Parse data
% Field name from newline to | pipe-space, data from space to end of line

idx_newlines = find(file_char==13);
idx_newlines = [-1; idx_newlines];
idx_delim = find(file_char == '|');

% hack for early files
if isempty(idx_delim)
    struct_data = BehRandIntLoadFile_StructuredFields_ColonDelimOnly(filename);
    return
end

num_newlines = length(idx_newlines);
for i_line = 1:num_newlines-1
    label = file_char(idx_newlines(i_line)+2:idx_delim(i_line)-1);
    label = label(:)'; % comes in as col vector, convert to row

    data = file_char(idx_delim(i_line)+2:idx_newlines(i_line+1)-1);
    if sum(isletter(data)) || sum(':' == data)
        % text data, change to row from column vector
        data = data(:)';
    else
        % numerical data, pull it out
        data(',' == data) = 0;
        data = sscanf(data, '%ld');
    end
    if label(1) ~= '<' % end of temp file flag
        struct_data.(label) = data;
    end
end

