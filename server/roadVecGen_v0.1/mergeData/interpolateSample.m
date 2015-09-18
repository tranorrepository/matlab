%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Continental Confidential
%                  Copyright (c) Continental, LLC. 2015
%
%      This software is furnished under license and may be used or
%      copied only in accordance with the terms of such license.
%
% Change Log:
%      Date                    Who                    What
%      2015/09/11              Ming Chen              Create
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yout] = interpolateSample(xlist, xin, yin)
% INTERPOLATESAMPLE
%    resample data with input x range
%
%    INPUT:
%    xlist - section full x list after rotation
%    xin   - input x data
%    yin   - input y data
%
%    OUTPUT:
%    yout  - output y data corresponding to xlist
%

X1 = xlist(1);
X2 = xlist(end);

ind0 = 1;
yout = zeros(length(xlist), 1);

for kk = 1:length(xlist)
    % find X1 X2
    xx = xlist(kk);
    if (X1 < X2)
        x1 = xin(ind0);
        y1 = yin(ind0);
        while xx > x1
            ind0 = ind0 + 1;
            if ind0 < length(xin)
                x1 = xin(ind0);
                y1 = yin(ind0);
            else
                ind0 = ind0 -1;
                x1 = xin(ind0);
                y1 = yin(ind0);
                break;
            end
        end
        
        if (ind0 > 1)
            x0 = xin(ind0-1);
            y0 = yin(ind0-1);
        else
            x0 = xin(1);
            y0 = yin(1);
        end
        
        if (x0 == x1)
            yout(kk) = y0;
        else
            yout(kk) = (x0 - xx) / (x0 - x1) * y1 + ...
                       (xx - x1) / (x0 - x1) * y0;
        end
    else
        x1 = xin(ind0);
        y1 = yin(ind0);
        while xx < x1
            ind0 = ind0 + 1;
            if ind0 < length(xin)
                x1 = xin(ind0);
                y1 = yin(ind0);
            else
                ind0 = ind0 - 1;
                x1 = xin(ind0);
                y1 = yin(ind0);
                break;
            end
        end
        if (ind0 > 1)
            x0 = xin(ind0 - 1);
            y0 = yin(ind0 - 1);
        else
            x0 = xin(1);
            y0 = yin(1);
        end
        if (x0 == x1)
            yout(kk) = y0;
        else
            yout(kk) = (x0 - xx) / (x0 - x1) * y1 + ...
                       (xx - x1) / (x0 - x1) * y0;
        end
    end
end


end