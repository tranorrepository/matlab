function laneNumber = laneNumberEst(newdata,segconfig)
load('common.mat');

% line type of new data lines
ltype = getLineType(newdata{1, 2}{1, 1});
rtype = getLineType(newdata{1, 2}{1, 2});

if ltype == DASH_LINE
    l = 0;
else
    l = 1;
end
if rtype == DASH_LINE
    r = 0;
else
    r = 1;
end

lane = [l, r];

numOfLanes = size(segconfig{1, 3}, 2);

% find matched lane
laneNumber = 1;
for ii = 1:numOfLanes
    if 2 == sum((segconfig{1, 3}{1, ii} == lane))
        laneNumber = ii;
        break;
    end
end
return;
