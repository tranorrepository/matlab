function newLines = lineFitting(linesData)
% LINEFITTING
%   data curve fitting and remapping input points to curve points
%
%   INPUT:
%
%   lineData - raw dash/solid point data of a single line
%              (x, y, paintFlag, mergedCount)
%
%   OUTPUT:
%
%   newLine  - remapped points on the curve
%              (x, y, paintFlag, mergedCount)
%
%


% load common data
load('common.mat');

% iterate for each line
numOfLines = size(linesData, 2);

newLines = cell(1, numOfLines);

for ln = 1:numOfLines
    line = linesData{1, ln};
    % exclude invalid data
    validData = line(line(:, PAINT_IND) ~= INVALID_FLAG, :);
    
    % initialize output data
    newLines{1, ln} = line;
    
    % step 1 - curve fitting
    % currently use polynomial to do curve fitting, other method should be
    % used
    [pp, fitType, s, ~] = getPolyFitParams(validData);
    
%     [pXY, sXY] = polyfit(validData(:, X), validData(:, Y), FIT_DEGREE);
%     [~, delXY] = polyval(pXY, validData(:, X), sXY);
%     
%     [pYX, sYX] = polyfit(validData(:, Y), validData(:, X), FIT_DEGREE);
%     [~, delYX] = polyval(pYX, validData(:, Y), sYX);
%     
%     if sum(abs(delXY)) > sum(abs(delYX))
%         pp   = pYX;
%         fitType = FIT_YX;
%     else
%         pp   = pXY;
%         fitType = FIT_XY;
%     end
    
    % step 2 - remapping data
    % map input points to the closest points on the curve fitted
    
    closestPoints = mapCurveClosestPoint(pp, line, fitType, s);
    newLines{1, ln}(:, 1:2) = closestPoints(:, 1:2);
end
