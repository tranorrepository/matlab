function laneOut = dataPreProc(laneIn,xlist,theta,fitFlag) 

PAINT_IND = 3;
fitOrder = 6;

nl1 = laneIn{1, 1};
nl2 = laneIn{1, 2};
%% Fitting for new data lines
% Rotate the newLines.
lineIn.x = nl1(nl1(:, PAINT_IND) >= 0,1);
lineIn.y = nl1(nl1(:, PAINT_IND) >= 0,2);
lineOut0 = rotline(lineIn,-theta);

lineIn.x = nl2(nl2(:, PAINT_IND) >= 0,1);
lineIn.y = nl2(nl2(:, PAINT_IND) >= 0,2);
lineOut1 = rotline(lineIn,-theta);

%% data fitting
% first line
if fitFlag
    index = intersect(find(lineOut0.x),find(lineOut0.y));
    v = lineOut0.x(index);
    w = lineOut0.y(index);
    [y1] = dataResample(xlist,w,v);
    
    index = intersect(find(lineOut1.x),find(lineOut1.y));
    v = lineOut1.x(index);
    w = lineOut1.y(index);
    [y2] = dataResample(xlist,w,v);
else
    
    index = intersect(find(lineOut0.x),find(lineOut0.y));
    [p, S, mu] = polyfit(lineOut0.x(index),lineOut0.y(index),fitOrder);
    [y1, ~] = polyval(p, xlist, S, mu);
    % second line
    index = intersect(find(lineOut1.x),find(lineOut1.y));
    [p, S, mu] = polyfit(lineOut1.x(index),lineOut1.y(index),fitOrder);
    [y2, ~] = polyval(p, xlist, S, mu);
end

laneOut = { [xlist' y1' ones(size(y1'))] ,[xlist' y2' ones(size(y2'))]};
return;
