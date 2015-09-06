function [paintIndex, xyIndex] = getPaintIndex(data)
% GETPAINTINDEX
%   get painted line column index from input data
%
%   INPUT:
%
%   data - organized GPS data from section, suppose data column format is
%          (x1, y1, x2, y2, x3, y3, ..., flag1, flag2, flag3, ..., 
%           sectionID, merged times)
%
%   OUTPUT:
%
%   paintIndex - painted line column index
%   xyIndex    - x, y column index of painted line
%

% total columns of input data
cols = size(data, 2);

% number of lines in GPS data
numOfLines = fix((cols - 2) / 3);

% paint info column index
paintIndex = 2 * numOfLines + 1 : 3 * numOfLines;

% x, y data index array
xyIndex = reshape(1 : 2 * numOfLines, 2, numOfLines)';