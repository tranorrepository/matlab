function data = gpsDataParser(filename)
% GPSDATAPARSER
%   parse input GPS data according to configuration file
%
% INPUT:
%
%   filename - GPS data text filename list
%

close all; clc;

% open GPS data file list
fid = fopen(filename, 'r');
if -1 == fid
    fclose(fid);
    error('Failed to open %s', filename);
end

GPS_DATA_REFS    = 2;
GPS_DATA_TYPE_1  = 6;
GPS_DATA_TYPE_2  = 19;

STR_TYPE_1 = '%f %f %f %f %d %d';
STR_TYPE_2 = '%f %f %d %f %f %f %f %f %f %f %f %f %f %d %f %f %f %f %f';

GPS_DATA_TYPE    = GPS_DATA_TYPE_2;
STR_DATA_TYPE    = STR_TYPE_2;

% whether the data file contains GPS reference point
bContainRefGPS = false;
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
    
    % get first two lines to obtain GPS ref, data format information
    firstLine  = fgetl(fidfn);
    secondLine = fgetl(fidfn);
    
    if GPS_DATA_REFS == size(regexp(firstLine, ' ', 'split'), 2)
        bContainRefGPS = true;
        rows = rows - 1;
    end
    if GPS_DATA_TYPE_1 == size(regexp(secondLine, ' ', 'split'), 2)
        GPS_DATA_TYPE = GPS_DATA_TYPE_1;
        STR_DATA_TYPE = STR_TYPE_1;
    elseif GPS_DATA_TYPE_2 == size(regexp(secondLine, ' ', 'split'), 2)
        GPS_DATA_TYPE = GPS_DATA_TYPE_2;
        STR_DATA_TYPE = STR_TYPE_2;
    end
    
    eval(['data' num2str(fnIndex) ' = zeros(' num2str(rows) ', ' num2str(GPS_DATA_TYPE) ');']);
    frewind(fidfn);
    
    % if exist first GPS reference point
    if bContainRefGPS
        bContainRefGPS = false;
        fline = fgetl(fidfn);
        
        % add GPS reference point parse if needed
    end
    
    % get data
    rowIndex = 1;
    while ~feof(fidfn)
        fline = fgetl(fidfn);
        flineData = sscanf(fline, STR_DATA_TYPE)';
        eval(['data' num2str(fnIndex) '(' num2str(rowIndex) ', :) = flineData;']);
        rowIndex = rowIndex + 1;
    end
    
    fclose(fidfn);
    
    % file index
    fnIndex = fnIndex + 1;
end

fclose(fid);

data = cell(1, fnIndex - 1);
for fn = 1:fnIndex - 1
    eval(['data{' num2str(fn) '} = data' num2str(fn) ';']);
end

% save('C:\Projects\matlab\ford.mat', 'data');