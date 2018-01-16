function temp_data = BehGoNogoSubSummary(temp_date, temp_anim)

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
file_mask = [file_mask, '*.txt'];


dir_names = {
    [cdDropbox '\KimchiLab\Behavior\CodeProcessing\OpBox_Monitor\application.windows32'];
    [cdDropbox '\KimchiLab\Behavior\CodeProcessing\OpBox_Monitor_PumpTime\application.windows32'];
    [cdData '\Behavior\RandIntGoNogoSwitch'];
    [cdData '\Behavior\RandIntGoNogoSwitch\MouseDelirium'];
};

data = [];

for i_dir = 1:numel(dir_names)
    if ~exist(dir_names{i_dir}, 'dir')
        continue
    end
    cd(dir_names{i_dir});

    files = dir(file_mask);
    num_files = length(files);
    fprintf('%s: %d files found\n', dir_names{i_dir}, num_files);
    for i_file = 1:num_files
        filename = files(i_file).name;
        clf;
        try
%             temp_data = BehGoNogoSessionSummary(filename);
            temp_data = BehGoNogoSessionDots(filename);
%             temp_data = BehGoNogoSessionDotsPosTrack(filename);
            if ~isempty(temp_data.acc)
                data = [data, temp_data];
            end

        catch
            fprintf('Error\n\n');
        end
        if num_files > 1
            pause;
        end
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
