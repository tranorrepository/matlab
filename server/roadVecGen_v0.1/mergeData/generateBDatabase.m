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

function bdatabase = generateBDatabase(segcfg, database, newdata, theta, xlimit)
% GENERATEBDATABASEE
%    generate background database
%    merge reported new data with correspding lane in background database
%
%    INPUT:
%    segcfg   - current section configuration data
%    database - database line data
%    newdata  - reported new line data
%    theta    - section rotation angle
%    xlimit   - section full x limits
%
%    OUTPUT:
%    bdatabase - updated database line data
%

global PLOT_ON

if xlimit(3) < xlimit(4)
    step = 0.1;    
else
    step = -0.1;    
end
xfulllist = (xlimit(3):step:xlimit(4))';

A = round((xlimit(1) - xlimit(3)) / step) + 1;
B = round((xlimit(2) - xlimit(3)) / step) + 1;
xbodylist = A:B; 

bdatabase = database;

% number of lanes in current segment
numOfLanes = segcfg.laneNum;

% process new data before merging.
[newlane, matchedLane] = dataPreProcessing(newdata.lineData, ...
                                             xfulllist, xbodylist, ...
                                             theta, segcfg);

if ~isempty(newlane)
    % merge database line data with new reported data
    if isempty(bdatabase.laneData)
        bdatabase.laneData = cell(numOfLanes, 1);
        bdatabase.laneData{matchedLane} = newlane;
    elseif isempty(bdatabase.laneData{matchedLane})
        bdatabase.laneData{matchedLane} = newlane;
    else
        dblines = bdatabase.laneData{matchedLane};
        newlane = dataMerging(newlane, dblines);
        bdatabase.laneData{matchedLane} = newlane;
    end
    
    % plot data
    if PLOT_ON
        figure(400)
        subplot(3, 1, matchedLane);
        hold off
        
        l1 = newlane(1);
        l2 = newlane(2);
        
        p1 = l1.paint;
        p2 = l2.paint;
        ind1 = (p1 / max(p1)) >= 0.5;
        ind2 = (p2 / max(p2)) >= 0.5;
        
        plot(l1.x(ind1), l1.y(ind1), 'r.');
        hold on; grid on; axis equal
        plot(l2.x(ind2), l2.y(ind2), 'g.');
        title(['BG data, SecID = ' num2str(segcfg.segId) ', Lane number = ' ...
              num2str(matchedLane)]);
    end
else
    % do nothing.
end


end