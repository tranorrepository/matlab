function data = vwDataParser(filename)
% VWDATAPARSER
%
%   data parser applied to VW data files
%
%   INPUT:
%
%   filename - VW data file path, input data format is 
%              (L.lat, R.lat, L.lon, R.log, L.paintFlag, R.paintFlag)
%
%   OUTPUT:
%
%   data - align data format, output data formatt is
%          (L.lat, L.lon, R.lat, R.log, L.paintFlag, R.paintFlag)
%
%

close all; clc;

% open GPS data file
fid = fopen(filename, 'r');
if -1 == fid
    fclose(fid);
    error('Failed to open %s', filename);
end

GPS_DATA_TYPE = 6;

bNewSet = false;

secIndex = 1;
colIndex = 1;

while ~feof(fid)
    fline = fgetl(fid);
    ls = size(regexp(fline, ' ', 'split'), 2);
    
    if isempty(fline)
        bNewSet = false;
        secIndex = secIndex + 1;
        colIndex = 1;
        continue;
    end
    
    if false == bNewSet
        s = '';
        for i = 1:ls
            s = [s, '%f '];
        end
        bNewSet = true;
        
        eval(['data' num2str(secIndex) ' = zeros(ls-1, ' num2str(GPS_DATA_TYPE) ');']);
    end

    if true == bNewSet
        lData = sscanf(fline, s);
        eval(['data' num2str(secIndex) '(:, ' num2str(colIndex) ') = lData;']);
        colIndex = colIndex + 1;
    end
end

fclose(fid);

% for output
datasetNum = secIndex - 1;
data = cell(datasetNum, 1);
for ds = 1:datasetNum
    eval(['data{' num2str(ds) ', 1} = data' num2str(ds) ';']);
end
