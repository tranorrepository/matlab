% dotted line fitting and resample of honda data

clear all; clc;
format long

% % ford data
% all *.mat is organized as a cell, named data
load('honda.mat');

% number of data set in data
datasetNum = size(data, 2);

% plot all data
figure(1)
for i = 1:datasetNum
    drawGPSData(data{i}, 'k.');
    hold on
end

% get dotted line from input data
dotBlkIndex   = cell(1, datasetNum);
dotLineIndex  = cell(1, datasetNum);
dotLineParams = cell(1, datasetNum);
for i = 1:datasetNum
    [dotBlkIndex{i}, dotLineIndex{i}] = dotLineBlockIndex(data{i});
    dotLineParams{i} = getDotLineParams(data{i}, dotBlkIndex{i}, dotLineIndex{i});
end

mergedLineParams = cell(1, datasetNum);
moveVector = cell(1, datasetNum - 1);
mergedLineParams{datasetNum} = dotLineParams{datasetNum};
for i = datasetNum-1:-1:1
    lineOne = mergedLineParams{i+1};
    lineTwo = dotLineParams{i};
    
    % merge process
    [mergedLineParams{i}, moveVector{i}] = mergeDotLineParams(lineOne, lineTwo);
    
    % plot result
    plot(lineOne(:, 2), lineOne(:, 1), 'r*', 'MarkerSize', 3);hold on;
    plot(lineTwo(:, 2), lineTwo(:, 1), 'r*', 'MarkerSize', 3);hold on;
    plot(mergedLineParams{i}(:, 2), mergedLineParams{i}(:, 1), 'g*', 'MarkerSize', 3);
    hold on;
    
    dotLineMerged0 = zeros(size(mergedLineParams{i}, 1), 2);
    dotLineMerged0(:, 1) = mergedLineParams{i}(:, 1) + 0.5 * mergedLineParams{i}(:, 4) .* cos(mergedLineParams{i}(:, 6));
    dotLineMerged0(:, 2) = mergedLineParams{i}(:, 2) + 0.5 * mergedLineParams{i}(:, 4) .* sin(mergedLineParams{i}(:, 6));
    plot(dotLineMerged0(:, 2), dotLineMerged0(:, 1), 'go', 'MarkerSize', 2);
    hold on;
    
    dotLineMerged1 = zeros(size(mergedLineParams{i}, 1), 2);
    dotLineMerged1(:, 1) = mergedLineParams{i}(:, 1) - 0.5 * mergedLineParams{i}(:, 4) .* cos(mergedLineParams{i}(:, 6));
    dotLineMerged1(:, 2) = mergedLineParams{i}(:, 2) - 0.5 * mergedLineParams{i}(:, 4) .* sin(mergedLineParams{i}(:, 6));
    plot(dotLineMerged1(:, 2), dotLineMerged1(:, 1), 'go', 'MarkerSize', 2);
    hold on;
    
    for n = 1:size(dotLineMerged1, 1)
        plot([dotLineMerged0(n, 2), dotLineMerged1(n, 2)], [dotLineMerged0(n, 1), dotLineMerged1(n, 1)], 'g');
        hold on
    end
    
    % for debug step by step purpose
    if 1 ~= i
        h = findobj;
        delete(h(4:(8+size(dotLineMerged1, 1))));
    end
end

