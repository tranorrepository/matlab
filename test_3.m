% TEST_3
% solid line move and merge for honda data

clear all; clc;
format long

% % ford data
% all *.mat is organized as a cell, named data
load('test_3.mat');

% plot count used to delete object
plotCount = 0;
num = 0;

% number of data set in data
datasetNum = size(data, 2);

% get dotted and solid line from input data
dotBlkIndex  = cell(1, datasetNum);
dotLineIndex = cell(1, datasetNum);

% solidBlkIndex  = cell(1, datasetNum);
solidLineIndex = cell(1, datasetNum);

dotLineParams   = cell(1, datasetNum);
% solidLineParams = cell(1, datasetNum);

% dotLineData        = cell(1, datasetNum);
solidLineData      = cell(1, datasetNum);
solidLineValidData = cell(1, datasetNum);
solidLinePaintData = cell(1, datasetNum);
% solidLineMovedData = cell(1, datasetNum);

% figure control
figure(3)

% iterate for every data set
for dn = 1:datasetNum
    % plot the data
    drawAllGPSData(data{dn}, 'k.');
    plotCount = plotCount + 2;
    
    % get dotted line block and line index information
    [dotBlkIndex{dn}, dotLineIndex{dn}] = dotLineBlockIndex(data{dn});
    
    % get dotted line parameters
    % (center x, center y, count, length, width, angle)
    dotLineParams{dn} = getDotLineParams(data{dn}, dotBlkIndex{dn}, dotLineIndex{dn});
    
    % solid line data and index
    [solidLineData{dn}, solidLineIndex{dn}] = solidLineBlockIndex(data{dn});
    
    % solid line painted data
    solidLinePaintData{dn} = solidLineData{dn}(data{dn}(:, solidLineIndex{dn}) == 1, :);
    
    % solid line valid data
    solidLineValidData{dn} = solidLineData{dn}(data{dn}(:, solidLineIndex{dn} - 2) ~= 0, :);
    
    plot(solidLineValidData{dn}(solidLineValidData{dn}(:, 3) == 0, 2), ...
         solidLineValidData{dn}(solidLineValidData{dn}(:, 3) == 0, 1), ...
         'b.', 'MarkerSize', 1);
end

% merge dotted and solid line

dotLineMoveVector = cell(1, datasetNum - 1);
mergedDotLineParams = cell(1, datasetNum);
mergedDotLineParams{datasetNum} = dotLineParams{datasetNum};

solidMoveVector = cell(1, datasetNum);
mergedSolidLinePaintData = cell(1, datasetNum);
mergedSolidLinePaintData{datasetNum} = solidLinePaintData{datasetNum};

mergedSolidLineValidData = cell(1, datasetNum);
mergedSolidLineValidData{datasetNum} = solidLineValidData{datasetNum};

for dn = datasetNum-1:-1:1
    % dotted line
    dotLineOne = mergedDotLineParams{dn+1};
    dotLineTwo = dotLineParams{dn};
    
    % plot the data
%     drawAllGPSData(data{dn}, 'b.');
%     plotCount = plotCount + 2;
    
    % merge dotted line
    [mergedDotLineParams{dn}, dotLineMoveVector{dn}] = mergeDotLineParams(dotLineOne, dotLineTwo);
    
    % plot two dotted line center and merged dotted line
