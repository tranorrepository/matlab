% roadDBDemo
%
% demo section merge process
%

clc
format long

% load data
load('roadDBDemo.mat');

if size(database, 1) ~= size(refdata, 1)
    error('Invalid data set!');
end

datasection = size(database, 1);

mergedData  = cell(datasection, 1);

% call roadDBDemo to iterate each data section
for ds = 1:datasection
    mergedData{ds, 1} = mergeTwoDataset(database{ds, 1}, refdata{ds, 1});
    drawAllGPSData(mergedData{ds, 1}, 'r.', 2);
    plot(mergedData{ds, 1}(mergedData{ds, 1}(:, 6) ~= 1, 4), mergedData{ds, 1}(mergedData{ds, 1}(:, 6) ~= 1, 3), 'r.', 'MarkerSize', 1); hold on;
end