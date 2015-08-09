function lineType = getLineType(lineData)
% GETLINETYPE
%   get line type, dotted or solid line according to line data
%
%   INPUT:
%
%   lineData - input line data, format is 
%              (x, y, paintFlag, merged count)
%
%   OUTPUT:
%
%   lineType - line type, dotted or solid
%              0 - dotted, 1 - solid
%

TH = 0.5;
PAINT_IND = 3;

threshold = sum(lineData(:, PAINT_IND) == 1) / ...
            sum(lineData(:, PAINT_IND) ~= -1);

if threshold < TH
    lineType = DASH_LINE;
else
    lineType = SOLID_LINE;
end