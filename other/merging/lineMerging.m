function [sampleLine, vec] = lineMerging(dbLine, newLine)
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
% number of valid paint points
numOfDBVP  = sum(dbLine(:, PAINT_IND) ~= INVALID_FLAG);
numOfNewVP = sum(newLine(:, PAINT_IND) ~= INVALID_FLAG);

numOfPoints = size(dbLine, 1);
minLine = newLine;
maxLine = dbLine;
if numOfDBVP < numOfNewVP
    numOfPoints = size(newLine, 1);
    minLine = dbLine;
    maxLine = newLine;
end

matchIndex = zeros(numOfPoints, 1);
tempData = zeros(numOfPoints, 4);
tempMove = zeros(numOfPoints, 4);
for p = 1:numOfPoints
    if maxLine(p, 3) >= 0 %~= INVALID_FLAG
        matchIndex(p) = minDistIndex(maxLine(p, 1:2), minLine);
        tempData(p, 1:3) =      R * maxLine(p, 1:3) + ...
                          (1 - R) * minLine(matchIndex(p), 1:3);
        if numOfDBVP > numOfNewVP
            tempMove(p, 1:2) = tempData(p, 1:2) - dbLine(p, 1:2);
            tempMove(p, 3:4) = tempData(p, 1:2) - newLine(matchIndex(p), 1:2);
        else            
            tempMove(p, 1:2) = tempData(p, 1:2) - dbLine(matchIndex(p), 1:2);
            tempMove(p, 3:4) = tempData(p, 1:2) - newLine(p, 1:2);
        end
    end
end

% shift vector
vec = mean(tempMove(:, 1:4));

% resample for output
tempLine = resampling(tempData);

if 0 %PLOT_ON
    figure(301)
    plot(dbLine(dbLine(:, 3) == 1, X), dbLine(dbLine(:, 3) == 1, Y), 'k.');
    hold on;
    plot(newLine(newLine(:, 3) == 1, X), newLine(newLine(:, 3) == 1, Y), ...
        'b.'); hold on;
    plot(tempLine(:, X), tempLine(:, Y), 'm'); hold on;
    axis equal;
end

% add point paint attribute
sampleLine = getPaintInfo(dbLine, newLine, tempLine);

if 0%PLOT_ON
    figure(301);
    hold off;
end

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
while index <= numOfPoints && ...
      lineData(index, 1) == 0 && ...
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

paintLine = sampleLine;
paintLine(:, 4) = avgMergedCnt + 1;
return;


avgMergedCnt = floor(mean(dbLine(:, MERGED_IND)));

% init output
paintLine = sampleLine;
paintLine(:, 4) = avgMergedCnt + 1;

linetype = getLineType(dbLine);

if DASH_LINE == linetype
    % get block start/end index
    dbBlk  = dotLineBlockIndex(dbLine);
    newBlk = dotLineBlockIndex(newLine);
    
    % number of blocks
    numDBBlk  = size(dbBlk, 1);
    numNewBlk = size(newBlk, 1);
    
    % length of each block
    dbLen  = dbBlk(:, 2) - dbBlk(:, 1);
    newLen = newBlk(:, 2) - newBlk(:, 1);
    
    avgPaintCnt = round(0.5 * round(mean(dbLen)) + 0.5 * round(mean(newLen)));
    numBlk = round(0.5 * numDBBlk + 0.5 * numNewBlk);
    
    numOfPoints = size(sampleLine, 1);
    avgNonPaintCnt = round((numOfPoints - avgPaintCnt * numBlk) / numBlk);
    % remainCnt = numOfPoints - (avgNonPaintCnt + avgPaintCnt) * numBlk;

    
    index = 1;
    for nb = 1:numBlk
        paintLine(index : index + avgPaintCnt - 1, 3) = 1;
        index = index + nb * (avgPaintCnt + avgNonPaintCnt);
    end
    
    for np = 1:numOfPoints
        index = mod(np, (avgPaintCnt + avgNonPaintCnt));
        if index >= 1 && index <= avgPaintCnt
            paintLine(np, 3) = 1;
        end
    end
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