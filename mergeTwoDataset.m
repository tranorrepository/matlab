function [mergedSampleData] = mergeTwoDataset(dbData, newData)
% MERGETWODATASET
%   solid line and dotted line merge mechanism
%
%   INPUT:
%
%   dbData - database data
%   newData - new data used to merge with database data
%
%   OUTPUT:
%
%
%

% dbData = data{1};
% newData = data{2};

% input data validate
% if size(dbData, 2) ~= size(newData, 2)
%     error('Invalid input parameters!');
% end

% data set cell
data = cell(1, 2);
data{1} = dbData;
data{2} = newData;

datasetNum = 2;

% get dotted and solid line from input data
dotBlkIndex  = cell(1, datasetNum);
dotLineIndex = cell(1, datasetNum);
solidLineIndex  = cell(1, datasetNum);
dotLineParams   = cell(1, datasetNum);
solidLineData      = cell(1, datasetNum);
solidLineValidData = cell(1, datasetNum);
solidLinePaintData = cell(1, datasetNum);

% figure control
figure(4)
axis equal

plotCount = 3;
colorSet = cell(3, 1);
colorSet{1} = 'k.';
colorSet{2} = 'b.';
colorSet{3} = 'k.';

% iterate for every data set
for dn = 1:datasetNum
    % plot the data
    drawAllGPSData(data{dn}, colorSet{mod(dn, 3)});
    plotCount = plotCount + 2;
    
    % get dotted line block and line index information
    [dotBlkIndex{dn}, dotLineIndex{dn}] = dotLineBlockIndex(data{dn});
    
    % get dotted line parameters
    % (center x, center y, count, length, width, angle)
    dotLineParams{dn} = getDotLineParams(data{dn}, dotBlkIndex{dn}, dotLineIndex{dn});
    
    % solid line data and index
    % (solid x, solid y, paintflag)
    [solidLineData{dn}, solidLineIndex{dn}] = solidLineBlockIndex(data{dn});
    
    % solid line painted data
    % (solid x, solid y, paintflag)
    solidLinePaintData{dn} = solidLineData{dn}(data{dn}(:, solidLineIndex{dn}) == 1, :);
    
    % solid line valid data
    % (solid x, solid y, paintflag)
    solidLineValidData{dn} = solidLineData{dn}(data{dn}(:, solidLineIndex{dn} - 2) ~= 0, :);
    
    plot(solidLineValidData{dn}(solidLineValidData{dn}(:, 3) == 0, 2), ...
         solidLineValidData{dn}(solidLineValidData{dn}(:, 3) == 0, 1), ...
         'c.', 'MarkerSize', 1);
end

% merge dotted and solid line

dotLineMoveVector = cell(datasetNum - 1, 1);
mergedDotLineParams = cell(datasetNum, 1);
mergedDotLineParams{datasetNum} = dotLineParams{datasetNum};

solidMoveVector = cell(datasetNum, 1);
mergedSolidLinePaintData = cell(datasetNum, 1);
mergedSolidLinePaintData{datasetNum} = solidLinePaintData{datasetNum};

mergedSolidLineValidData = cell(datasetNum, 1);
mergedSolidLineValidData{datasetNum} = solidLineValidData{datasetNum};

for dn = datasetNum-1:-1:1
    % dotted line
    dotLineOne = mergedDotLineParams{dn+1};
    dotLineTwo = dotLineParams{dn};
    
    % merge dotted line
    [mergedDotLineParams{dn}, dotLineMoveVector{dn}] = mergeDotLineParams(dotLineOne, dotLineTwo);
    
%     plotCount = plotCount + plotMergedLine(mergedDotLineParams{dn});
    
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
        % (solid x, solid y, paintflag)
        if (dotLineIndex{dn} == dotLineIndex{dn+1})
            solidLineOne = mergedSolidLineValidData{dn+1};
            solidLineTwo = solidLineValidData{dn};
            
            mergedSolidLineValidData{dn} = mergeSolidLinePaintData(solidLineOne, solidLineTwo);
            
%             plot(mergedSolidLineValidData{dn}(mergedSolidLineValidData{dn}(:, 3) > 0.5, 2), ...
%                  mergedSolidLineValidData{dn}(mergedSolidLineValidData{dn}(:, 3) > 0.5, 1), 'g.', 'MarkerSize', 4); hold on
%             plot(mergedSolidLineValidData{dn}(mergedSolidLineValidData{dn}(:, 3) <= 0.5, 2), ...
%                  mergedSolidLineValidData{dn}(mergedSolidLineValidData{dn}(:, 3) <= 0.5, 1), 'g.', 'MarkerSize', 1); hold on
%              
%             plotCount = plotCount + 1;
        else
            mergedSolidLineValidData{dn} = solidLineValidData{dn};
            plot(mergedSolidLineValidData{dn+1}(:, 2), mergedSolidLineValidData{dn+1}(:, 1), 'g.', 'MarkerSize', 2); hold on
            plotCount = plotCount + 1;
            plot(mergedSolidLineValidData{dn}(:, 2), mergedSolidLineValidData{dn}(:, 1), 'g.', 'MarkerSize', 2); hold on
            plotCount = plotCount + 1;
        end
    end
end

% resample for solid and dotted line
% solid line points count
solidLinePointsCnt = size(mergedSolidLineValidData{1}, 1);
dotLineSampleData = linSample(mergedDotLineParams{1}, solidLinePointsCnt);

mergedSampleData = zeros(solidLinePointsCnt, 6);

if (dotLineIndex{1} == dotLineIndex{2})
    mergedSampleData(:, 1:2) = dotLineSampleData(:, 1:2);
    mergedSampleData(:, 5  ) = dotLineSampleData(:, 3  );
    mergedSampleData(:, 3:4) = mergedSolidLineValidData{1}(:, 1:2);
    mergedSampleData(:, 6  ) = mergedSolidLineValidData{1}(:, 3  );
else
    mergedSampleData(:, 1:2) = mergedSolidLineValidData{1}(:, 1:2);
    mergedSampleData(:, 5  ) = mergedSolidLineValidData{1}(:, 3  );
    mergedSampleData(:, 3:4) = dotLineSampleData(:, 1:2);
    mergedSampleData(:, 6  ) = dotLineSampleData(:, 3  );
end