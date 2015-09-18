function [rptData] = readData(filename)
%Input:
%         filename
%Output:
%         Newdata : 1*N cell,N stands for number of video
%                           contents of each column: [L_lon,L_lat,L_flag,R_lon,R_lat,R_flag]
count = 0;
data = cell(1,1);
rptData = cell(1,1);
% open GPS data file list
fid = fopen(filename, 'r');
if -1 == fid
    fclose(fid);
    error('Failed to open %s', filename);
end
while ~feof(fid)
    % open filename list
    fn = fgetl(fid);
    fidfn = fopen(fn, 'r');
    count = count + 1;
    if -1 == fidfn
        fclose(fid);
        error('Failed to open %s', fn);
    end
    
    % get lines of file
    rows = 0;
    while ~feof(fidfn)
        rows = rows + sum(fread(fidfn, 10000, '*char') == char(10));
    end
    frewind(fidfn);
    %fidfn = fopen(fn, 'r');
    lineIdx = 1;
    while ~feof(fidfn)
        fileLine = fscanf(fidfn, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 19);
        if ~isempty(fileLine)
            eval(['DataSource' num2str(count) '(lineIdx,:) = fileLine;']);
            lineIdx = lineIdx + 1;
        else
            break;
        end
    end
    fclose(fidfn);
    eval(['data{1,count}=DataSource' num2str(count) ';']);

    L_lon = data{1,count}(:,2);
    L_lat = data{1,count}(:,1);
    L_flag = data{1,count}(:,3);

    R_lon = data{1,count}(:,13);
    R_lat = data{1,count}(:,12);
    R_flag = data{1,count}(:,14);
    
    rptData{1,count} = [L_lon,L_lat,L_flag,R_lon,R_lat,R_flag];
end
end