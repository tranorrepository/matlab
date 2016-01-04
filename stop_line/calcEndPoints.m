function [start, stop] = calcEndPoints(center, length, theta)
% CALCENDPOINTS
%    calculate end points according to center point and length
%
%    INPUT:
%    center - center point x, y
%    length - line length
%    theta  - line angle
%
%    OUTPUT:
%    start - start point x, y
%    end   - end point x, y
%
%

z = (center.x + center.y * 1i) .* exp(-theta * 1i);

% rotated center point
rotCtr.x = real(z);
rotCtr.y = imag(z);

% rotated start and end point
rotStart.x = rotCtr.x - 0.5 * length;
rotStart.y = rotCtr.y;

rotEnd.x = rotCtr.x + 0.5 * length;
rotEnd.y = rotCtr.y;

sz = (rotStart.x + rotStart.y * 1i) .* exp(theta * 1i);
ez = (rotEnd.x + rotEnd.y * 1i) .* exp(theta * 1i);

% rotate back
start.x = real(sz);
start.y = imag(sz);

stop.x = real(ez);
stop.y = imag(ez);
