clc;
clear all;

cdDropbox;
dir_name = 'Research\Behavior\CodeProcessing\OpBox_Monitor\application.windows32';
% dir_name = [cdData '\Behavior\RandIntGoNogoSwitch'];
% dir_name = [cdData '\Behavior\LickGo'];
% dir_name = [cdData '\Behavior\MouseDelirium'];
cd(dir_name);

% All subjects today
temp_anim = 'k*';
temp_date = datestr(now, 'yyyymmdd');

% Specific subject/date
temp_anim = 'MD*'; % delirium mice
temp_anim = '*'; % delirium mice
% temp_anim = 'kCm*';
% temp_date = '201505*';

file_mask = [temp_anim '*-' temp_date '*-*.txt'];

files = dir(file_mask);
num_files = length(files);
fprintf('%d files found\n', num_files);
data = [];
for i_file = 1:num_files
    filename = files(i_file).name;
%     data(i_file) = BehGoNogoSessionSummary(filename);
    clf;
    try
%         temp_data = BehGoNogoSessionSummary(filename);
        temp_data = BehGoNogoSessionDots(filename);
        if ~isempty(temp_data.acc)
            data = [data, temp_data];
        end
        
% %     axis([0 4/24, 0 1.01]);
        if num_files > 1
            pause;
        end
    catch
        fprintf('Error\n');
    end
end
 
% RandIntGoNogo: <90min: >=85% over 100 trials, >80 reward

% %% Rehash last stimuli
% for i_file = 1:num_files
%     fprintf('%s: %c+ vs. %c-', files(i_file).name(1:3), data(i_file).last_go, data(i_file).last_nogo);
%     if (data(i_file).last_go == data(i_file).last_nogo)
%         fprintf('   Error, same go and nogo at end');
%     end
%     fprintf('\n');
% end
% fprintf('\n');
% 
% for i_file = 1:num_files
%     if (data(i_file).last_go == data(i_file).last_nogo)
%         fprintf('Error, same go and nogo at end\n');
%     else 
%         fprintf('%c\t%c', data(i_file).last_go, data(i_file).last_nogo);
%         fprintf('\t');
%         if (data(i_file).last_nogo == 'M')
%             fprintf('M');
%         else 
%             if (data(i_file).last_nogo == 'L')
%                 fprintf('H');
%             elseif (data(i_file).last_nogo == 'H')
%                 fprintf('L');
%             end
%         end
%         fprintf('\t');
%         
%         if (data(i_file).last_go == 'M')
%             fprintf('M');
%         else 
%             if (data(i_file).last_go == 'L')
%                 fprintf('H');
%             elseif (data(i_file).last_go == 'H')
%                 fprintf('L');
%             end
%         end
%         fprintf('\n');
%     end
% end
% 


% %% Plot some summary data over time
% title_text = {};
% clf;
% grid_axes = AxesGrid(2,2);
% i_grid = 0;
% 
% i_grid = i_grid+1; axes(grid_axes(i_grid));
% temp_data = [data.num_switches];
% plot(temp_data, '.-');
% title('NumSwitch');
% 
% i_grid = i_grid+1; axes(grid_axes(i_grid));
% temp_data = [data.msElapsed]/1e3/60/60;
% plot(temp_data, '.-');
% title('HrElapsed');
% 
% 
% i_grid = i_grid+1; axes(grid_axes(i_grid));
% temp_data = [data.num_switches] ./ ([data.msElapsed]/1e3/60/60);
% plot(temp_data, '.-');
% title('NumSwitchPerHr');
% 
% i_grid = i_grid+1; axes(grid_axes(i_grid));
% temp_data = [data.acc];
% plot(temp_data, '.-');
% axis([0.5 numel(data)+0.5, 0 1]);
% title('Acc')
% 
% % for i_data = 1:numel(data)
% %     plot    
% % end
