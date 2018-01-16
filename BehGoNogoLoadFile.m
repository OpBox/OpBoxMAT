function struct_data = BehGoNogoLoadFile(filename)

% clear all;
% cd('C:\Doc\Dropbox\PostDocResearch\Behavior\Data\RandIntGoNogoOnArduino');
% filename = 'kBa-20140522-122835.txt';
% 
% % fprintf('Filename: %s\n', filename');

%% Load file
if ~exist(filename, 'file')
    fprintf ('File %s not found in %s\n', filename, pwd);
    struct_data = [];
    return;
else
    fid = fopen(filename, 'r');
    if fid == -1
        fprintf ('Problem opening file %s within %s\n', filename, pwd);
        struct_data = [];
        return;
    end
end
file_char = fread(fid, inf, 'uchar=>char'); % faster than fscanf. textread fails on string data. Returns as double for some weird reason
fclose(fid);
% file_char = file_char'; % for strfind below

%% Parse data
% Field name from newline to | pipe-space, data from space to end of line which is \13\10

idx_newlines = find(file_char==13);
idx_newlines = [-1; idx_newlines];
idx_delim = find(file_char == '|'); % Delimiter
post_delim = 1; % if data starts immediately after delim

%% Delimiter hacks for earlier files
% Hack for earliest files that used ":" as delimiter instead of "|" . Changed due to wanting to include : in time text
if isempty(idx_delim)
    struct_data = BehRandIntLoadFile_StructuredFields_ColonDelimOnly(filename);
    return
end

% Hack for early files that used "| " as a delimiter instead of "|" . Changed to save unnecessary char
if mean(file_char(idx_delim+1) == ' ') > 0.9
    post_delim = 2;
end

%% Process text looking for fields
num_newlines = length(idx_newlines);
for i_line = 1:num_newlines-1
    label = file_char(idx_newlines(i_line)+2:idx_delim(i_line)-1); % +2 to account for /13/10 end of line. -1 to end right before delimiter
    label = label(:)'; % comes in as col vector, convert to row

    data = file_char(idx_delim(i_line)+post_delim:idx_newlines(i_line+1)-1); % +1 if only delim, +2 if delim & space. -1 to end before new line
    if sum(isdigit(data) | ',' == data) == numel(data)
        % All text based numerical data (digits or comma), convert from string to numbers
        % data = sscanf(data, '%ld,');  % Scans as float/double in R2013a, int64 in R2015b, most functions will expect double
        data = sscanf(data, '%f,');  % Scans as float/double in R2013a, int64 in R2015b, most functions will expect double
    else
        % text data, eliminate commas and change to row from column vector
        data = data(data ~= ',');
        data = data(:)';
    end
    
%     if sum(',' == data)
%         % array data: numerical or char
%         if sum(isletter(data))
%             % Array Char data
%             data = data(',' ~= data);
%             data = sscanf(data, '%c ');
%             data = data(:);
%         else
%             % Array Numerical data
%             data(',' == data) = 0;
%         end
%     elseif isdigit(data) == numel(data)
%         % numerical, non array data
%     else
%         % text data, change to row from column vector
%         data = data(:)';
%     end
    if label(1) ~= '<' % end of temp file flag in some files
        struct_data.(label) = data;
    end
end

