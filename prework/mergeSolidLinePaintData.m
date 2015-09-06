function mergedSolidLine = mergeSolidLinePaintData(solidLine0, mergedCnt0, solidLine1, mergedCnt1)
% MERGESOLIDLINEPAINTDATA
%   merge two solid lines according to closest point match
%
%   INPUT:
%
%   solidLine0, solidLine1 - two input solid lines, each of them contains
%                            2 columns mapping to x, y cordinate, paint
%                            flag
%
%   OUTPUT:
%
%   mergedSolidLine - merged solid line parameters, 2 columns, (x, y, paint)
%
%

% input parameter validation
if size(solidLine0, 2) ~= size(solidLine1, 2)
    error('Invalid parameters for function mergeSolidLinePaintData()');
end

solidLine = cell(2, 1);
solidLine{1, 1} = solidLine0;
solidLine{2, 1} = solidLine1;

items0 = size(solidLine0, 1);
items1 = size(solidLine1, 1);

if items0 <= items1
    itemsMin = items0;
    itemsMinInd = 1;
    itemsMaxInd = 2;
else
    itemsMin = items1;
    itemsMinInd = 2;
    itemsMaxInd = 1;
end

mergedSolidLine = zeros(itemsMin, size(solidLine0, 2));

% distance matrix
matchIndex  = zeros(itemsMin, 1);
% tmpDistData = ones(itemsMax, 2);
for i = 1:itemsMin
%     tmpDistData(:, :) = 1;
%     tmpDistData(:, 1) = tmpDistData(:, 1) * solidLine{itemsMinInd}(i, 1);
%     tmpDistData(:, 2) = tmpDistData(:, 2) * solidLine{itemsMinInd}(i, 2);
%     distData = tmpDistData(:, 1:2) - solidLine{itemsMaxInd}(:, 1:2);
%     distData = distData .* distData;
%     dist = distData(:, 1) + distData(:, 2);
%     [~, minDistIndex] = min(dist);
%     matchIndex(i) = minDistIndex;
    matchIndex(i) = minDistIndex(solidLine{itemsMinInd, 1}(i, 1:2), ...
                                 solidLine{itemsMaxInd, 1}(:, 1:2));
    
    mergedSolidLine(i, 1:3) = 0.5 * solidLine{itemsMinInd, 1}(i, 1:3) + ...
                              0.5 * solidLine{itemsMaxInd, 1}(matchIndex(i), 1:3);
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