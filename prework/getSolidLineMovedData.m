function [solidLineMovedData] = getSolidLineMovedData(dotLineParams, mergedDotLineParams, moveVector, solidLinePaintData)
% GETSOLIDLINEMOVEDDATA
%   get solid line moved data from dotted line moveing vector
%
%   INPUT:
%
%   dotLineParams - two dotted line parameters
%   mergedDotLineParams - merged dotted line parameters
%   moveVector - merged dotted line moving vector
%   solidLinePaintData - solid line painted data
%
%   OUTPUT:
%
%   solidLineMovedData - solid line data after moving according to dotted
%                        line moving vector
%
%
%

if size(dotLineParams, 2) ~= size(solidLinePaintData, 2)
    error('Invalid parameters for getSolidLineMovedData()');
end

% color
colorSolid{1} = 'r.';
colorSolid{2} = 'c.';

datasetNum = size(dotLineParams, 2);

solidLineMovedData = cell(1, datasetNum);

for dn = 1:datasetNum
    dotLineCenterCnt  = size(dotLineParams{dn}, 1);
    mergedDotLineCenterCnt = size(mergedDotLineParams, 1);
    
    solidLinePaintCnt = size(solidLinePaintData{dn}, 1);

    % matchedData  = ones(solidLinePaintCnt, 2);
    solidMoveVector = zeros(solidLinePaintCnt, 3);
    matchedIndex = ones(solidLinePaintCnt, 1);
    tempDistData = ones(dotLineCenterCnt, 2);
    for n = 1:solidLinePaintCnt
        tempDistData(:, :) = 1;
        tempDistData(:, 1) = tempDistData(:, 1) * solidLinePaintData{dn}(n, 1);
        tempDistData(:, 2) = tempDistData(:, 2) * solidLinePaintData{dn}(n, 2);
        distData = tempDistData(:, 1:2) - dotLineParams{dn}(:, 1:2);
        distData = distData .* distData;
        dist = distData(:, 1) + distData(:, 2);
        [~, minDistIndex] = min(dist);
        matchedIndex(n) = minDistIndex;
        solidMoveVector(n, 3) = minDistIndex;
        if minDistIndex <= mergedDotLineCenterCnt
            if 1 == mod(dn, 2)
                solidMoveVector(n, 1:2) = moveVector(minDistIndex, 1:2);
            else
                solidMoveVector(n, 1:2) = moveVector(minDistIndex, 3:4);
            end
        end
    end
    
    % move each painted point according to matched index
    
    solidLineMovedData{dn} = solidLinePaintData{dn}(:, 1:2) - ...
                             solidMoveVector(:, 1:2);
    solidLineMovedData{dn}(:, 3) = solidMoveVector(:, 3);
    plot(solidLineMovedData{dn}(:, 2), solidLineMovedData{dn}(:, 1), ...
         colorSolid{dn}, 'MarkerSize', 2);
    hold on
end