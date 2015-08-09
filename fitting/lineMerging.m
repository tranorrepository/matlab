function newLine = lineMerging(dbLine, newLine)
% LINEMERGING
%   merge two input lines
%
%   INPUT:
%
%   dbLine  - database line data
%             (x, y, paint flag, merged count)
%
%   newLine - new input line needed to be merged to database
%             (x, y, paint flag, merged count)
%                                merged count should be 1
%
%

avgMergedCnt = floor(mean(dbLine(:, MERGED_IND)));

% reliability of merged times
R = reliability(avgMergedCnt);

% closest data point matching
numOfPoints = size(dbLine, 1);

matchIndex = zeros(numOfPoints, 1);
tempData = zeros(numOfPoints, 2);
for p = 1:numOfPoints
    matchIndex(p) = minDistIndex(dbLine(p, 1:2), newLine);
    tempData(p, 1:2) =      R * dbLine(p, 1:2) + ...
                      (1 - R) * newLine(matchIndex(p), 1:2);
end

tempLine{1} = tempData;

% fitting for matched point pair
pp = polyfit(tempLine(:, X), tempLine(:, Y), FIT_DEGREE);

linetype = getlineType(dbLine);

% for dotted line find block index
if DASH_LINE == linetype
    dbBlk  = dotLineBlockIndex(dbLine);
    newBlk = dotLineBlockIndex(newLine);
    
    dbStart(:, X)  = dbLine(dbBlk(:, 1), X);
    dbStop(:, X)   = dbLine(dbBlk(:, 2), X);
    newStart(:, X) = newLine(newBlk(:, 1), X);
    newStop(:, X)  = newLine(newBlk(:, 2), X);
    
    dbStart(:, Y)  = polyval(pp, dbStart(:, X));
    dbStop(:, Y)   = polyval(pp, dbStop(:, X));
    newStart(:, Y) = polyval(pp, newStart(:, X));
    newStop(:, Y)  = polyval(pp, newStop(:, X));
    
    % match start/stop points
    numOfBlks = size(newBlk, 1);
    startMatchIndex = zeros(numOfBlks, 1);
    stopMatchIndex = zeros(numOfBlks, 1);
    
    index = 1;
    mergedStartStop = zeros(index, 4);
    
    for nb = 1:numOfBlks
        startMatchIndex(nb) = minDistIndex(newStart(nb, :), dbStart);
        stopMatchIndex(nb)  = minDistIndex(newStop(nb, :), dbStop);
        
        if startMatchIndex(nb) == stopMatchIndex(nb)
            % matched to the same dash line
            mergedStartStop(:, 1:2) = R * dbStart(startMatchIndex(nb), 1:2) + ...
                                (1 - R) * newStart(db, 1:2);
            mergedStartStop(:, 3:4) = R * dbStop(stopMatchIndex(nb), 1:2) + ...
                                (1 - R) * newStop(db, 1:2);
        elseif startMatchIndex(nb) < stopMatchIndex(nb)
            % not the same dash line
            
        end
    end
    
    
else
end


%%
function index = minDistIndex(point0, solidLineMax)

points = size(solidLineMax, 1);

start = 1;
stop = points;

while (start < stop)
    distData0 = point0 - solidLineMax(start, :);
    distData1 = point0 - solidLineMax(stop, :);
    dist0 = sum(distData0 * distData0');
    dist1 = sum(distData1 * distData1');
    
    if dist0 < dist1
        stop = floor(0.5 * start + 0.5 * stop);
    else
        start = floor(0.5 * start + 0.5 * stop + 0.5);
    end
end

index = start;