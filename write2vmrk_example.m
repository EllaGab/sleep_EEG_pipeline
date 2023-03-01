
%% Write info into VMRK file - example

vmrk_fpath = '...\...\...vmrk'; % ful path to the output vmrk file

% Create onsets and durations
n = 4; % # of events
onsets = sort(randi([0 10000], 1, n));
durations = round((2 - 0.3).*rand(n, 1) * 250);

% Output structure
vmrk_markers = struct('type',{},...
    'onset',{},...
    'duration',{});

for i_event = 1 : n
    vmrk_markers(i_event).type = 'event';
    vmrk_markers(i_event).onset = onsets(i_event);
    vmrk_markers(i_event).duration = durations(i_event);
end

% Error if the file already exits
if exist(vmrk_fpath, 'file')
    warning(vmrkFilePath);
    error('The VMRK file with the same name already exist. CHECK!!!!');
end


try
    % Open file
    [fid, message] = fopen(vmrk_fpath,'w');
    
    % Get current date and time
    date_time = datestr(datetime('now'));
    
    % Header/description
    fprintf(fid,'%s\n\n', date_time);
    fprintf(fid,'%s\n','[Markers Info]', ...
    'Each entry: Mk<Marker number>=<type>,<onset in data points>,<duration in data points>',...
    'Fields are delimited by commas, some fields might be omitted (empty)');
    fprintf(fid, '\n\n');
    
    for i_marker = 1:length(vmrk_markers)
        fprintf(fid,'%s\n',['Mk' num2str(i_marker) '=' ...
            vmrk_markers(i_marker).type ',' ...
            num2str(vmrk_markers(i_marker).onset) ',' ...
            num2str(vmrk_markers(i_marker).duration)]);
    end

% Catch error
catch ME
    % Close file
    fclose(fid);

    rethrow(ME);
end
    
% Close file
fclose(fid);

