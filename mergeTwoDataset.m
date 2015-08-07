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

SINGLE_LANE = 1;
MULTI_LANE  = 2;

% get dotted and solid line from input data
dotBlkIndex  = cell(1, datasetNum);
dotLineIndex = cell(1, datasetNum);
solidLineIndex  = cell(1, datasetNum);
dotLineParams   = cell(1, datasetNum);
solidLineData      = cell(1, datasetNum);
solidLineValidData = cell(1, datasetNum);
solidLinePaintData = cell(1, datasetNum);
solidLineMovedData = cell(1, datasetNum);

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
    
%     plot(solidLineValidData{dn}(solidLineValidData{dn}(:, 3) == 0, 2), ...
%          solidLineValidData{dn}(solidLineValidData{dn}(:, 3) == 0, 1), ...
%          'c.', 'MarkerSize', 1);
end

% merge dotted and solid line

dotLineMoveVector = cell(datasetNum - 1, 1);
mergedDotLineParams = cell(datasetNum - 1, 1);

solidMoveVector = cell(datasetNum, 1);
mergedSolidLineValidData = cell(datasetNum, 1);

% database merged times
dbmergedCnt = 1;

% merge dotted line
[mergedDotLineParams{1}, dotLineMoveVector{1}] = mergeDotLineParams(dotLineParams{1}, dbmergedCnt, dotLineParams{2}, 1);

% plotCount = plotCount + plotMergedLine(mergedDotLineParams{dn});

% get solid line moved vector
solidMoveVector{1}(1, 1) = sum(dotLineMoveVector{1}(:, 1)) / size(dotLineMoveVector{1}, 1);
solidMoveVector{1}(1, 2) = sum(dotLineMoveVector{1}(:, 2)) / size(dotLineMoveVector{1}, 1);
solidMoveVector{2}(1, 1) = sum(dotLineMoveVector{1}(:, 3)) / size(dotLineMoveVector{1}, 1);
solidMoveVector{2}(1, 2) = sum(dotLineMoveVector{1}(:, 4)) / size(dotLineMoveVector{1}, 1);

% move solid line valid data
solidLineMovedData{1}(:, 1) = solidLineValidData{1}(:, 1) + solidMoveVector{1}(1, 1);
solidLineMovedData{1}(:, 2) = solidLineValidData{1}(:, 2) + solidMoveVector{1}(1, 2);
solidLineMovedData{1}(:, 3) = solidLineValidData{1}(:, 3);
solidLineMovedData{2}(:, 1) = solidLineValidData{2}(:, 1) + solidMoveVector{2}(1, 1);
solidLineMovedData{2}(:, 2) = solidLineValidData{2}(:, 2) + solidMoveVector{2}(1, 2);
solidLineMovedData{2}(:, 3) = solidLineValidData{2}(:, 3);

% merged two solid lines valid data
% (solid x, solid y, paintflag)
if (dotLineIndex{1} == dotLineIndex{2})
    mergedSolidLineValidData{1} = mergeSolidLinePaintData(solidLineMovedData{1}, dbmergedCnt, solidLineMovedData{2}, 1);
    type = SINGLE_LANE;
    
%     
%     plot(mergedSolidLineValidData{1}(mergedSolidLineValidData{1}(:, 3) > 0.5, 2), ...
%         mergedSolidLineValidData{1}(mergedSolidLineValidData{1}(:, 3) > 0.5, 1), 'g.', 'MarkerSize', 4); hold on
%     plot(mergedSolidLineValidData{1}(mergedSolidLineValidData{1}(:, 3) <= 0.5, 2), ...
%         mergedSolidLineValidData{1}(mergedSolidLineValidData{1}(:, 3) <= 0.5, 1), 'g.', 'MarkerSize', 1); hold on

else
    mergedSolidLineValidData = solidLineMovedData;
    type = MULTI_LANE;

%     plot(mergedSolidLineValidData{1}(:, 2), mergedSolidLineValidData{1}(:, 1), 'g.', 'MarkerSize', 2); hold on
%     plot(mergedSolidLineValidData{2}(:, 2), mergedSolidLineValidData{2}(:, 1), 'g.', 'MarkerSize', 2); hold on

end


% resample for solid and dotted line
mergedSampleData = resampleData(mergedDotLineParams, mergedSolidLineValidData, type);
% cols = size(mergedSampleData, 2);
% mergedSampleData(:, cols+1) = data{1}(:, 7);
% mergedSampleData(:, cols+2) = dbmergedCnt + 1;


%%
function mergedSampleData = resampleData(dotLineParams, solidLineParams, type)
%
%  dotLineParams - (x, y, count, lenght, width, theta)
%
%  solidLineParams - (x, y, paint flag)

SINGLE_LANE = 1;
MULTI_LANE  = 2;

% first items is from database
if (1 ~= size(dotLineParams, 1)) || (2 ~= size(solidLineParams, 1))
    error('Invalid input data for resampleData!');
end

if type == SINGLE_LANE
    solidLinePointsCnt = size(solidLineParams{1}, 1);
    
    % resample dotted line data
    dotLineSampleData = linSample(dotLineParams{1}, solidLinePointsCnt);
    
    mergedSampleData = zeros(solidLinePointsCnt, 6);
    
    mergedSampleData(:, 1:2) = dotLineSampleData(:, 1:2);
    mergedSampleData(:, 5  ) = dotLineSampleData(:, 3  );
    mergedSampleData(:, 3:4) = solidLineParams{1}(:, 1:2);
    mergedSampleData(:, 6  ) = solidLineParams{1}(:, 3  );
    
    return;
end

if type == MULTI_LANE
    solidLinePointsCnt1 = size(solidLineParams{1}, 1);
    solidLinePointsCnt2 = size(solidLineParams{2}, 1);
    
    solidLinePointsCnt = max(solidLinePointsCnt1, solidLinePointsCnt2);
    
    % resample dotted line data
    dotLineSampleData = linSample(dotLineParams{1}, solidLinePointsCnt);
    
    mergedSampleData = zeros(solidLinePointsCnt, 9);
    
    % solid line 1
    mergedSampleData(1:solidLinePointsCnt1, 1:2) = solidLineParams{1}(:, 1:2);
    mergedSampleData(1:solidLinePointsCnt1, 7  ) = solidLineParams{1}(:, 3  );
    mergedSampleData(solidLinePointsCnt1+1:end, 7) = -1;
    
    mergedSampleData(:, 3:4) = dotLineSampleData(:, 1:2);
    mergedSampleData(:, 8  ) = dotLineSampleData(:, 3  );
    
    % solid line 2
    mergedSampleData(1:solidLinePointsCnt2, 5:6) = solidLineParams{2}(:, 1:2);
    mergedSampleData(1:solidLinePointsCnt2, 9  ) = solidLineParams{2}(:, 3  );
    mergedSampleData(solidLinePointsCnt2+1:end, 9) = -1;
    
    return;
end