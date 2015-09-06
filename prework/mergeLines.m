function mergedLine = mergeLines(line1, line2, lineType1, ...
                                 line3, line4, lineType2)
% MERGELINES
%   merge two line together
%
%   INPUT:
%
%   line1     - database data
%   line2     - new data
%   lineType1 - line type, dottedd (0) or solid (1)
%   line3     - database data
%   line4     - new data
%   lineType2 - line type, dottedd (0) or solid (1)
%
%   OUTPUT
%
%   mergedLine - merged line data
%                cell(1, 2)
%                  (x, y, paint, merged count)
%
%

% line type declare
DOTTED_LINE = 0;
SOLID_LINE = 1;

% for now, not support four solod line merge
if SOLID_LINE == lineType1 && SOLID_LINE == lineType2
    error('Invalid line type for mergeLines');
end

% all lines are dotted lines
if DOTTED_LINE == lineType1 && DOTTED_LINE == lineType2
    lines = cell(2, 2);
    lines{1, 1} = line1;
    lines{1, 2} = line2;
    lines{2, 1} = line3;
    lines{2, 2} = line4;
    
    mergedLine = cell(1, 2);
    
    for ln = 1:2
        resampleCnt = size(lines{ln, 1}, 1);
        
        % get dotted line parameters
        blkIndex1 = getLineBlkIndex(lines{ln, 1});
        blkIndex2 = getLineBlkIndex(lines{ln, 2});
        blkParams1 = getLineBlkParams(line1, blkIndex1);
        blkParams2 = getLineBlkParams(line2, blkIndex2);
        
        % merge dotted line parameters
        mergedCnt1 = mean(line1(:, 4));
        mergedCnt2 = mean(line2(:, 4));
        mergedParams = mergeDotLineParams(blkParams1, mergedCnt1, ...
                                          blkParams2, mergedCnt2);
        
        % resample
        mergedLine{1, ln}(:, 1:3) = linSample(mergedParams, resampleCnt);
        mergedLine{1, ln}(:, 4)   = mergedCnt1 + mergedCnt2;
    end
    return;
end

% one dotted line, one solid line
% first two is dotted line, second two is solid line
if DOTTED_LINE == lineType1 
    % get dotted line parameters
    blkIndex1 = getLineBlkIndex(line1);
    blkIndex2 = getLineBlkIndex(line2);
    blkParams1 = getLineBlkParams(line1, blkIndex1);
    blkParams2 = getLineBlkParams(line2, blkIndex2);
    
    % match dotted line center
    matchedInd = matchDotLineCenter(blkParams1, blkParams2);
    
    % merge dotted line parameters
    mergedCnt1 = mean(line1(:, 4));
    mergedCnt2 = mean(line2(:, 4));
    [mergedParams, moveVector] = mergeDotLineParams(...
                                      blkParams1, mergedCnt1, ...
                                      blkParams2, mergedCnt2);
    
    % resample
    mergedLine(:, 1:3) = linSample(mergedParams, resampleCnt);
    mergedLine(:, 4)   = mergedCnt1 + mergedCnt2;
    
end

if SOLID_LINE == lineType
    mergedLine = line1;
end




resampleCnt = size(line1, 1);
mergedLine = zeros(resampleCnt, 4);




%%
function blkData = getLineBlkParams(lineData, dotBlkIndex)
%
%   lineData - (x, y, paint, merged count)
%
%   blkData  - organized center, length, width and angle data
%             (x, y, point count, lenght, width, angle)

% assume the data is organized as expected
items = size(dotBlkIndex, 1);

% center
dotLineC = zeros(items, 3); % x, y, count
dotLineC(:, 3) = (dotBlkIndex(:, 2) - dotBlkIndex(:, 1) + 1);

lengthData = zeros(items, 2);
% widthData  = zeros(items, 2);
for i = 1:items
    % center
    dotLineC(i, 1:2) = sum(lineData(dotBlkIndex(i, 1):dotBlkIndex(i, 2), 1:2)) / dotLineC(i, 3);
    
    % for length calculation
    lengthData(i, :) = lineData(dotBlkIndex(i, 2), 1:2) - ...
                       lineData(dotBlkIndex(i, 1), 1:2);
    % width
%     widthData(i, 1) = sum(lineData(dotBlkIndex(i, 1):dotBlkIndex(i, 2), dotLineIndex + 3) - ...
%                           lineData(dotBlkIndex(i, 1):dotBlkIndex(i, 2), dotLineIndex + 1));
%     widthData(i, 2) = sum(lineData(dotBlkIndex(i, 1):dotBlkIndex(i, 2), dotLineIndex + 4) - ...
%                           lineData(dotBlkIndex(i, 1):dotBlkIndex(i, 2), dotLineIndex + 2));
end

% angle
theta = angle(lengthData(:, 1) + lengthData(:, 2)*1j);

theta(theta < 0) = pi + theta(theta < 0);

% length
length = zeros(items, 1);
lengthData = lengthData .* lengthData;
length(:) = sqrt(lengthData(:, 1) + lengthData(:, 2));

% width
width = zeros(items, 1);
% widthData = widthData .* widthData;
% width(:) = sqrt(widthData(:, 1) + widthData(:, 2));

blkData = [dotLineC, length, width, theta];


%%
function dotBlkIndex = getLineBlkIndex(lineData)
%
% dotted line start/stop index
% from which index to which the dotted/slid line starts and ends
PAINT_INDEX = 3;
items = size(lineData, 1);
dotBlkIndex = zeros(1, 2); % start, stop
blkIndex = 1;
bChanged = false;
for i = 1:items
    value = lineData(i, PAINT_INDEX);
    if (1.0 == value)
        if (false == bChanged)
            dotBlkIndex(blkIndex, 1) = i;   % start
        end
        bChanged = true;
    else
        if (true == bChanged)
            dotBlkIndex(blkIndex, 2) = i-1; % stop
            if 10 < (dotBlkIndex(blkIndex, 2) - dotBlkIndex(blkIndex, 1))
                blkIndex = blkIndex + 1;
            end
            bChanged = false;
        end
    end
end

if (true == bChanged) && (0 == dotBlkIndex(blkIndex, 2))
    dotBlkIndex(blkIndex, 2) = items;
end

%%
function matchIndex = matchDotLineCenter(dotLineParams0, dotLineParams1)

items0 = size(dotLineParams0, 1);
items1 = size(dotLineParams1, 1);

itemsMin = items0;
itemsMax = items1;
dotLineParamsMin = dotLineParams0;
dotLineParamsMax = dotLineParams1;
if (items0 > items1)
    itemsMin = items1;
    itemsMax = items0;
    dotLineParamsMin = dotLineParams1;
    dotLineParamsMax = dotLineParams0;
end

% find the match center point index
matchIndex  = zeros(itemsMin, 1);
tmpDistData = ones(itemsMax, 2);
for i = 1:itemsMin
    tmpDistData(:, :) = 1;
    tmpDistData(:, 1) = tmpDistData(:, 1) * dotLineParamsMin(i, 1);
    tmpDistData(:, 2) = tmpDistData(:, 2) * dotLineParamsMin(i, 2);
    distData = tmpDistData(:, 1:2) - dotLineParamsMax(:, 1:2);
    distData = distData .* distData;
    dist = distData(:, 1) + distData(:, 2);
    [~, minDistIndex] = min(dist);
    matchIndex(i) = minDistIndex;
end