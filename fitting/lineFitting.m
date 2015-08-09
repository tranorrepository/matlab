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

% iterate for each line
numOfLines = size(linesData, 2);

newLines = cell(1, numOfLines);

for ln = 1:numOfLines
    line = linesData{1, ln};
    % exclude invalid data
    validData = line(line(:, PAINT_IND) ~= INVALID_FLAG, :);
    
    % initialize output data
    newLines{1, ln} = validData;
    
    % step 1 - curve fitting
    % currently use polynomial to do curve fitting, other method should be
    % used
    pp = polyfit(validData(:, X), validData(:, Y), FIT_DEGREE);
    
    % step 2 - remapping data
    % map input points to the closest points on the curve fitted
    
    newLines{1, ln}(:, Y) = polyval(pp, validData(:, X)); % a tricky way here

end