function [paintIndex, xyIndex] = getPaintIndex(data)
% GETPAINTINDEX
%   get painted line column index from input data
%
%   INPUT:
%
%   data - organized GPS data, 19 columns(ford) or 6 columns(Honda)
%
%   OUTPUT:
%
%   paintIndex - painted line column index
%   xyIndex - x, y column index of painted line
%

cols = size(data, 2);

if (6 ~= cols && 19 ~= cols && 7 ~= cols && 20 ~= cols)
    error('invalid data set!');
end

paintIndex  = [3; 14];
xyIndex = [paintIndex - 2, paintIndex - 1];
if (6 == cols) || (7 == cols)
    paintIndex  = [5; 6];
    xyIndex = [paintIndex - 4, paintIndex - 2]';
end