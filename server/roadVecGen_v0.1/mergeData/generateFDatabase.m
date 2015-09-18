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

function fdatabase = generateFDatabase(database, theta, Xrange)
% GENERATEFDATABASE
%    generate foreground database data
%
%    INPUT:
%    database - background data base section data
%    theta    - current section rotation angle
%    Xrange   - section full x range
%
%    OUTPUT:
%    fdatabase - foreground database lines
%

global PLOT_ON

% Curve Fitting Order
fitOrder = 8;

% Initialize foreground database
fdatabase = struct('segId', 0, 'lineData', []);

% Segment ID of database
segID = database.segId;
fdatabase.segId = segID;

% Step1 : Check the valid lanes number
% Number of lanes in current segment
numOfLanes = size(database.laneData, 1);

if numOfLanes == 0
    return;
end

numOfValidLanes = numOfLanes;
validLaneIndex = 1:numOfLanes;
for lane = 1:numOfLanes
    if isempty(database.laneData{lane})
        numOfValidLanes = numOfValidLanes -1;
        validLaneIndex(lane) = -1;
    end
end

% if 1, 3 lane valid, keep lane 1 and discard lane 3.
if (numOfLanes == 3 && numOfValidLanes == 2 && validLaneIndex(2) == -1)
    numOfValidLanes = 1;
    validLaneIndex(3) = -1;
end

% Step2 : Data fitting
if Xrange(3) < Xrange(4)
    step = 0.1;
else
    step = -0.1;
end
xlist = (Xrange(3):step:Xrange(4))';

% A for data, M for painting for each line.
A = zeros(length(xlist), numOfValidLanes * 2);
M = zeros(length(xlist), numOfValidLanes * 2);
ind = 1;
for lane = validLaneIndex(validLaneIndex > 0)
    % First line
    x = database.laneData{lane}(1).x;
    y = database.laneData{lane}(1).y;
    index = intersect(find(x), find(y));
    [p, S, mu] = polyfit(x(index), y(index), fitOrder);
    [A(:, ind * 2 - 1), ~] = polyval(p, xlist, S, mu);
    
    % Get painting for the line
    M(:, ind * 2 - 1) = database.laneData{lane}(1).paint;
    
    % Second line
    x = database.laneData{lane}(2).x;
    y = database.laneData{lane}(2).y;
    index = intersect(find(x), find(y));
    [p, S, mu] = polyfit(x(index), y(index), fitOrder);
    A(:,ind*2) = polyval(p, xlist, S, mu);
    
    % Get painting for the line
    M(:, ind * 2) = database.laneData{lane}(2).paint;
    
    ind = ind + 1;
end

% Step 3 : Inter-Lane Merging
middleLine = cell(numOfValidLanes - 1, 1);
for n = 1:numOfValidLanes - 1
    % merge middle line
    middleLine{n, 1} = (A(:, 2 * n) + A(:, 2 * n + 1)) / 2;
end

if (numOfValidLanes == 0)
    return
elseif (numOfValidLanes == 1)
    B(:, 1) = A(:, 1);
    B(:, 2) = A(:, 2);
    
    N(:, 1) = M(:, 1);
    N(:, 2) = M(:, 2);
elseif  (numOfValidLanes == 2)
    d0 = middleLine{1, 1} - A(:, 2);
    d1 = middleLine{1, 1} - A(:, 3);
    B(:, 1) = A(:, 1) + d0;
    B(:, 2) = middleLine{1, 1};
    B(:, 3) = A(:, 4) + d1;
    
%     N(:,1) = M(:,1);
%     N(:,2) = M(:,2) + M(:,3);
%     N(:,3) = M(:,4);
    
    N(:, 1) = M(:, 1);
    N(:, 2) = M(:, 2);
    N(:, 3) = M(:, 4);
    
elseif (numOfValidLanes == 3)
    d0 = middleLine{1, 1} - A(:, 2);
    d1 = middleLine{1, 1} - A(:, 3);
    
    d2 = middleLine{2, 1} - A(:, 4);
    d3 = middleLine{2, 1} - A(:, 5);
    
    B(:, 1) = A(:, 1)+ d0 + d2;
    B(:, 2) = middleLine{1, 1} + d2;
    B(:, 3) = middleLine{2, 1} + d1;
    B(:, 4) = A(:, 6) + d1 + d3;

%     N(:,1) = M(:,1);
%     N(:,2) = M(:,2) + M(:,3);
%     N(:,3) = M(:,4) + M(:,5);
%     N(:,4) = M(:,6);
    
    N(:, 1) = M(:, 1);
    N(:, 2) = M(:, 2) ;
    N(:, 3) = M(:, 4) ;
    N(:, 4) = M(:, 6);
else
    warning('Do not support more than 3 lane yet.');
    return;
end

if PLOT_ON
    figure(501)
    subplot(1, 2, 2)
    plot(xlist, B, '-.');
    axis equal; grid on;
    title('FDB: After merging')
end

% Step 4: Cut off the overlap part
if Xrange(1) < Xrange(2)
    index = find(xlist >=  Xrange(1) & xlist <=  Xrange(2));
else
    index = find(xlist <=  Xrange(1) & xlist >=  Xrange(2));
end

% Step 4a: Calculate theta and center point for each end.
y1 = B(index(1:2), :);
y2 = B(index(end - 1:end), :);

ang1 = atan(mean((y1(1, :) - y1(2, :)) / step, 2));
ang2 = atan(mean((y2(1, :) - y2(2, :)) / step, 2));

c1 = mean(y1(1, :), 2);
c2 = mean(y2(end, :), 2);

% Step 4b: Find body range for each line
% start point
p1.x = xlist(index(1));
p1.y = c1;
co1 = rotateLine(p1, ang1);
% end point
p2.x = xlist(index(end));
p2.y = c2;
co2 = rotateLine(p2, ang2);

index2 = cell(numOfValidLanes + 1, 1);
for lane = 1:numOfValidLanes + 1
    lineIn.x = xlist(:);
    lineIn.y = B(:, lane);
    lineOut1 = rotateLine(lineIn, ang1);
    lineOut2 = rotateLine(lineIn, ang2);
    if step > 0
        AA = find(lineOut1.x >= co1.x);
        BB = find(lineOut2.x <= co2.x);
    else
        AA = find(lineOut1.x <= co1.x);
        BB = find(lineOut2.x >= co2.x);
    end
    index2{lane} = intersect(AA, BB);
end

% Step 5: Rotate back to original direction.
numOfUsedLanes = 0;
fdatabase.lineData = cell(numOfLanes + 1, 1);
ind = 1;
for ll = 1:numOfLanes
    if validLaneIndex(ll) == -1
        fdatabase.lineData{ind} = [];
        ind = ind + 1;
        
        numOfUsedLanes = numOfUsedLanes + 1;
    else
        break;
    end
end

for ll = 1:numOfValidLanes + 1
    index = index2{ll};
    lineIn.x = xlist(index);
    lineIn.y = B(index, ll);
    lineOut = rotateLine(lineIn, theta);
    p = N(index, ll);
    
    line.x = lineOut.x;
    line.y = lineOut.y;
    line.paint = p;
    line.count = 0;
    
    fdatabase.lineData{ind} = line;
    ind = ind + 1;
end

numOfUsedLanes = numOfUsedLanes + numOfValidLanes;
while numOfUsedLanes < numOfLanes
    fdatabase.lineData{ind} = [];
    ind = ind + 1;
    
    numOfUsedLanes = numOfUsedLanes + 1;
end

return;
end