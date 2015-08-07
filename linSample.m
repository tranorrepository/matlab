function sampleData = linSample(lineParams, solidLinePointsCnt)
% LINSAMPLE
%   resample point linearly by using center, length and theta
%
%   INPUT:
%
%   lineParams - 
%     (center x, center y, points count, length, width, theta)
%   solidLinePointsCnt - merged solid line points count
%
%   OUTPUT:
%
%   sampleData - resample points of dotted line data. total points is the
%                same as solid line valid points count.
%                format is (x, y, paint)
%
%                1 1 1 1 * 1 1 1 1 0 0 0 0 1 1 1 1 1 * 1 1 1 1 1 0 0 0
%                \_______________/         \___________________/
%                     length 1                    length 2
%                \_______________________/ \_________________________/
%                         center 1                   center 2
%
%
%

items = size(lineParams, 1);
sampleData = zeros(solidLinePointsCnt, 3);

% average points for each dotted line center
averageCnt = floor(solidLinePointsCnt / items);

% 3/4 of each dottedd line block is paint, 1/4 is not painted
sampleDotLinePaintCnt = floor(0.75 * averageCnt * ones(items, 1));

% dotted line paint points count, average merged point count
% sampleDotLinePaintCnt = round(0.5 * lineParams(:, 3));

% total paint points count
paintCnt = sum(sampleDotLinePaintCnt);

% sample no paint points
nopaintBlkCnt = 0;
remainCnt = 0;
if solidLinePointsCnt > paintCnt
    nopaintBlkCnt = floor((solidLinePointsCnt - paintCnt) / items);
    remainCnt = solidLinePointsCnt - paintCnt - nopaintBlkCnt * items;
end

%
index = 1;
for i = 1:items
    xPoint0 = lineParams(i, 1) + 0.5 * lineParams(i, 4) .* cos(lineParams(i, 6));
    yPoint0 = lineParams(i, 2) + 0.5 * lineParams(i, 4) .* sin(lineParams(i, 6));
    
    
    xPoint1 = lineParams(i, 1) - 0.5 * lineParams(i, 4) .* cos(lineParams(i, 6));
    yPoint1 = lineParams(i, 2) - 0.5 * lineParams(i, 4) .* sin(lineParams(i, 6));
    
    % paint points
    sampleData(index : index + sampleDotLinePaintCnt(i) - 1, 1) = linspace(xPoint0, xPoint1, sampleDotLinePaintCnt(i));
    sampleData(index : index + sampleDotLinePaintCnt(i) - 1, 2) = linspace(yPoint0, yPoint1, sampleDotLinePaintCnt(i));
    sampleData(index : index + sampleDotLinePaintCnt(i) - 1, 3) = 1;
    
    index = index + sampleDotLinePaintCnt(i);
    
    % if needed this for output, uncomment it
%     sampleData(index, 3) = linspace(lineParams(i, 3), lineParams(i, 3), sampleDotLinePaintCnt(i));
%     sampleData(index, 4) = linspace(lineParams(i, 4), lineParams(i, 4), sampleDotLinePaintCnt(i));
%     sampleData(index, 5) = linspace(lineParams(i, 5), lineParams(i, 5), sampleDotLinePaintCnt(i));
%     sampleData(index, 6) = linspace(lineParams(i, 6), lineParams(i, 6), sampleDotLinePaintCnt(i));
%     
    % no paint points
    if i < items
        xPoint2 = lineParams(i+1, 1) + 0.5 * lineParams(i+1, 4) .* cos(lineParams(i+1, 6));
        yPoint2 = lineParams(i+1, 2) + 0.5 * lineParams(i+1, 4) .* sin(lineParams(i+1, 6));
    else
        ratio = (sampleDotLinePaintCnt(items) + nopaintBlkCnt + remainCnt) / sampleDotLinePaintCnt(items);
        xPoint2 = ratio * (xPoint0 - xPoint1) + xPoint1;
        yPoint2 = ratio * (yPoint0 - yPoint1) + yPoint1;
    end
    
    sampleData(index : index + nopaintBlkCnt - 1, 1) = linspace(xPoint1, xPoint2, nopaintBlkCnt);
    sampleData(index : index + nopaintBlkCnt - 1, 2) = linspace(yPoint1, yPoint2, nopaintBlkCnt);
    sampleData(index : index + nopaintBlkCnt - 1, 3) = 0;
    
    index = index + nopaintBlkCnt;
end