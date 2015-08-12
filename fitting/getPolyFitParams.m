function [pp, type, s, degree] = getPolyFitParams(validData)
% GETPOLYFITPARAMS
%
% get polynomial fitting parameters
%
%   INPUT:
%
%   validData - line data
%
%   OUTPUT:
%
%   pp     - polynomial fitting parameters
%   degree - polynomial degree
%   type   - curve fitting x->y or y->x
%            1 - FIT_XY, 2 - FIT_YX

load('common.mat');

degree = FIT_DEGREE;

[pXY, sXY] = polyfit(validData(:, X), validData(:, Y), round(degree));
[~, delXY] = polyval(pXY, validData(:, X), sXY);

[pYX, sYX] = polyfit(validData(:, Y), validData(:, X), round(degree));
[~, delYX] = polyval(pYX, validData(:, Y), sYX);

if sum(abs(delXY)) > sum(abs(delYX))
    while(sYX.normr > FIT_TH && degree < MAX_FIT_DEGREE)
        degree = degree + 1;
        [pYX, sYX] = polyfit(validData(:, Y), validData(:, X), degree);
    end
    
    pp   = pYX;
    type = FIT_YX;
    s    = sYX;
else
    while(sXY.normr > FIT_TH && degree < MAX_FIT_DEGREE)
        degree = degree + 1;
        [pXY, sXY] = polyfit(validData(:, X), validData(:, Y), degree);
    end
    
    pp   = pXY;
    type = FIT_XY;
    s    = sXY;
end