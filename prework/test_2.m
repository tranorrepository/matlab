% TEST_2
% solid line move and merge for honda data

clear all; clc;
format long

% % ford data
% all *.mat is organized as a cell, named data
load('honda.mat');

% plot count used to delete object
plotCount = 0;

% number of data set in data
datasetNum = size(data, 2);

% get dotted and solid line from input data
dotBlkIndex  = cell(1, datasetNum);
dotLineIndex = cell(1, datasetNum);

solidBlkIndex  = cell(1, datasetNum);
solidLineIndex = cell(1, datasetNum);

dotLineParams   = cell(1, datasetNum);
solidLineParams = cell(1, datasetNum);

dotLineData        = cell(1, datasetNum);
solidLineData      = cell(1, datasetNum);
solidLinePaintData = cell(1, datasetNum);
solidLineMovedData = cell(1, datasetNum);

% iterate for every data set
for dn = 1:datasetNum
    % get dotted line block and line index information
    [dotBlkIndex{dn}, dotLineIndex{dn}] = dotLineBlockIndex(data{dn});
    
    % get dotted line parameters
    % (center x, center y, count, length, width, angle)
    dotLineParams{dn} = getDotLineParams(data{dn}, dotBlkIndex{dn}, dotLineIndex{dn});
    
    % solid line data and index
    [solidLineData{dn}, solidLineIndex{dn}] = solidLineBlockIndex(data{dn});
    
    % solid line painted data
    solidLinePaintData{dn} = solidLineData{dn}(data{dn}(:, solidLineIndex{dn}) == 1, :);
end

figure(2)

% merge dotted and solid line

moveVector = cell(1, datasetNum - 1);
mergedDotLineParams = cell(1, datasetNum);
mergedDotLineParams{datasetNum} = dotLineParams{datasetNum};

solidMoveVector = cell(1, datasetNum - 1);
mergedSolidLineParams = cell(1, datasetNum);

