function sampleLine = lineMerging(dbLine, newLine)
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


% load common data
load('common.mat');

avgMergedCnt = floor(mean(dbLine(:, MERGED_IND)));

% reliability of merged times
R = reliability(avgMergedCnt);

% closest data point matching
numOfPoints = size(dbLine, 1);

matchIndex = zeros(numOfPoints, 1);
tempData = zeros(numOfPoints, 4);
for p = 1:numOfPoints
    if dbLine(p, 3) ~= INVALID_FLAG
        matchIndex(p) = minDistIndex(dbLine(p, 1:2), newLine);
        tempData(p, 1:3) =      R * dbLine(p, 1:3) + ...
                          (1 - R) * newLine(matchIndex(p), 1:3);
    end
end

% resample for output
tempLine = resampling(tempData);

% add point paint attribute
sampleLine = getPaintInfo(dbLine, newLine, tempLine);


%%
function newLine = resampling(lineData)
%
%   MECHANISM
%
%   traverse all input points, if two adjacent points distance is over
%   threshold, use linear interpolation to add some points. else traverse
%   to next point and resample
%
%   INPUT/OUTPUT:
%
%   lineData
%   newLine   - points on a line
%               (x, y)
%


% load common data
load('common.mat');

% number of points
numOfPoints = size(lineData, 1);

% output initialization
index = 1;
while lineData(index, 1) == 0 && ...
      lineData(index, 2) == 0
      index = index + 1;
end

% first point
newLine(1, :) = lineData(index, :);
stp = index;
index = 1;

% iterate for each point
for np = stp:numOfPoints-1
    if lineData(np, 1) ~= 0 && lineData(np, 2) ~= 0 && ...
            lineData(np + 1, 1) ~= 0 && lineData(np + 1, 2) ~= 0
        d = sqrt(sum((newLine(index, 1:2) - lineData(np + 1, 1:2)) .^ 2));
        if abs(d - SAMPLE_DIST) <= DIST_TH
            % sample distance is less than SAMPLE_DIST
            index = index + 1;
            newLine(index, :) = lineData(np + 1, :);
        elseif d > SAMPLE_DIST + DIST_TH
            % interpolation
            cnt = round(d / SAMPLE_DIST);
            for n = 1:cnt
                index = index + 1;
                newLine(index, 1:2) = lineData(np, 1:2) + ...
                    (lineData(np + 1, 1:2) - lineData(np, 1:2)) * n / cnt;
                newLine(index, 3) = 0.5 * lineData(np, 3) + ...
                    0.5 * lineData(np + 1, 3);
            end
        end
    end
end


%%
function paintLine =  getPaintInfo(dbLine, newLine, sampleLine)
%
%
%

load('common.mat');

avgMergedCnt = floor(mean(dbLine(:, MERGED_IND)));

% reliability of merged times
R = reliability(avgMergedCnt);

% get block start/end index
dbBlk  = dotLineBlockIndex(dbLine);
newBlk = dotLineBlockIndex(newLine);

% number of blocks
numDBBlk  = size(dbBlk, 1);
numNewBlk = size(newBlk, 1);

% start, end, quadratic sum
dbMatchedInd  = zeros(numDBBlk, 3);
newMatchedInd = zeros(numNewBlk, 3);

for nb = 1:numDBBlk
    dbMatchedInd(nb, 1) = minDistIndex(dbLine(dbBlk(nb, 1), 1:2), ...
                                       sampleLine);
    dbMatchedInd(nb, 2) = minDistIndex(dbLine(dbBlk(nb, 2), 1:2), ...
                                       sampleLine);
	dbMatchedInd(nb, 3) = sum((sampleLine(dbMatchedInd(nb, 1)) - ...
                               sampleLine(dbMatchedInd(nb, 2))) .^ 2);
end
for nb = 1:numNewBlk
    newMatchedInd(nb, 1) = minDistIndex(newLine(newBlk(nb, 1), 1:2), ...
                                        sampleLine);
    newMatchedInd(nb, 2) = minDistIndex(newLine(newBlk(nb, 2), 1:2), ...
                                        sampleLine);
	newMatchedInd(nb, 3) = sum((sampleLine(newMatchedInd(nb, 1)) - ...
                                sampleLine(newMatchedInd(nb, 2))) .^ 2);
end

