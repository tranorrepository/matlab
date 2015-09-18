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

function laneNumber = laneNumberEst(ind11, ind22, xbodylist, segcfg)
% LANENUMBEREST
%    lane number estimation
%
%    INPUT:
%    ind11     - left line dash block start/stop index
%    ind22     - right line dash block start/stop index
%    xbodylist - section body list of line x data
%    segcfg    - section configuration parameters
%
%    OUTPUT:
%    laneNumber - estimated lane number
%

% get the line within the section body
% left line
cntLeft = 1;
lenL = [];
for k = 1:size(ind11, 1)
    a1 = max(ind11(k, 1), xbodylist(1));
    a2 = min(ind11(k, 2), xbodylist(end));
    if  (a1 < a2) && (a1 >= xbodylist(1)) && (a2 <= xbodylist(end))
        lenL(cntLeft) = abs(a2 - a1);
        cntLeft = cntLeft + 1;
    end
end

% right line
cntRight = 1;
lenR = [];
for k = 1:size(ind22,1)
    a1 = max(ind22(k, 1), xbodylist(1));
    a2 = min(ind22(k, 2), xbodylist(end));
    if (a1 < a2 ) && (a1 >= xbodylist(1)) && (a2 <= xbodylist(end))
        lenR(cntRight) = abs(a2 - a1);
        cntRight = cntRight + 1;
    end
end

if isempty(lenL) || isempty(lenR)
    laneNumber = [];
else
    T = 40;
    
    mL = mean(lenL);
    sL = std(lenL);
    
    mR = mean(lenR);
    sR = std(lenR);
    
    LL = mL + sL;
    RR = mR + sR;
    
    if LL > RR
        if LL / RR < 2
            if RR > T
                lane = {'11'};
            else
                lane = {'00'};
            end
        elseif LL < T
            lane = {'00'};
        elseif RR > 2 * T
            lane = {'11'};
        else
            lane = {'10'};
        end
    else
        if RR / LL < 2
            if LL > T
                lane = {'11'};
            else
                lane = {'00'};
            end
        elseif RR < T
            lane = {'00'};
        elseif LL > 2 * T
            lane = {'11'};
        else
            l = 0;
            r = 1;
            lane = {'01'};
        end
    end
    
    % find matched lane
    laneNumber = 1;
    for ii = 1:segcfg.laneNum
        if isequal(segcfg.laneType(ii), lane)
            laneNumber = ii;
            break;
        end
    end
end


end