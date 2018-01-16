clc;

clear;
cdMatlab;
cd('..\PostDocResearch\Behavior\Data\RandIntGoNogo');

file_mask = ['k*-201*-*.txt'];
files = dir(file_mask);
num_files = length(files);

for i_file = 1:num_files
    filename = files(i_file).name;

    % Load file
    fid = fopen(filename, 'r');
    if fid == -1
        fprintf ('Problem opening file: %s\n', filename)
        return;
    end
    file_double = fread(fid, inf, 'uchar'); % faster than fscanf. textread fails on string data
    file_char = char(file_double');
    clear file_double;
    fclose(fid);

    %% Parse data
    % Make sure session was properly terminated, 
    % otherwise for now return w/emtpy values
    flag = 'msElapsed: ';
    ms_elapsed = StrFlagToLine(file_char, flag);
    if isempty(ms_elapsed)
        fprintf('Session not terminated properly. Exiting Session Summary.\n\n')
        continue;
    end
 
    flag = 'Subject: ';
    subject = StrFlagToLine(file_char, flag);

    flag = 'Protocol: ';
    protocol = StrFlagToLine(file_char, flag);

    flag = 'PerGoStim: ';
    per_go_stim = StrFlagToLine(file_char, flag);

    flag = 'TimeStart: ';
    datetime = StrFlagToLine(file_char, flag);
    date_start = str2num(datetime([1:4, 6:7, 9:10]));
    hour_start = str2num(datetime(12:13)) + str2num(datetime(15:16))/60 + str2num(datetime(18:19))/3600;

    flag = 'MaxMT: ';
    temp_str = StrFlagToLine(file_char, flag);
    if isempty(temp_str)
        max_mt = NaN;
    else 
        max_mt = str2num(temp_str);
        max_mt = max_mt / 1e3; % ms to sec
    end

    % process timestamps and convert to numbers
    flags = {'ts_np_in', 'ts_np_out', 'ts_lick_in', 'ts_lick_out', 'ts_fluid_on', 'ts_fluid_off', 'ts_free_rwd', 'ts_stim_on', 'ts_stim_off', 'stim_class', 'all_iti', 'ts_iti_end', 'ts_mt_end'};
    num_flags = length(flags);
    for i_flag = 1:num_flags
        flag = [flags{i_flag} ': '];
        temp_str = StrFlagToLine(file_char, flag);
        if isempty(temp_str)
            temp_num = NaN;
        else 
            temp_str(temp_str == ',') = 0;
            temp_num = sscanf(temp_str, '%ld'); % 64 bit integers
        end
        eval([flags{i_flag} ' = temp_num;']);
    end

    % Text at end/final line
    idx_punc = strfind(file_char, '<');
    text_end = file_char(idx_punc:end);

    stim_class('R' == stim_class) = 'G';
    
    % Check that stim class corresponds to ts_stim_on
    % should be 1 more in preparation for next stim
    num_class = length(stim_class);
    num_stim = length(ts_stim_on);
    num_free = length(ts_free_rwd);
    
    if (num_class < num_stim) || (num_class == num_stim && 0 ~= num_free)
        fprintf('%3d/%3d: %s\n', i_file, num_files, filename);
        % early in training, num_class = num_stim when FR1 was switched to RI protocol. as of 2014/01/08, this captures all these files when num_free == 0
        fprintf('\tError w/stim class!:');
        fprintf(' #Stims: %3d', num_stim);
        fprintf(' #Class: %3d', num_class);
        fprintf(' #FreeR: %3d', num_free);
        fprintf('\n');
%         fprintf('%c', unique(stim_class));
%         fprintf('\n');
        
        flag = 'StimClass: ';
        stim_class = StrFlagToLine_NumArray(file_char, flag);
        num_new_class = length(stim_class);
        fprintf('\t  Total stim_class in file = %3d', num_new_class);
        if num_new_class == num_stim
            fprintf('. Fixable from current file\n');
        else
            fprintf('. Need tmp file for %s\n', filename);
            tmp_file = ['~' filename(1:end-2) 'mp'];
            cd('TmpFiles\');
            % Load file
            fid = fopen(tmp_file, 'r');
            if fid == -1
                fprintf ('Problem opening file: %s\n', filename)
                return;
            end
            file_double = fread(fid, inf, 'uchar'); % faster than fscanf. textread fails on string data
            file_char = char(file_double');
            clear file_double;
            fclose(fid);
            
            flag = 'StimClass: ';
            stim_class = StrFlagToLine_NumArray(file_char, flag);
            num_tmp_class = length(stim_class);
            if num_tmp_class == num_stim
                fprintf('\t  Fixable from tmp file %s\n', tmp_file);
            end            
            cd('..');
            
        end
        
        % Save file back to disk...
        cd('FixedStimClassFiles');
        
        fid = fopen(filename, 'w');
        if fid == -1
            fprintf ('Problem opening file: %s\n', filename)
            return;
        end

        flag = 'Subject: ';
        fprintf(fid, '%s%s\n', flag, subject);

        flag = 'Protocol: ';
        fprintf(fid, '%s%s\n', flag, protocol);

        flag = 'PerGoStim: ';
        fprintf(fid, '%s%s\n', flag, per_go_stim);

        flag = 'TimeStart: ';
        fprintf(fid, '%s%s\n', flag, datetime);

        if ~isnan(max_mt)
            flag = 'MaxMT: ';
            fprintf(fid, '%s%d', flag, max_mt*1e3);
            fprintf(fid, '%c%c', 13, 10);
        end

        % process timestamps and convert to numbers
        flags = {'ts_np_in', 'ts_np_out', 'ts_lick_in', 'ts_lick_out', 'ts_fluid_on', 'ts_fluid_off', 'ts_free_rwd', 'ts_stim_on', 'ts_stim_off', 'stim_class', 'all_iti', 'ts_iti_end', 'ts_mt_end'};
        num_flags = length(flags);
        for i_flag = 1:num_flags
            flag = [flags{i_flag} ': '];
            fprintf(fid, '%s', flag);
            eval(['temp_num = ' flags{i_flag} ';']);
            fprintf(fid, '%d,', temp_num);
            fprintf(fid, '%c%c', 13, 10);
        end

        fprintf(fid, '%s', text_end);

        fclose(fid);
        cd('..');
    end
end

