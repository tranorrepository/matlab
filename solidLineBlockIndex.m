function [solidLineData, solidLineIndex] = solidLineBlockIndex(data)
% SOLIDLINEBLOCKINDEX
%   dotted line information from input data
%
%   INPUT:
%
%   data - organized GPS data, 19 columns(ford) or 6 columns(Honda)
%
%   OUTPUT:
%
%   solidLineData - solid line start/stop block index of GPS data
%   solidLineIndex - the column of paint solid line
%

% assume the data is organized as expected
[paintIndex, xyIndex] = getPaintIndex(data);
paint = sum(1 == data(:, paintIndex));

% solid line index
solidLineIndex = paintIndex(max(paint) == paint);
solidLineData  = data(:, xyIndex(max(paint) == paint, :));
solidLineData(:, 3) = data(:, solidLineIndex);