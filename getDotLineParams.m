function dotLineParams = getDotLineParams(data, dotBlkIndex, dotLineIndex)
% GETDOTLINEPARAMS
%   get dotted line parameters, such as center, point count, length, width
%   and angle
%
%   INPUT:
%
%   data - organized GPS data, 19 columns(ford) or 6 columns(Honda)
%   dotBlkIndex - dotted line start/stop block index of GPS data
%   dotLineIndex - the column of paint dotted line
%
%   OUTPUT:
%
%   dotLineParams - organized center, length, width and angle data
%                   (x, y, point count, lenght, width, angle)

% assume the data is organized as expected
[paintIndex, xyIndex] = getPaintIndex(data);
indexData = xyIndex(paintIndex == dotLineIndex, :);

items = size(dotBlkIndex, 1);

% center
dotLineC = zeros(items, 3); % x, y, count
dotLineC(:, 3) = (dotBlkIndex(:, 2) - dotBlkIndex(:, 1) + 1);

lengthData = zeros(items, 2);
widthData  = zeros(items, 2);
for i = 1:items
    % center
    dotLineC(i, 1:2) = sum(data(dotBlkIndex(i, 1):dotBlkIndex(i, 2), indexData)) / dotLineC(i, 3);
    
    % for length calculation
    lengthData(i, :) = data(dotBlkIndex(i, 2), indexData) - ...
                       data(dotBlkIndex(i, 1), indexData);
    % width
%     widthData(i, 1) = sum(data(dotBlkIndex(i, 2):dotBlkIndex(i, 2), dotLineIndex + 3) - ...
%                           data(dotBlkIndex(i, 2):dotBlkIndex(i, 2), dotLineIndex + 1));
%     widthData(i, 2) = sum(data(dotBlkIndex(i, 2):dotBlkIndex(i, 2), dotLineIndex + 4) - ...
%                           data(dotBlkIndex(i, 2):dotBlkIndex(i, 2), dotLineIndex + 2));
end

% angle
theta = angle(lengthData(:, 1) + lengthData(:, 2)*1j);

% length
length = zeros(items, 1);
lengthData = lengthData .* lengthData;
length(:) = sqrt(lengthData(:, 1) + lengthData(:, 2));

% width
width = zeros(items, 1);
widthData = widthData .* widthData;
width(:) = sqrt(widthData(:, 1) + widthData(:, 2));

dotLineParams = [dotLineC, length, width, theta];