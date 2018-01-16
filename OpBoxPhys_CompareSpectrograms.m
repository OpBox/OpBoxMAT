function OpBoxPhys_CompareSpectrograms(temp_date, temp_anim)

dir_phys = 'D:\Dropbox (KimchiLab)\KimchiLabData\EEG\DeliriumRats\Spectrograms';

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

num_ch = 3;
freq_bands = EEGFreqBands();
crop_f = [freq_bands.delta(1) freq_bands.high_gamma(end)];
crop_hr = [0 4];
crop_sec = crop_hr * 60 * 60;

ColormapParula;
axis_power = [-55 -30];
font_size = 8;

grid_axes = AxesGrid(num_ch, num_files);
for i_file = 1:num_files
    filename = files(i_file).name;
    
    load(filename, 't', 'f', 'p');
    mask_t = crop_sec(1) <= t & t <= crop_sec(end);
%     mask_t = true(size(t));
    mask_f = crop_f(1) <= f & f <= crop_f(end);
    t = t(mask_t);
    f = f(mask_f);
    p = p(mask_f, mask_t, :);
        
    for i_ch = 1:size(p, ndims(p))
        axes(grid_axes(i_ch, i_file));
        surf(t/(MsPerDay()/1e3), f, 10*log10(abs(squeeze(p(:, :, i_ch)))),'EdgeColor','none');
        axis xy; view(0,90);
        caxis(axis_power);
        axis tight;
%             datetick('x');
        set(gca, 'FontSize', font_size);
        if i_file == 1
            ylabel('Freq (Hz)');
            set(get(gca, 'YLabel'), 'FontSize', font_size)
        end
    end
end




