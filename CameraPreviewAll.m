all_cams = imaqhwinfo('winvideo');
num_cams = numel(all_cams.DeviceIDs);
% num_cams = 8;

num_rows = 240;
num_cols = 320;


%% Set up images
FigDocked;
clf;
grid_axes = AxesGrid(floor(sqrt(num_cams)), ceil(num_cams/floor(sqrt(num_cams))));

for i_grid = 1:num_cams
    axes(grid_axes(i_grid));
    h_img(i_grid) = image(zeros(num_rows, num_cols));
    axis equal tight;
    
end

%% Set up cameras
for i_cam = 1:num_cams
    vid_format = sprintf('MJPG_%dx%d', num_cols, num_rows);
    if ~sum(strcmpi(vid_format, all_cams.DeviceInfo(i_cam).SupportedFormats))
        vid_format = sprintf('YUY2_%dx%d', num_cols, num_rows);
    end
    cams(i_cam) = videoinput('winvideo', all_cams.DeviceIDs{i_cam}, vid_format);
end


%% Preview cams
for i_cam = 1:num_cams
    preview(cams(i_cam), h_img(i_cam));
end


% %% Reset all
% imaqreset