for dn = datasetNum-1:-1:2 % dataset 1 is bad data
    % dotted line
    dotLineOne = mergedDotLineParams{dn+1};
    dotLineTwo = dotLineParams{dn};
    
    % merge dotted line
    [mergedDotLineParams{dn}, moveVector{dn}] = mergeDotLineParams(dotLineOne, dotLineTwo);
    
    % plot current result - for debugging
    % plot two dataset line
    drawAllGPSData(data{dn+1}, 'k.');
    plotCount = plotCount + 2;
    drawAllGPSData(data{dn}, 'b.');
    plotCount = plotCount + 2;
    
    % plot two dotted line center and merged dotted line
    plot(dotLineOne(:, 2), dotLineOne(:, 1), 'r*', 'MarkerSize', 2); hold on
    plotCount = plotCount + 1;
    plot(dotLineTwo(:, 2), dotLineTwo(:, 1), 'r*', 'MarkerSize', 2); hold on
    plotCount = plotCount + 1;
    plotCount = plotCount + plotMergedLine(mergedDotLineParams{dn});
    
	% for debug step by step purpose
    if 2 ~= i % dataset 1 is bad data
        h = findobj;
        delete(h(4:plotCount));
    end

    % get solid line moved data
    tempDotLineParams{1} = dotLineParams{dn};
    tempDotLineParams{2} = dotLineParams{dn+1};
    
    tempSolidLinePaintData{1} = solidLinePaintData{dn};
    tempSolidLinePaintData{2} = solidLinePaintData{dn+1};
    
    tempSolidLineMovedData = getSolidLineMovedData(tempDotLineParams, ...
        mergedDotLineParams{dn}, moveVector{dn}, ...
        tempSolidLinePaintData);
    solidLineMovedData{dn} = tempSolidLineMovedData{1};
    solidLineMovedData{dn+1} = tempSolidLineMovedData{2};

    % solid line block index
    for d = dn:dn+1
        items = size(solidLineMovedData{d}, 1);
        solidBlkIndex{d} = zeros(1, 2); % start, stop
        blkIndex = 1;
        bChanged = false;
        preval = solidLineMovedData{d}(1, 3);
        for i = 1:items
            value = solidLineMovedData{d}(i, 3);
            if (preval == value)
                if (false == bChanged)
                    solidBlkIndex{d}(blkIndex, 1) = i;   % start
                end
                bChanged = true;
            else
                if (true == bChanged)
                    solidBlkIndex{d}(blkIndex, 2) = i-1; % stop
                    if 20 < (solidBlkIndex{d}(blkIndex, 2) - solidBlkIndex{d}(blkIndex, 1))
                        blkIndex = blkIndex + 1;
                    end
                    bChanged = false;
                    preval = solidLineMovedData{d}(i+1, 3);
                end
            end
        end
        
        if (0 == solidBlkIndex{d}(end, 2))
            solidBlkIndex{d}(end, 2) = size(solidLineMovedData{d}, 1);
        end
        
        solidLineParams{d} = getSolidLineParams(solidLineMovedData{d}, ...
                                                solidBlkIndex{d});
    end
    
    % merge two solid line
    [mergedSolidLineParams{dn}, solidMoveVector{dn}] = mergeDotLineParams(...
        solidLineParams{dn}, solidLineParams{dn+1});
    
    % plot the merged solid line
    plot(mergedSolidLineParams{dn}(:, 2), mergedSolidLineParams{dn}(:, 1), 'g*', 'MarkerSize', 3);
    hold on;
    
    dotLineMerged0 = zeros(size(mergedSolidLineParams{dn}, 1), 2);
    dotLineMerged0(:, 1) = mergedSolidLineParams{dn}(:, 1) + 0.5 * mergedSolidLineParams{dn}(:, 4) .* cos(mergedSolidLineParams{dn}(:, 6));
    dotLineMerged0(:, 2) = mergedSolidLineParams{dn}(:, 2) + 0.5 * mergedSolidLineParams{dn}(:, 4) .* sin(mergedSolidLineParams{dn}(:, 6));
    plot(dotLineMerged0(:, 2), dotLineMerged0(:, 1), 'go', 'MarkerSize', 2);
    hold on;
    
    dotLineMerged1 = zeros(size(mergedSolidLineParams{dn}, 1), 2);
    dotLineMerged1(:, 1) = mergedSolidLineParams{dn}(:, 1) - 0.5 * mergedSolidLineParams{dn}(:, 4) .* cos(mergedSolidLineParams{dn}(:, 6));
    dotLineMerged1(:, 2) = mergedSolidLineParams{dn}(:, 2) - 0.5 * mergedSolidLineParams{dn}(:, 4) .* sin(mergedSolidLineParams{dn}(:, 6));
    plot(dotLineMerged1(:, 2), dotLineMerged1(:, 1), 'go', 'MarkerSize', 2);
    hold on;
    
    for n = 1:size(dotLineMerged1, 1)
        plot([dotLineMerged0(n, 2), dotLineMerged1(n, 2)], [dotLineMerged0(n, 1), dotLineMerged1(n, 1)], 'g');
        hold on
    end
end


































































