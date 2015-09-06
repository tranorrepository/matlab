% clear all; clc;
format long

% % load GPS data
% % ford data
% data0 = load('data_2\dataStruct_0.txt');
% data1 = load('data_2\dataStruct_1.txt');
% data2 = load('data_2\dataStruct_2.txt');
% data3 = load('data_2\dataStruct_3.txt');

% % honda data
% data1 = load('data_3\GPS_1.txt');
% data3 = load('data_3\GPS_3.txt');
% data4 = load('data_3\GPS_4.txt');
% data5 = load('data_3\GPS_5.txt');
% data6 = load('data_3\GPS_6.txt');
% data7 = load('data_3\GPS_7.txt');
% data8 = load('data_3\GPS_8.txt');
% data9 = load('data_3\GPS_9.txt');
% data10 = load('data_3\GPS_10.txt');

% % ford data
% input0 = data0;
% input1 = data3;

% % honda data
input0 = data1;
input1 = data3;


figure
drawGPSData(input0, 'k.');
hold on
drawGPSData(input1, 'k.');
hold on
% drawGPSData(data4, 'k.');
% hold on
% drawGPSData(data5, 'k.');
% hold on
% drawGPSData(data6, 'k.');
% hold on
% drawGPSData(data7, 'k.');
% hold on
% drawGPSData(data8, 'k.');
% hold on
% drawGPSData(data9, 'k.');
% hold on
% drawGPSData(data10, 'k.');
% hold on

% dotLineParams13 = mergeData(data1, data3);
% dotLineParams45 = mergeData(data4, data5);
% dotLineParams67 = mergeData(data6, data7);
% dotLineParams89 = mergeData(data8, data9);

% get dotted line from input data
[dotBlkIndex0, dotLineIndex0] = dotLineBlockIndex(input0);
[dotBlkIndex1, dotLineIndex1] = dotLineBlockIndex(input1);

% get dotted line parameters
% format is (center x, center y, points count, length, theta)
dotLineParams0 = getDotLineParams(input0, dotBlkIndex0, dotLineIndex0);
dotLineParams1 = getDotLineParams(input1, dotBlkIndex1, dotLineIndex1);

% iterative closest point
dotLineParams = mergeDotLineParams(dotLineParams0, dotLineParams1);

% solid line data
% solidLineIndex0 = 17 - dotLineIndex0;
% solidLineIndex1 = 17 - dotLineIndex1;
% solidLine0 = data0(:, (solidLineIndex0 - 2):(solidLineIndex0 - 1));
% solidLine1 = data1(:, (solidLineIndex1 - 2):(solidLineIndex1 - 1));

% test for now
dotLineC0 = dotLineParams0(:, 1:2);
plot(dotLineC0(:, 2), dotLineC0(:, 1), 'r*');
hold on

dotLineC1 = dotLineParams1(:, 1:2);
plot(dotLineC1(:, 2), dotLineC1(:, 1), 'r*');
hold on

dotLine = dotLineParams(:, 1:2);
plot(dotLine(:, 2), dotLine(:, 1), 'r*');
hold on

% plot merged dotted line
dotLineMerged0 = zeros(size(dotLine, 1), 2);
dotLineMerged0(:, 1) = dotLine(:, 1) + 0.5 * dotLineParams(:, 4) .* cos(dotLineParams(:, 6));
dotLineMerged0(:, 2) = dotLine(:, 2) + 0.5 * dotLineParams(:, 4) .* sin(dotLineParams(:, 6));

plot(dotLineMerged0(:, 2), dotLineMerged0(:, 1), 'go', 'MarkerSize', 2);
hold on;

dotLineMerged1 = zeros(size(dotLine, 1), 2);
dotLineMerged1(:, 1) = dotLine(:, 1) - 0.5 * dotLineParams(:, 4) .* cos(dotLineParams(:, 6));
dotLineMerged1(:, 2) = dotLine(:, 2) - 0.5 * dotLineParams(:, 4) .* sin(dotLineParams(:, 6));
plot(dotLineMerged1(:, 2), dotLineMerged1(:, 1), 'go', 'MarkerSize', 2);
hold on;

for i = 1:size(dotLineMerged1, 1)
    plot([dotLineMerged0(i, 2), dotLineMerged1(i, 2)], [dotLineMerged0(i, 1), dotLineMerged1(i, 1)], 'g');
    hold on
end
% end of plot