% % EEG Figures from different states of same rat
% 
% clear all
% clc;
% 
% %% Go to directory
% cdDropbox;
% cd('KimchiLabData\EEG\DeliriumRats\');
% 
% %% Define subjects/dates
% desc = {'Baseline', 'Scopolamine', 'Baseline', 'LPS'};
% % subjs = {'kCn', 'kCn', 'kCn', 'kCn'}';
% % dates = {'20150422', '20150423', '20150520', '20150521'};
% subjs = {'kCl', 'kCl', 'kCl', 'kCl'}';
% dates = {'20150422', '20150423', '20150507', '20150508'};
% 
% dirs = {
%     [cdDropbox '\KimchiLabData\EEG\DeliriumRats'];
%     [cdDropbox '\KimchiLabData\EEG\DeliriumRats'];
%     [cdDropbox '\KimchiLabData\EEG\DeliriumRats'];
%     [cdDropbox '\KimchiLabData\EEG\DeliriumRats'];
% };
% 
% 
% %% Load EEG/EMG info
% num_subj = numel(subjs);
% 
% clear data
% for i_subj = 1:num_subj
%     cd(dirs{i_subj});
%     file_mask = [subjs{i_subj} '*-' dates{i_subj} '-*.bin'];
%     files = dir(file_mask);
% 
%     if isempty(files)
%         fprintf('File not found\n');
%         continue;
%     end
%     
%     filename = files(end).name;
%     fprintf('%s\n', filename);
%     
%     data(i_subj) = OpBoxPhys_LoadData(filename);
% end
% 
% %% Graph info
% % starts = [65.2 3003 4013.5 8.31e3];
% starts = [610 600 3600 3600];
% dur = 5;
% 
% chan_names = {'EEG', 'EEG2', 'EMG'};
% colors = {ColorPicker('blue'), ColorPicker('turquoise'), ColorPicker('red')};
% eeg_lim = [200, 200, 200, 200];
% emg_lim = repmat(500, num_subj, 1);
% 
% clf;
% [grid_eeg, grid_emg] = AxesPeth(num_subj/2, 2, [0 0.99 0 0.96], [0.22 0.17 0.02], 0.5);
% grid_eeg = grid_eeg';
% grid_emg = grid_emg';
% 
% 
% for i_subj = 1:num_subj
%     ts_start = starts(i_subj) + data(i_subj).ts(1);
%     
%     temp_mask = ts_start <= data(i_subj).ts & data(i_subj).ts <= (ts_start+dur);
% 
%     axes(grid_eeg(i_subj));
%     i_ch = 1;
%     h = plot(data(i_subj).ts(temp_mask)-ts_start, 1e3 * data(i_subj).analog(i_ch, temp_mask));
%     set(h, 'Color', colors{i_ch});
%     ylabel(sprintf('%s (%s)', chan_names{i_ch}, 'uV'));
%     axis tight
%     % Specific to top/EEG panel
%     title(sprintf('%s', desc{i_subj}));
%     set(gca, 'XTickLabel', []);
%     axis([-inf inf 0-eeg_lim(i_subj) eeg_lim(i_subj)]);
% 
%     axes(grid_emg(i_subj));
%     i_ch = 3;
%     h = plot(data(i_subj).ts(temp_mask)-ts_start, 1e3 * data(i_subj).analog(i_ch, temp_mask));
%     set(h, 'Color', colors{i_ch});
%     ylabel(sprintf('%s (%s)', chan_names{i_ch}, 'uV'));
%     axis tight
%     % Specific to bottom/EMG panel
%     xlabel('Time (sec)');
%     axis([-inf inf 0-emg_lim(i_subj) emg_lim(i_subj)]);
% 
% %         
% %         if i_ch == 1 
% %             title(disp_names{i_subj});
% %             xlabel('Time (sec)');
% %         end
% %         ylabel(sprintf('%s (uV)', chan_names{i_ch}));
% %         set(gca, 'XTick', 0:dur);
% %         set(gca, 'YTick', [min(axis_volt), 0, max(axis_volt)]);
% %         axis([-Inf Inf axis_volt]);
% %     end
% %     axes(grid_axes(end, i_subj));
% %     [freqs, dB_psd, psdx] = PowerSpecMatrixWelch(1e3*data.analog(1:size(grid_axes)-1, temp_mask)', data.Fs, win, frac_overlap);
% % %     mask_ts = 0 <= data.ts & data.ts <= dur_psd;
% % %     [freqs, dB_psd, psdx] = PowerSpecMatrixWelch(data.analog(1:size(grid_axes)-1, mask_ts)', data.Fs, win, frac_overlap);
% %     h = plot(freqs, dB_psd);
% %     for i_ch = 1:numel(h)
% %         set(h(i_ch), 'Color', colors{i_ch});
% %     end
% %     set(h, 'LineWidth', line_width);
% %     xlabel('Frequency (Hz)');
% %     ylabel('Power (dB)');
% %     axis([axis_freq, axis_power]);
% % %     axis([axis_freq, -Inf Inf]);
% %     set(gca, 'XTick', 0:20:100);
% % %     set(gca, 'YTick', 0:20:100);
% end
% 
% % Format Graphs some more
% 
% % AxesSharedLimits(grid_eeg, [-inf inf NaN NaN]);
% % AxesSharedLimits(grid_emg, [-inf inf NaN NaN]);
% 
% 
% 
% 
% % % names = {'kBe'}';
% % % dates = {'20141215'};
% % chan_names = {'EEG1', 'EEG2', 'EMG'};
% % % colors = {ColorPicker('blue'), ColorPicker('turquoise'), ColorPicker('red')};
% % colors = {ColorPicker('blue'), ColorPicker('red')};
% % win = 1e3;
% % % win = 2^12;
% % frac_overlap = 0.9;
% % axis_freq = [0 100];
% % axis_power = [0 30];
% % axis_volt = [-0.2 0.2] * 1e3;
% % dur_psd = 60*60;
% % line_width = 2;
% % 
% % num_subj = numel(names);
% % 
% % clf;
% % grid_axes = AxesGrid(3, num_subj, [0.03 0.97 0.03 0.96], [0.12 0.15]);
% % 
% % for i_subj = 1:num_subj 
% %     file_mask = [names{i_subj} '-' dates{i_subj} '-*.bin'];
% %     files = dir(file_mask);
% %     
% %     filename = files(end).name;
% %     fprintf('%s\n', filename);
% %     
% %     data = OpBoxPhys_LoadData(filename);
% %     idx_start = starts(i_subj);
% %     
% %     for i_ch = 1:size(grid_axes, 1)-1
% %         axes(grid_axes(i_ch, i_subj));
% %         temp_mask = idx_start <= data.ts & data.ts <= (idx_start+dur);
% %         h = plot(data.ts(temp_mask)-idx_start, 1e3 * data.analog(i_ch, temp_mask));
% %         set(h, 'Color', colors{i_ch});
% %         if i_ch == 1 
% %             title(disp_names{i_subj});
% %             xlabel('Time (sec)');
% %         end
% %         ylabel(sprintf('%s (uV)', chan_names{i_ch}));
% %         set(gca, 'XTick', 0:dur);
% %         set(gca, 'YTick', [min(axis_volt), 0, max(axis_volt)]);
% %         axis([-Inf Inf axis_volt]);
% %     end
% %     axes(grid_axes(end, i_subj));
% %     [freqs, dB_psd, psdx] = PowerSpecMatrixWelch(1e3*data.analog(1:size(grid_axes)-1, temp_mask)', data.Fs, win, frac_overlap);
% % %     mask_ts = 0 <= data.ts & data.ts <= dur_psd;
% % %     [freqs, dB_psd, psdx] = PowerSpecMatrixWelch(data.analog(1:size(grid_axes)-1, mask_ts)', data.Fs, win, frac_overlap);
% %     h = plot(freqs, dB_psd);
% %     for i_ch = 1:numel(h)
% %         set(h(i_ch), 'Color', colors{i_ch});
% %     end
% %     set(h, 'LineWidth', line_width);
% %     xlabel('Frequency (Hz)');
% %     ylabel('Power (dB)');
% %     axis([axis_freq, axis_power]);
% % %     axis([axis_freq, -Inf Inf]);
% %     set(gca, 'XTick', 0:20:100);
% % %     set(gca, 'YTick', 0:20:100);
% % end
