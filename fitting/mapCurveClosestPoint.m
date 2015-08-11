function closestPoints = mapCurveClosestPoint(pp, line, type)
% MAPCURVECLOSESTPOINT
%   mapping line points to the closest point on fitted curve
%
%   INPUT:
%
%   pp   - polynomial fitting parameters, FIT_DEGREE is 4 by default
%   line - input line points
%          (x, y, paint flag, merged count)
%   type - curve fitting x->y or y->x
%          1 - FIT_XY, 2 - FIT_YX
%
%   OUTPUT:
%
%   closestPoints - mapped closest points on the curve
%
%

load('common.mat');

% number of points on input line
numOfPoints = size(line, 1);

% initialize output
closestPoints = line;

P0 = zeros(1, 2);
P1 = zeros(1, 2);
P2 = zeros(1, 2);

% iterate each point
if type == FIT_XY
    for np = 1:numOfPoints
        P0(X) = line(np, X);
        P0(Y) = line(np, Y);
        
        % only check valid points
        if line(np, 3) ~= INVALID_FLAG
            P1(X) = P0(X);
            P1(Y) = polyval(pp, P1(X));
            
            % define curve function
            P2(X) = P0(X) - 5;
%             f = @(x)pp(1)*x^4 + pp(2)*x^3 + pp(3)*x^2 + pp(4)*x + pp(5) - P2(Y);
%             options=optimset('MaxIter',1e3,'TolFun',1e-3);
%             P2(X) = fsolve(f, P0(X), options);
            P2(Y) = polyval(pp, P2(X));
            while (1)
                if abs(P2(X) - P1(X)) < DIST_TH
                    P0 = P2;
                    break;
                end
                
                d1 = sqrt(sum((P1 - P0) .^ 2));
                d2 = sqrt(sum((P2 - P0) .^ 2));
                
                if (d1 <= d2)
                    P2(X) = 0.5 * P1(X) + 0.5 *P2(X);
                    P2(Y) = polyval(pp, P2(X));
                else
                    P1(X) = 0.5 * P1(X) + 0.5 *P2(X);
                    P1(Y) = polyval(pp, P1(X));
                end
            end
        end
        
        closestPoints(np, 1:2) = P0;
    end
else
    % FIT_YX
    for np = 1:numOfPoints
        P0(X) = line(np, X);
        P0(Y) = line(np, Y);
        
        % only check valid points
        if line(np, 3) ~= INVALID_FLAG
            P1(Y) = P0(Y);
            P1(X) = polyval(pp, P1(Y));
            
            % define curve function
            P2(Y) = P0(Y) - 5;
%             f = @(y)pp(1)*y^4 + pp(2)*y^3 + pp(3)*y^2 + pp(4)*y + pp(5) - P2(X);
%             options=optimset('MaxIter',1e3,'TolFun',1e-3);
%             P2(Y) = fsolve(f, P0(Y), options);
            P2(X) = polyval(pp, P2(Y));
            while (1)
                if abs(P2(Y) - P1(Y)) < DIST_TH
                    P0 = P2;
                    break;
                end
                
                d1 = sqrt(sum((P1 - P0) .^ 2));
                d2 = sqrt(sum((P2 - P0) .^ 2));
                
                if (d1 <= d2)
                    P2(Y) = 0.5 * P1(Y) + 0.5 *P2(Y);
                    P2(X) = polyval(pp, P2(Y));
                else
                    P1(Y) = 0.5 * P1(Y) + 0.5 *P2(Y);
                    P1(X) = polyval(pp, P1(Y));
                end
            end
        end
        closestPoints(np, 1:2) = P0;
    end
end