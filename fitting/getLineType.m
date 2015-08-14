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
%              1010 - dotted, 1111 - solid
%

load('common.mat');

option = 1;

if option
    typeValue = laneNumberDetection(lineData, DASH_CONT_POINTS_TH, PLOT_OFF);
    
    if typeValue < LINE_TYPE_TH
        lineType = DASH_LINE;
    else
        lineType = SOLID_LINE;
    end

else
    TH = 0.5;
    
    threshold = sum(lineData(:, PAINT_IND) == 1) / ...
        sum(lineData(:, PAINT_IND) ~= -1);
    
    if threshold < TH
        lineType = DASH_LINE;
    else
        lineType = SOLID_LINE;
    end
end