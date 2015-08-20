function laneOut = dataPreProc(laneIn,xlist,theta,fitFlag,matchedLane,segID) 

PAINT_IND = 3;
fitOrder = 6;

step = xlist(2)-xlist(1);

nl1 = laneIn{1, 1};
nl2 = laneIn{1, 2};
%% Plot new data
% plot
figure(300)
subplot(2,2,4)
hold off
plot(nl1(nl1(:,3)>0,1),nl1(nl1(:,3)>0,2),'r.',nl2(nl2(:,3)>0,1),nl2(nl2(:,3)>0,2),'b.');
axis equal;
grid on;
title('New data before processing');
%% Fitting for new data lines
% Rotate the newLines.
lineIn.x = nl1(:,1);
lineIn.y = nl1(:,2);
lineOut0 = rotline(lineIn,-theta);

lineIn.x = nl2(:,1);
lineIn.y = nl2(:,2);
lineOut1 = rotline(lineIn,-theta);

% find the both end of the line.
dotBlkIndex1 = dotLineBlockIndex(nl1);
dotBlkIndex2 = dotLineBlockIndex(nl2);

% map to x value on the xlist.
xx1 = lineOut0.x(dotBlkIndex1(:),1);
xx2 = lineOut1.x(dotBlkIndex2(:),1);

xx1 = reshape(xx1,length(xx1)/2,2);
xx2 = reshape(xx2,length(xx2)/2,2);

% get x index in the Xlist.
n = length(xlist);

ii1 = round((xx1 - xlist(1))/step) + 1;
ii1(ii1 < 1) = 1;
ii1(ii1 > n) = n;

ii2 = round((xx2 - xlist(1))/step) + 1;
ii2(ii2 < 1) = 1;
ii2(ii2 > n) = n;

%Paint
paint1 = zeros(size(xlist));
paint2 = zeros(size(xlist));

for k = 1:size(ii1,1)
paint1(ii1(k,1):ii1(k,2)) = 1;
end

for k = 1:size(ii2,1)
paint2(ii2(k,1):ii2(k,2)) = 1;
end

%% data fitting
ind0 = find(nl1(:, PAINT_IND) > 0);
ind1 = find(nl2(:, PAINT_IND) > 0);

lineOut0.x = lineOut0.x(ind0);
lineOut0.y = lineOut0.y(ind0);

lineOut1.x = lineOut1.x(ind1);
lineOut1.y = lineOut1.y(ind1);

index0 = intersect(find(lineOut0.x),find(lineOut0.y));
index1 = intersect(find(lineOut1.x),find(lineOut1.y));

% first line
if fitFlag   
    v = lineOut0.x(index0);
    w = lineOut0.y(index0);
    [y1] = dataResample(xlist,w,v);    
   
    v = lineOut1.x(index1);
    w = lineOut1.y(index1);
    [y2] = dataResample(xlist,w,v);
else  
    [p, S, mu] = polyfit(lineOut0.x(index0),lineOut0.y(index0),fitOrder);
    [y1, ~] = polyval(p, xlist, S, mu);
    % second line   
    [p, S, mu] = polyfit(lineOut1.x(index1),lineOut1.y(index1),fitOrder);
    [y2, ~] = polyval(p, xlist, S, mu);
end

laneOut = { [xlist' y1' paint1'] ,[xlist' y2' paint2']};

% plot
figure(300)
subplot(2,2,matchedLane)
plot(xlist(paint1>0),y1(paint1>0),'r.',xlist(paint2>0),y2(paint2>0),'b.');
axis equal;
grid on;
hold on
title(['Lane number =' num2str(matchedLane) ', SecID = ' num2str(segID)]);
 return;