% end points
dbStarts  = sampleLine(dbMatchedInd(:, 1), 1:2);
dbStops   = sampleLine(dbMatchedInd(:, 2), 1:2);
newStarts = sampleLine(newMatchedInd(:, 1), 1:2);
newStops  = sampleLine(newMatchedInd(:, 2), 1:2);

% length of painted dash lines
newDist = sqrt(sum((newStarts(:, 1:2)' - newStops(:, 1:2)') .^ 2))';

starts = zeros(numDBBlk, 2);
stops  = zeros(numDBBlk, 2);

startInd = zeros(numDBBlk, 1);
stopInd = zeros(numDBBlk, 1);

% match less block to more block
for nb = 1:numDBBlk
    startInd(nb) = minDistIndex(dbStarts(nb, 1:2), newStarts);
    stopInd(nb)  = minDistIndex(dbStops(nb, 1:2), newStops);
    
    dist = sqrt(sum((dbStarts(nb, 1:2) - newStarts(startInd(nb), 1:2)) .^ 2));
    
    if dist < newDist(startInd(nb))
        starts(nb, 1:2) = R * dbStarts(nb, 1:2) + ...
            (1 - R) * newStarts(startInd(nb), 1:2);
        stops(nb, 1:2) = R * dbStops(nb, 1:2) + ...
            (1 - R) * newStops(stopInd(nb), 1:2);
    else
        starts(nb, 1:2) = dbStarts(nb, 1:2);
        stops(nb, 1:2) = dbStops(nb, 1:2);
    end
end

% one new dash block is no matching
for nn = 1:numNewBlk
    if isempty(find(nn == startInd, 1))
        numDBBlk = numDBBlk + 1;
        starts(numDBBlk, 1:2) = newStarts(nn, 1:2);
        stops(numDBBlk, 1:2) = newStops(nn, 1:2);
    end
end

% num of points
numOfPoints = size(sampleLine, 1);

% initialize output
paintLine = zeros(numOfPoints, 4);

paintLine(:, 1:3) = sampleLine(:, 1:3);
paintLine(:, 4)  = avgMergedCnt + 1;

linetype = getLineType(dbLine);

if DASH_LINE == linetype
    for np = 1:numOfPoints
        lx = sampleLine(np, X);
        nb = 1;
        while (nb <= numDBBlk)
            if (((starts(nb, X) < stops(nb, X)) && ...
                    (starts(nb, X) <= lx) && (stops(nb, X) > lx)) || ...
                ((starts(nb, X) > stops(nb, X)) && ...
                    (starts(nb, X) >= lx) && (lx > stops(nb, X))))
               break;
            else
                nb = nb + 1;
            end
        end
        
        if nb > numDBBlk
            paintLine(np, 3) = 0;
        else
            paintLine(np, 3) = 1;
        end
    end
else
%     for np = 1:numOfPoints
%         lx = sampleLine(np, X);
%         nb = 1;
%         while (nb <= numDBBlk)
%             if (((starts(nb, X) < stops(nb, X)) && ...
%                     (starts(nb, X) <= lx) && (stops(nb, X) > lx)) || ...
%                 ((starts(nb, X) > stops(nb, X)) && ...
%                     (starts(nb, X) >= lx) && (lx > stops(nb, X))))
%                break;
%             else
%                 nb = nb + 1;
%             end
%         end
%         
%         if nb > numDBBlk
%             paintLine(np, 3) = 0;
%         else
%             paintLine(np, 3) = 1;
%         end
%     end
end



%%
function index = minDistIndex(point, line)

points = size(line, 1);

% find the match center point index
tmpDistData = ones(points, 2);
tmpDistData(:, 1) = tmpDistData(:, 1) * point(1, 1);
tmpDistData(:, 2) = tmpDistData(:, 2) * point(1, 2);
distData = tmpDistData(:, 1:2) - line(:, 1:2);
distData = distData .* distData;
dist = distData(:, 1) + distData(:, 2);
[~, index] = min(dist);


% start = 1;
% stop = points;
% 
% while (start < stop)
%     distData0 = point - line(start, 1:2);
%     distData1 = point - line(stop, 1:2);
%     dist0 = sum(distData0 * distData0');
%     dist1 = sum(distData1 * distData1');
%     
%     if dist0 < dist1
%         stop = floor(0.5 * start + 0.5 * stop);
%     else
%         start = floor(0.5 * start + 0.5 * stop + 0.5);
%     end
% end
% 
% index = start;