clear;
cdMatlab;
cd('..\PostDocResearch\Behavior\Data\RandIntGoNogo');

anim = 'Bc';
file_mask = ['k' anim '*-*-*.txt'];
files = dir(file_mask);
num_files = length(files);

for i_file = 1:num_files
    filename = files(i_file).name;
    BehRandIntSessionSummary(filename);
    pause;
end