%     plot(dotLineOne(:, 2), dotLineOne(:, 1), 'r*', 'MarkerSize', 2); hold on
%     plotCount = plotCount + 1;
%     plot(dotLineTwo(:, 2), dotLineTwo(:, 1), 'r*', 'MarkerSize', 2); hold on
%     plotCount = plotCount + 1;

    %
    % delete unused plot object
    if 0 < num
        h = findobj;
        delete(h(4:num+7));    
        plotCount = plotCount - (num+4);
    end
    
    plotCount = plotCount + plotMergedLine(mergedDotLineParams{dn});
    
    
    % get solid line moved vector
    solidMoveVector{dn}(1, 1) = sum(dotLineMoveVector{dn}(:, 1)) / size(dotLineMoveVector{dn}, 1);
    solidMoveVector{dn}(1, 2) = sum(dotLineMoveVector{dn}(:, 2)) / size(dotLineMoveVector{dn}, 1);
    solidMoveVector{dn+1}(1, 1) = sum(dotLineMoveVector{dn}(:, 3)) / size(dotLineMoveVector{dn}, 1);
    solidMoveVector{dn+1}(1, 2) = sum(dotLineMoveVector{dn}(:, 4)) / size(dotLineMoveVector{dn}, 1);
    
    
    if 0
        % move solid line painted data
        mergedSolidLinePaintData{dn+1}(:, 1) = mergedSolidLinePaintData{dn+1}(:, 1) - solidMoveVector{dn+1}(1, 1);
        mergedSolidLinePaintData{dn+1}(:, 2) = mergedSolidLinePaintData{dn+1}(:, 2) - solidMoveVector{dn+1}(1, 2);
        solidLinePaintData{dn}(:, 1) = solidLinePaintData{dn}(:, 1) - solidMoveVector{dn}(1, 1);
        solidLinePaintData{dn}(:, 2) = solidLinePaintData{dn}(:, 2) - solidMoveVector{dn}(1, 2);
        
        % merge two solid lines painted data
        if (dotLineIndex{dn} == dotLineIndex{dn+1})
            solidLineOne = mergedSolidLinePaintData{dn+1};
            solidLineTwo = solidLinePaintData{dn};
            mergedSolidLinePaintData{dn} = mergeSolidLinePaintData(solidLineOne, solidLineTwo);
            
            plot(mergedSolidLinePaintData{dn}(:, 2), mergedSolidLinePaintData{dn}(:, 1), 'r.', 'MarkerSize', 2); hold on
            plotCount = plotCount + 1;
        else
            mergedSolidLinePaintData{dn} = solidLinePaintData{dn};
            plot(mergedSolidLinePaintData{dn+1}(:, 2), mergedSolidLinePaintData{dn+1}(:, 1), 'g.', 'MarkerSize', 2); hold on
            plotCount = plotCount + 1;
            plot(mergedSolidLinePaintData{dn}(:, 2), mergedSolidLinePaintData{dn}(:, 1), 'g.', 'MarkerSize', 2); hold on
            plotCount = plotCount + 1;
        end
    else
        % move solid line valid data
        mergedSolidLineValidData{dn+1}(:, 1) = mergedSolidLineValidData{dn+1}(:, 1) - solidMoveVector{dn+1}(1, 1);
        mergedSolidLineValidData{dn+1}(:, 2) = mergedSolidLineValidData{dn+1}(:, 2) - solidMoveVector{dn+1}(1, 2);
        solidLineValidData{dn}(:, 1) = solidLineValidData{dn}(:, 1) - solidMoveVector{dn}(1, 1);
        solidLineValidData{dn}(:, 2) = solidLineValidData{dn}(:, 2) - solidMoveVector{dn}(1, 2);
        
        % merged two solid lines valid data
        if (dotLineIndex{dn} == dotLineIndex{dn+1})
            solidLineOne = mergedSolidLineValidData{dn+1};
            solidLineTwo = solidLineValidData{dn};
            mergedSolidLineValidData{dn} = mergeSolidLinePaintData(solidLineOne, solidLineTwo);
            
            plot(mergedSolidLineValidData{dn}(:, 2), mergedSolidLineValidData{dn}(:, 1), 'g.', 'MarkerSize', 2); hold on
            plotCount = plotCount + 1;
        else
            mergedSolidLineValidData{dn} = solidLineValidData{dn};
            plot(mergedSolidLineValidData{dn+1}(:, 2), mergedSolidLineValidData{dn+1}(:, 1), 'g.', 'MarkerSize', 2); hold on
            plotCount = plotCount + 1;
            plot(mergedSolidLineValidData{dn}(:, 2), mergedSolidLineValidData{dn}(:, 1), 'g.', 'MarkerSize', 2); hold on
            plotCount = plotCount + 1;
        end
    end
    
    num = size(mergedDotLineParams{dn}, 1);
end

% resample for solid and dotted line
% sampleCnt = 100;
% dotLineSampleData = linSample(mergedDotLineParams{1}, sampleCnt);