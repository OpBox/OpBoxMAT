function OpBoxPhys_ComparePSD(temp_date, temp_anim)

dir_phys = 'D:\Dropbox (KimchiLab)\KimchiLabData\EEG\DeliriumRats\Spectrograms';
dir_phys = 'D:\Dropbox (KimchiLab)\KimchiLabData\EEG\DeliriumMice\Spectrograms';

if nargin < 1
    temp_anim = '*';
    temp_date = datestr(now, 'yyyymmdd');
    file_mask = [temp_anim '*-' temp_date];
elseif numel(regexp(temp_date, '-'))
    file_mask = temp_date;
elseif numel(regexp(temp_date, '[a-zA-Z]'))
    % Then date include letters = anim name
    % If name also exists, swap
    if exist('temp_anim', 'var')
        temp = temp_anim;
        temp_anim = temp_date;
        temp_date = temp;
    else
        temp_anim = temp_date;
        temp_date = [];
    end
    file_mask = [temp_anim '*-' temp_date];
else
    if ~exist('temp_anim', 'var')
        temp_anim = [];
    end
    file_mask = [temp_anim '*-' temp_date];
end
file_mask = [file_mask, '*.mat'];

cd(dir_phys);
files = dir(file_mask);
num_files = length(files);
fprintf('%d files found\n', num_files);

num_ch = 4;
freq_bands = EEGFreqBands();
crop_f = [freq_bands.delta(1) freq_bands.high_gamma(end)];
crop_hr = [0 4];
crop_sec = crop_hr * 60 * 60;

axis_freq = crop_f;
axis_power = [-55 -30];
% axis_freq = [0 10];
% axis_power = [-40 -20];

clf;
grid_axes = AxesGrid(1, num_ch);
colors = ColorGradientRGB(num_files);

for i_ch = 1:num_ch
    axes(grid_axes(i_ch));
    hold on;
    set(gca, 'Color', ColorPicker('lightgray'));
    axis([axis_freq, axis_power]);
end

for i_file = 1:num_files
    filename = files(i_file).name;
    
    load(filename, 't', 'f', 'p');
    mask_t = crop_sec(1) <= t & t <= crop_sec(end);
%     mask_t = true(size(t));
    mask_f = crop_f(1) <= f & f <= crop_f(end);
    t = t(mask_t);
    f = f(mask_f);
    p = p(mask_f, mask_t, :);
    p = squeeze(mean(p, 2));
        
    for i_ch = 1:size(p, ndims(p))
        axes(grid_axes(i_ch));
        
        if ~isempty(p(:, i_ch))
            h(i_ch, i_file) = plot(f, 10*log10(p(:, i_ch)));
            set(h(i_ch, i_file), 'Color', colors(i_file, :));
        end
        
        
        if i_file == num_files && i_ch == num_ch
            legend(h(i_ch, :), {files.name});
        end
        
    end
    
  
end
