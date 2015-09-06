function plotCount = plotMergedLine(mergedLineParams)
% PLOTMERGEEDLINE
%

plotCount = 0;

plot(mergedLineParams(:, 2), mergedLineParams(:, 1), 'g*', 'MarkerSize', 2);
hold on;
plotCount = plotCount + 1;

dotLineMerged0 = zeros(size(mergedLineParams, 1), 2);
dotLineMerged0(:, 1) = mergedLineParams(:, 1) + 0.5 * mergedLineParams(:, 4) .* cos(mergedLineParams(:, 6));
dotLineMerged0(:, 2) = mergedLineParams(:, 2) + 0.5 * mergedLineParams(:, 4) .* sin(mergedLineParams(:, 6));
plot(dotLineMerged0(:, 2), dotLineMerged0(:, 1), 'go', 'MarkerSize', 2);
hold on
plotCount = plotCount + 1;

dotLineMerged1 = zeros(size(mergedLineParams, 1), 2);
dotLineMerged1(:, 1) = mergedLineParams(:, 1) - 0.5 * mergedLineParams(:, 4) .* cos(mergedLineParams(:, 6));
dotLineMerged1(:, 2) = mergedLineParams(:, 2) - 0.5 * mergedLineParams(:, 4) .* sin(mergedLineParams(:, 6));
plot(dotLineMerged1(:, 2), dotLineMerged1(:, 1), 'ro', 'MarkerSize', 2);
hold on
plotCount = plotCount + 1;

for n = 1:size(dotLineMerged1, 1)
    plot([dotLineMerged0(n, 2), dotLineMerged1(n, 2)], [dotLineMerged0(n, 1), dotLineMerged1(n, 1)], 'r');
    hold on
    plotCount = plotCount + 1;
end