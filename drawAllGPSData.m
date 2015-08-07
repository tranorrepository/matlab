function drawAllGPSData(GPS_DATA, color, mkrsz)
% DRAWALLGPSDATA
%   plot all GPS data
%
%   INPUT:
%
%   GPS_DATA - a section GPS data, suppose format is 
%              (x1, y1, x2, y2, x3, y3, ..., flag1, flag2, flag3, ..., 
%               sectionID, merged times)
%
%   color    - color for plotting data
%
%   mkrsz    - marker size
%
%   OUTPUT:
%
%   NONE
%

[~, cols] = size(GPS_DATA);

if 0 ~= mod(cols, 3)
    error('Invalid input data for drawAllGPSData!');
end

% define x, y index, current it's (y, x) order
xIndex = 2;
yIndex = 1;

% number of lines in GPS data
numOfLines = fix((cols - 2) / 3);

% paint info column index
flagIndex = 2 * numOfLines + 1 : 3 * numOfLines;

% iterate each line
for nl = 1:numOfLines
    xyData = GPS_DATA(:, 2 * nl - 1 : 2 * nl);
    if 3 == nargin
        plot(xyData(GPS_DATA(:, flagIndex(nl)) == 1, xIndex), ...
             xyData(GPS_DATA(:, flagIndex(nl)) == 1, yIndex), ...
             color, 'MarkerSize', mkrsz); hold on;
    else
        plot(xyData(GPS_DATA(:, flagIndex(nl)) == 1, xIndex), ...
             xyData(GPS_DATA(:, flagIndex(nl)) == 1, yIndex), ...
             '.', 'Color', [0.66, 0.66, 0.66], 'MarkerSize', 1); hold on;
    end
end