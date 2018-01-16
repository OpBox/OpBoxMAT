clear all;

cd('C:\Doc\Dropbox\Research\Behavior\Processing');
files = dir('*.trk');
filename = files(end).name;

fprintf('%s\n', filename);
fid = fopen(filename, 'r');

length_subject_name = fread(fid, 1, 'int32=>double', 'b');
data.subject_name = fread(fid, length_subject_name, 'uint8=>char')';
length_date_time = fread(fid, 1, 'int32=>double', 'b');
data.date_time = fread(fid, length_date_time, 'uint8=>char')';

data.id_box = fread(fid, 1, 'int32=>double', 'b');
data.num_x = fread(fid, 1, 'int32=>double', 'b');
data.num_y = fread(fid, 1, 'int32=>double', 'b');
data.resolution = fread(fid, 1, 'int32=>double', 'b');

size_int = 4;
size_header = 2*size_int + length_subject_name + length_date_time + 4*size_int; % 2 int for length name & date_time string, then strings, then 4 ints for id, num x & y, resolution

% Read in timestamps & data together: This is almost 10 times faster than skip reading, rewinding, and repeating
% fseek(fid, size_header, 'bof');
% temp_data = fread(fid, inf, 'uint32=>uint32', 0, 'b'); % fread(FID,SIZE,PRECISION,SKIP,MACHINEFORMAT)
temp_data = fread(fid, inf, 'int32=>int32', 0, 'b'); % fread(FID,SIZE,PRECISION,SKIP,MACHINEFORMAT)
fclose(fid);

data.ts = double(temp_data(1:2:end));
data.num_ts = numel(data.ts);
data.data = temp_data(2:2:end);


%% Plot data
clf;
subplot(1,3,1:2);
plot(data.ts/1e6/60/60/24, data.data, '.');
datetick('x');
axis([0 Inf -Inf Inf]);

subplot(1,3,3);
hist(diff(data.ts), 100)
fprintf('Median ITI = %.3f ms\n', median(diff(data.ts))/1e3);
fprintf('Median diff ITI = %dus\n', median(diff(unique(diff(data.ts)))));