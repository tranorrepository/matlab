function newLines = shiftData(linesData,  vector)
% SHIFTDATA
%   shift all lines in linesData with vector. weight should take into
%   account
%
%   INPUT:
%
%   linesData - line data set
%               1xN columns, each column is Mx4 matrix
%               (x, y, paint flag, merged count)
%
%   vector    - (x, y)
%
%


% load common data
load('common.mat');

newLines = linesData;

% iterate for each line
numOfLines = size(linesData, 2);
for ln = 1:numOfLines
    % shift 
    newLines{1, ln}((linesData{1, ln}(:, 3) ~= INVALID_FLAG), X) = ...
        linesData{1, ln}((linesData{1, ln}(:, 3) ~= INVALID_FLAG), X) + ...
        vector(1, X);
    newLines{1, ln}((linesData{1, ln}(:, 3) ~= INVALID_FLAG), Y) = ...
        linesData{1, ln}((linesData{1, ln}(:, 3) ~= INVALID_FLAG), Y) + ....
        vector(1, Y);
end