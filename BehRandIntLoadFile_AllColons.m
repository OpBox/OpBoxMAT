function struct_data = BehRandIntLoadFile(filename)

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

idx_newlines = [-1; find(13 == file_char)];
idx_colons = find(':' == file_char);
num_lines = length(idx_newlines)-1;

x = repmat(idx_colons, 1, num_lines);
y = repmat(idx_newlines(1:end-1)', length(idx_colons), 1);
z = x .* (x>y);
z(0==z) = NaN;
first_colons = nanmin(z);

% for i_line = 1:num_lines-1
%     first_colons(i_line) = 1;
% end

for i_line = 1:num_lines
    idx_sol = idx_newlines(i_line) + 2;
    % use first colon on each line (mixed up by saving time as HH:MM:SS)
    idx_col = first_colons(i_line);
    idx_eol = idx_newlines(i_line+1);

    label = file_char(idx_sol:idx_col-1)';
    if '<' == label(1)
        % comment line
        % but if has "End" / "msElapsed" text, then save this
        % hack for early files...
        label = 'msElapsed';
        data = file_char(idx_col+2:idx_eol-1)';
        idx_label = strfind(data, label);
        if idx_label > 0
            idx_semi = find(';' == data);
            idx_semi = idx_semi(idx_semi > idx_label);
            data = data(idx_label + length(label)+2:idx_semi(1)-1);
            data = str2double(data);
            struct_data.(label) = data;
        end
        continue;
    end
    
    data = file_char(idx_col+2:idx_eol-1)';
    % Convert data into numeric data if appropriate
    if ~sum(isletter(data)) && ~sum(':' == data)
        data(',' == data) = 0;
        data = sscanf(data, '%ld');
    end
    
    struct_data.(label) = data;
end



