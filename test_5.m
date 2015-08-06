function data = test_5()
% TEST_5
%
% VW data

data = gpsDataReader('vwlist.txt');
datasetNum = size(data, 1);

for ds = 1:datasetNum
    plot(data{ds}(:, 2), data{ds}(:, 1), 'k.', 'MarkerSize', 1);
    hold on;
end




%%
function data = gpsDataReader(filename)
% GPSDATAREADER
%   read input GPS data according to configuration file
%
% INPUT:
%
%   filename - GPS data text filename list
%

% open GPS data file list
fid = fopen(filename, 'r');
if -1 == fid
    fclose(fid);
    error('Failed to open %s', filename);
end

STR_DATA_TYPE = '%f %f';
GPS_DATA_TYPE = 2;

fnIndex = 1;

while ~feof(fid)
    % open filename list
    fn = fgetl(fid);
    fidfn = fopen(fn, 'r');
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
    
    eval(['data' num2str(fnIndex) ' = zeros(' num2str(rows) ', ' num2str(GPS_DATA_TYPE) ');']);

    % get data
    rowIndex = 1;
    while ~feof(fidfn)
        fline = fgetl(fidfn);
        flineData = regexp(fline, ',', 'split'); % sscanf(fline, STR_DATA_TYPE);
        eval(['data' num2str(fnIndex) '(' num2str(rowIndex) ', 1) = sscanf(flineData{1}, ''%f'');']);
        eval(['data' num2str(fnIndex) '(' num2str(rowIndex) ', 2) = sscanf(flineData{2}, ''%f'');']);
        rowIndex = rowIndex + 1;
    end
    
    fclose(fidfn);
    
    % file index
    fnIndex = fnIndex + 1;
end

fclose(fid);

data = cell(fnIndex - 1, 1);
for fn = 1:fnIndex - 1
    eval(['data{' num2str(fn) ', 1} = data' num2str(fn) ';']);
end

save('C:\Projects\matlab\ford.mat', 'data');