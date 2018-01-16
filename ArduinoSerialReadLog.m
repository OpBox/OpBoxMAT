clear all
clc

cd('C:\Doc\Dropbox\Research\Behavior\CodeProcessing\SerialMonitor\application.windows32');
% cd('C:\Doc\Dropbox\Research\Behavior\CodeProcessing\SerialMonitor');
% cd('C:\Doc\Dropbox\Research\Behavior\Processing');

files = dir('*.tmp');
files = dir('*.bin');
filename = files(end-12).name
% filename = 'Test-20150220-204626.bin'

fid = fopen(filename, 'r');
data = fread(fid, 'uint8=>uint8');
% data = fread(fid,inf,'uint32=>uint32',0,'l');
% txt = fscanf(fid, '%s');
fclose(fid);

% data(1:800)';

% idx_start = 2;
% data = data(2:end);
% data(1:20)'
% 
% idx = 1:8:numel(data);
% plot(data(idx), '.');


% plot(diff(find(txt=='~')), '.')
% % char(txt(1:17)')
% 
% 
% size_packet = 17;
% num_packets = round(numel(txt)/size_packet);
% 
% z = reshape(txt(1:num_packets*size_packet), size_packet, num_packets);
% 
% % z = reshape(txt(1:end-14), numel(txt(1:end-14))/17, 17)
% % z(1:size_packet, 1:30);
% % plot(z(1, :), '.')
% clf;
% plot(diff(find(z(:)=='~')), '.')



%% Crop to Packets's
idx_start = find(data=='<');
data = data(idx_start(5):end);
num_bytes = 12; % bytes per line
num_data = floor(numel(data)/num_bytes) * num_bytes;
data = data(1:num_data);
data = reshape(data, num_bytes, num_data/num_bytes);

data1 = double(data(4+(0:3), :));
data2 = double(data(8+(0:3), :));

ts = zeros(1, size(data,2));
val = zeros(size(ts));
for i = 1:4
    ts = ts + data1(i, :)*(256^(4-i));
    val = val + data2(i, :)*(256^(4-i));
end

data(1:num_bytes, 1:num_bytes)
unique(diff(ts))
mean(diff(ts))
% plot(data(1, :))
(ts(end)-ts(1))/1e3/60/60
numel(data)
% unique(diff(val))
% mean(diff(val))
% hist(diff(ts), 100)

%% Plot data
% plot(data(7:8:end), '.')