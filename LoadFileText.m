function file_char = LoadFileText(filename)

fid = fopen(filename, 'r');
if fid == -1
    fprintf ('Problem opening file: %s\n', filename)
    file_char = [];
else
    file_char = fread(fid, inf, 'uchar=>char'); % faster than fscanf. textread fails on string data. Returns as double for some weird reason
    fclose(fid);
end