% for i = 1:datasetNum
%     [paintIndex, xyIndex] = getPaintIndex(data{i});
%     paint = sum(1 == data{i}(:, paintIndex));
%     dotLineIndex = paintIndex(min(paint) == paint);
%     solidLineIndex = paintIndex(max(paint) == paint);
%     dotLineData = data{i}(:, xyIndex(min(paint) == paint, :));
%     solidLineData = data{i}(:, xyIndex(max(paint) == paint, :));
%     
%     % match solid line block to dotted line center
%     solidLinePaintData = solidLineData(data{i}(:, solidLineIndex) == 1, :);
%     
%     dotLineCenterCnt  = size(dotLineParams{i}, 1);
%     solidLinePaintCnt = size(solidLinePaintData, 1);
%     
%     mergedDotLineCenterCnt = size(mergedLineParams{i}, 1);
%     
%     % distance matrix
%     distData = inf * ones(solidLinePaintCnt, dotLineCenterCnt);
%     
%     % matchedData  = ones(solidLinePaintCnt, 2);
%     solidMoveVector = zeros(solidLinePaintCnt, 3);
%     matchedIndex = ones(solidLinePaintCnt, 1);
%     tempDistData = ones(dotLineCenterCnt, 2);
%     for n = 1:solidLinePaintCnt
%         tempDistData(:, :) = 1;
%         tempDistData(:, 1) = tempDistData(:, 1) * solidLinePaintData(n, 1);
%         tempDistData(:, 2) = tempDistData(:, 2) * solidLinePaintData(n, 2);
%         distData = tempDistData(:, 1:2) - dotLineParams{i}(:, 1:2);
%         distData = distData .* distData;
%         dist = distData(:, 1) + distData(:, 2);
%         [~, minDistIndex] = min(dist);
%         matchedIndex(n) = minDistIndex;
%         solidMoveVector(n, 3) = minDistIndex;
%         if minDistIndex <= mergedDotLineCenterCnt
%             if 1 == mod(i, 2)
%                 solidMoveVector(n, 1:2) = moveVector{floor((i+1)/2)}(minDistIndex, 1:2);
%             else
%                 solidMoveVector(n, 1:2) = moveVector{floor((i+1)/2)}(minDistIndex, 3:4);
%             end
%         end
%         %     matchedData(i, :) = dotLineParams{1}(minDistIndex, 1:2);
%         %     plot([solidLinePaintData(i, 2), matchedData(i, 2)], ...
%         %          [solidLinePaintData(i, 1), matchedData(i, 1)], 'k');
%         %     hold on
%     end
%     
%     % move each painted point according to matched index
%     
%     solidLineMovedData{i} = solidLinePaintData - solidMoveVector(:, 1:2);
%     solidLineMovedData{i}(:, 3) = solidMoveVector(:, 3);
%     plot(solidLineMovedData{i}(:, 1), solidLineMovedData{i}(:, 2), ...
%          colorSolid{i}, 'MarkerSize', 2);
%     hold on
% end
% 
% 
% % merged solid line according to closest dotted line center
% % solid line start/stop
% 
% % dotted line start/stop index, where the dotted line starts and ends
% solidBlkIndex = cell(1, datasetNum);
% solidLineParams = cell(1, datasetNum);
% for d = 1:datasetNum
%     items = size(solidLineMovedData{d}, 1);
%     solidBlkIndex{d} = zeros(1, 2); % start, stop
%     blkIndex = 1;
%     bChanged = false;
%     preval = solidLineMovedData{d}(1, 3);
%     for i = 1:items
%         value = solidLineMovedData{d}(i, 3);
%         if (preval == value)
%             if (false == bChanged)
%                 solidBlkIndex{d}(blkIndex, 1) = i;   % start
%             end
%             bChanged = true;
%         else
%             if (true == bChanged)
%                 solidBlkIndex{d}(blkIndex, 2) = i-1; % stop
%                 if 20 < (solidBlkIndex{d}(blkIndex, 2) - solidBlkIndex{d}(blkIndex, 1))
%                     blkIndex = blkIndex + 1;
%                 end
%                 bChanged = false;
%                 preval = solidLineMovedData{d}(i+1, 3);
%             end
%         end
%     end
%     
%     if (0 == solidBlkIndex{d}(end, 2))
%         solidBlkIndex{d}(end, 2) = size(solidLineMovedData{d}, 1);
%     end
%     
%     solidLineParams{d} = getSolidLineParams(solidLineMovedData{d}, ...
%                                             solidBlkIndex{d});
% end
% 
% 
% [LineParams0, moveVector0] = mergeDotLineParams(solidLineParams{1}, ...
%                                                 solidLineParams{2});
% 
% %
% plot(LineParams0(:, 2), LineParams0(:, 1), 'g*', 'MarkerSize', 3);
% hold on;
% 
% dotLineMerged0 = zeros(size(LineParams0, 1), 2);
% dotLineMerged0(:, 1) = LineParams0(:, 1) + 0.5 * LineParams0(:, 4) .* cos(LineParams0(:, 6));
% dotLineMerged0(:, 2) = LineParams0(:, 2) + 0.5 * LineParams0(:, 4) .* sin(LineParams0(:, 6));
% plot(dotLineMerged0(:, 2), dotLineMerged0(:, 1), 'go', 'MarkerSize', 2);
% hold on;
% 
% dotLineMerged1 = zeros(size(LineParams0, 1), 2);
% dotLineMerged1(:, 1) = LineParams0(:, 1) - 0.5 * LineParams0(:, 4) .* cos(LineParams0(:, 6));
% dotLineMerged1(:, 2) = LineParams0(:, 2) - 0.5 * LineParams0(:, 4) .* sin(LineParams0(:, 6));
% plot(dotLineMerged1(:, 1), dotLineMerged1(:, 2), 'go', 'MarkerSize', 2);
% hold on;
% 
% for n = 1:size(dotLineMerged1, 1)
%     plot([dotLineMerged0(n, 2), dotLineMerged1(n, 2)], [dotLineMerged0(n, 1), dotLineMerged1(n, 1)], 'g');
%     hold on
% end