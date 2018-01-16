% function [heat_map, h_map] = PosTrackDisplayHeatMap(x_data, y_data)  % Prior passed in data, now just map
function [heat_map, h_map] = PosTrackDisplayHeatMap(heat_map)

% % Calculate Heat Map
% % With linear assumptions, here is a heat map:
% % Could weight it by diff ts/duration of bin, but then not clear that stayed in same place for that time
% x_heat = sum(x_data,2)/size(x_data,2);
% y_heat = sum(y_data,2)/size(y_data,2);
% heat_map = y_heat * x_heat';

% clf;
% cmap = colormap('jet');
ColormapParula();
% h = image(heat_map * size(cmap,1));
h_map = image(heat_map);
axis equal
axis tight
% set(gca, 'XTick', 1:length(x_heat));
% set(gca, 'YTick', 1:length(y_heat));
set(gca, 'XTick', []);
set(gca, 'YTick', []);
set(gca, 'Clim', [0 1]);
set(h_map, 'CDataMapping', 'scaled');

% h_bar = colorbar;
% set(h_bar, 'CLim', [0 1]);
% set(h_bar, 'YLim', [0 1]);
% have to figure out how to normalize this from 0-100%

