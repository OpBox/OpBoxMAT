% Nosepoke on 6
% Glue acrylic boxes

clc;
clear all;

cdMatlab;
% cd('..\Research\Behavior\Data\RandIntGoNogo');
% cd('..\Research\Behavior\Data\GoNogoTrack');
cd('..\Research\Behavior\Data\RandIntGoNogoSwitch');
% cd('..\Research\Behavior\Data\RandIntGoNogoOnArduino');
% cd('..\Research\Behavior\Data\AnimalFacilityData\RandIntGoNogoSwitch');

% temp_date = '20140616';
% temp_date = datestr(now, 'yyyymmdd');
temp_date = '*';
temp_anim = 'k*';

file_mask = [temp_anim '-' temp_date '-*.txt'];
files = dir(file_mask);

filenames = {files.name};
anims = zeros(length(filenames), 3);
for i_file = 1:length(filenames)
    anims(i_file, :) = filenames{i_file}(1:3);
end

[name_anims, idx_names, idx_anims] = unique(anims, 'rows');
num_anims = length(name_anims);
num_files_per_anim = hist(idx_anims, 1:num_anims);
max_num_files = max(num_files_per_anim);

%% Go Through files
filenames = {};
for i_anim = 1:num_anims
    temp_anim = name_anims(i_anim, :);
    file_mask = [temp_anim '-' temp_date '-*.txt'];
    files = dir(file_mask);
    filename = files(end).name;
    filenames{i_anim} = filename;
    data(i_anim) = BehGoNogoSessionSummary(filename);
%     pause;
end

%% Rehash last stimuli
num_files = length(filenames);
for i_file = 1:num_files
    fprintf('%s: %c+ vs. %c-', filenames{i_file}, data(i_file).last_go, data(i_file).last_nogo);
    if (data(i_file).last_go == data(i_file).last_nogo)
        fprintf('   Error, same go and nogo at end');
    end
    fprintf('\n');
end
fprintf('\n');

for i_file = 1:num_files
    if (data(i_file).last_go == data(i_file).last_nogo)
        fprintf('Error, same go and nogo at end\n');
    else 
        fprintf('%c\t%c', data(i_file).last_go, data(i_file).last_nogo);
        fprintf('\t');
        if (data(i_file).last_nogo == 'M')
            fprintf('M');
        else 
            if (data(i_file).last_nogo == 'L')
                fprintf('H');
            elseif (data(i_file).last_nogo == 'H')
                fprintf('L');
            end
        end
        fprintf('\t');
        
        if (data(i_file).last_go == 'M')
            fprintf('M');
        else 
            if (data(i_file).last_go == 'L')
                fprintf('H');
            elseif (data(i_file).last_go == 'H')
                fprintf('L');
            end
        end
        fprintf('\n');
    end
end

