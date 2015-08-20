% CalcRotationAngle
%
%   INPUT:
%
%   segconfig - Nx3 cell
%                    +---- ID  +  8x{x,y} Pair + lane 
%   segID     - segment ID        
%
%   OUTPUT:  rotation angle [0,pi]
%
%   fdatabase - 
%               {1, 2}
%                   {1, 4} lines

function [theta ,X] = calcRotationAngle(segconfig,segID)
x = segconfig{segID,2}(1:2:end);
y = segconfig{segID,2}(2:2:end);

x0 = (x(1)+x(2))/2;
x1 = (x(3)+x(4))/2;

y0 = (y(1)+y(2))/2;
y1 = (y(3)+y(4))/2;

theta = atan2((y0-y1),(x0-x1));

X0 = real((x+y*1i)*exp(-theta*j));
if (X0(1) < X0(3))
    X = round([ min(X0(1),X0(2))  max(X0(3),X0(4)) min(X0(5),X0(6))  max(X0(7),X0(8))],1);
else
    X = round([ max(X0(1),X0(2))  min(X0(3),X0(4)) max(X0(5),X0(6))  min(X0(7),X0(8))],1);
end