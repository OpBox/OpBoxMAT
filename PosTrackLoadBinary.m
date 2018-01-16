function pos_data = PosTrackLoadBinary(filename)
% filename = 'kBh-20140909-092050.trk';
% clear all;
% clc;
% 
% % cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\CodeProcessing\PosTracker');
% cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\Processing');
% % cd('C:\Users\Eyal\Dropbox\PostDocResearch\Behavior\CodeProcessing\PosTracker\application.windows32');
% % filename = 'Test-20140328-093320.trk';
% files = dir('*.trk');
% filename = files(end).name;

% The following header & data/ts format depends on the structure that is laid down in the processing file
fid = fopen(filename, 'r');

length_subject_name = fread(fid, 1, 'int32=>double', 'b');
pos_data.subject_name = fread(fid, length_subject_name, 'uint8=>char')';
length_date_time = fread(fid, 1, 'int32=>double', 'b');
pos_data.date_time = fread(fid, length_date_time, 'uint8=>char')';

pos_data.id_box = fread(fid, 1, 'int32=>double', 'b');
pos_data.num_x = fread(fid, 1, 'int32=>double', 'b');
pos_data.num_y = fread(fid, 1, 'int32=>double', 'b');
pos_data.resolution = fread(fid, 1, 'int32=>double', 'b');

size_int = 4;
size_header = 2*size_int + length_subject_name + length_date_time + 4*size_int; % 2 int for length name & date_time string, then strings, then 4 ints for id, num x & y, resolution

% Read in timestamps & data together: This is almost 10 times faster than skip reading, rewinding, and repeating
% fseek(fid, size_header, 'bof');
data = fread(fid, inf, 'uint32=>uint32', 0, 'b'); % fread(FID,SIZE,PRECISION,SKIP,MACHINEFORMAT)
fclose(fid);
% separate data into timestamps & array data
pos_data.ts = double(data(1:2:end));
pos_data.num_ts = numel(pos_data.ts);
data = data(2:2:end);
num_data = numel(data);

% Pull out x & y values/data
pos_data.x_data = false(pos_data.num_x, num_data);
for i = 1:pos_data.num_x
    pos_data.x_data(i, :) = bitget(data,i);
end

pos_data.y_data = false(pos_data.num_y, num_data);
for i = 1:pos_data.num_y
    pos_data.y_data(i, :) = bitget(data,i+pos_data.num_x);
end

% clear data; % will get cleared when exit function

% %% Bin data
% bin_dur = 1e3; % in ms
% bin_edges = 0:bin_dur:max(pos_data.ts);

% %% Analyze ISI
% isi = diff(pos_data.ts);
% % unique(isi)
% % hist(isi)
% fprintf('\n');
% fprintf('%%>Res  =%d: ', pos_data.resolution);
% PrintMeanSumLength(isi>pos_data.resolution);
% fprintf('%%>Res+1=%d: ', pos_data.resolution+1);
% PrintMeanSumLength(isi>(pos_data.resolution+1));
% fprintf('\n');


%% display data
% imagesc(pos_data.x_data)
% imagesc(pos_data.y_data)

% clf;
% h_map = PosTrackDisplayHeatMap(pos_data.x_data', pos_data.y_data');

% temp_x = bsxfun(@times, x_data, (1:num_x)');
% temp_x(temp_x==0) = NaN;
% mean_x = nanmean(temp_x);
% % plot(mean_x);
% 
% temp_y = bsxfun(@times, y_data, (1:num_y)');
% temp_y(temp_y==0) = NaN;
% mean_y = nanmean(temp_y);
% % plot(mean_y);
% 
% % clf;
% PlotPointsByTime(mean_x, mean_y);
% axis equal
% axis([0.5 num_x+0.5, 0.5 num_y+0.5]);
% set(gca, 'YDir', 'Reverse');
% set(gca, 'Color', ColorPicker('lightgray'));
% set(gca, 'Box', 'on');
% set(gca, 'XTick', [], 'YTick', []);
% 
% 
% %% Calculate distance moved
% temp_mean_x = mean_x(~isnan(mean_x) & ~isnan(mean_y));
% temp_mean_y = mean_y(~isnan(mean_x) & ~isnan(mean_y));
% temp_ts = ts(~isnan(mean_x) & ~isnan(mean_y));
% diff_x = diff(temp_mean_x);
% diff_y = diff(temp_mean_y);
% diff_ts = diff(temp_ts);
% distance = (diff_x .^ 2 + diff_y .^ 2) .^ 0.5;
% distance_per_time = distance(:) ./ diff_ts(:); % these calculations assume that isi are equal, which they may not be
% % Can either rebin ts or try to rescale by velocity?
% % May not be critical since trying to find fractal "edge"
% fprintf('Total distance = %d\n', nansum(distance));
% 
% max_dec = 1000;
% distance = zeros(max_dec, 1);
% distance_per_time = zeros(max_dec, 1);
% for dec = 1:max_dec
%     diff_x = diff(temp_mean_x(1:dec:end));
%     diff_y = diff(temp_mean_y(1:dec:end));
%     diff_ts = diff(temp_ts(1:dec:end));
%     temp_distance = (diff_x .^ 2 + diff_y .^ 2) .^ 0.5;
%     distance(dec) = nansum(temp_distance);
%     distance_per_time(dec) = nansum(temp_distance(:) ./ diff_ts(:));
%     fprintf('Distance for dec %2d = %d = %0.3f\n', dec, distance(dec), distance(dec)/distance(1));
% %     fprintf('Distance per time for dec %2d = %d = %0.3f\n', dec, distance_per_time(dec), distance_per_time(dec)/distance_per_time(1));
% end
% 
% clf;
% hold on;
% plot(distance/distance(1), '.-');
% % plot(distance_per_time/distance_per_time(1), 'r.-');
% axis([0.5 max_dec, 0 1]);
% 
% 
% %% Analyze number of points & area covered by subject over time
% area = sum(x_data) .* sum(y_data);
% 
% clf
% plot(ts/1e3/60/60, area);
% axis([-Inf Inf, 0 Inf]);
% PrintMeanSumLength(area<1);
% MedIQR(area);
% title([subject_name ' - ' date_time]);
