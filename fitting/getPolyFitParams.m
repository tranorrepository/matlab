function [pp, type, s, degree, mu] = getPolyFitParams(validData)
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

[pXY, sXY, muXY] = polyfit(validData(:, X), validData(:, Y), round(degree));
[~, delXY] = polyval(pXY, validData(:, X), sXY, muXY);

[pYX, sYX, muYX] = polyfit(validData(:, Y), validData(:, X), round(degree));
[~, delYX] = polyval(pYX, validData(:, Y), sYX, muYX);

if sum(abs(delXY)) > sum(abs(delYX))
    while(sYX.normr > FIT_TH && degree < MAX_FIT_DEGREE)
        degree = degree + 1;
        [pYX, sYX, muYX] = polyfit(validData(:, Y), validData(:, X), degree);
    end
    
    pp   = pYX;
    type = FIT_YX;
    s    = sYX;
    mu   = muYX;
else
    while(sXY.normr > FIT_TH && degree < MAX_FIT_DEGREE)
        degree = degree + 1;
        [pXY, sXY, muXY] = polyfit(validData(:, X), validData(:, Y), degree);
    end
    
    pp   = pXY;
    type = FIT_XY;
    s    = sXY;
    mu   = muXY;
end