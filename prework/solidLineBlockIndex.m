function [solidLineData, solidLineIndex] = solidLineBlockIndex(data)
% SOLIDLINEBLOCKINDEX
%   dotted line information from input data
%
%   INPUT:
%
%   data - organized GPS data from section, suppose data column format is
%          (x1, y1, x2, y2, x3, y3, ..., flag1, flag2, flag3, ..., 
%           sectionID, merged times)
%
%   OUTPUT:
%
%   solidLineData  - solid line start/stop block index of GPS data
%   solidLineIndex - the column of paint solid line
%

% assume the data is organized as expected
[paintIndex, xyIndex] = getPaintIndex(data);
paint = sum(1 == data(:, paintIndex));

% solid line index
solidLineIndex = paintIndex(max(paint) == paint);
solidLineData  = data(:, xyIndex(max(paint) == paint, :));
solidLineData(:, 3) = data(:, solidLineIndex);