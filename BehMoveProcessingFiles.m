clear

cdMatlab;
cd('..\PostDocResearch\Behavior\');
dir_parent = pwd;
cd('Data');
dir_destin_root = pwd;
cd('..\CodeProcessing');
dir_protocols = pwd;

exe_subdir = 'application.windows32';

prefix_dirs = {
    'LickStimWater';
    'MotionTrack2DwithLightWater';
    'NpStimLickWater_FR1';
    'RandIntGoNogo';
    'RandIntGoNogoSwitch';
    'RandomInterval';
    'RI20';
    'RandIntLick';
    'GoNogoTrack';
    };
    
% prefix_dir = 'RandIntGoNogo_Box';

max_boxes = 8;

file_mask = 'k*-*-*.t*';
% track_mask = 'k*-*-*.trk';
% does not move track files .trk yet

for i_dir = 1:length(prefix_dirs)
    cd(dir_protocols);
    if exist(prefix_dirs{i_dir}, 'dir')
        cd(prefix_dirs{i_dir});
        beh_files = dir(file_mask);
        for i_file = 1:length(beh_files);
           % Make sure not to move files while running them! (copy only)
           filename = beh_files(i_file).name;
           fprintf('Moving %s\n', filename);
           movefile(filename, [dir_destin_root '\' prefix_dirs{i_dir}]);
        end
        
        % Now look for windows exe subfolder derivatives of this protocol
        if exist(exe_subdir, 'dir')
            cd(exe_subdir);
            beh_files = dir(file_mask);
            for i_file = 1:length(beh_files);
               % Make sure not to move files while running them! (copy only)
               filename = beh_files(i_file).name;
               fprintf('Moving %s\n', filename);
               movefile(filename, [dir_destin_root '\' prefix_dirs{i_dir}]);
            end
        end
        
        % Now look for box derivatives of this protocol
        for i_box = 0:max_boxes - 1
            cd(dir_protocols);
            if exist([prefix_dirs{i_dir} '_Box' num2str(i_box)], 'dir') 
                cd([prefix_dirs{i_dir} '_Box' num2str(i_box)]);
                % Make sure not to move files while running them! (copy only)
                beh_files = dir(file_mask);
                for i_file = 1:length(beh_files);
                   filename = beh_files(i_file).name;
                   fprintf('Moving %s\n', filename);
                   movefile(filename, [dir_destin_root '\' prefix_dirs{i_dir}]);
                end
            end
        end
    end
end


