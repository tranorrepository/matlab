function drawAllGPSData(GPS_DATA, color, mkrsz)
[~, cols] = size(GPS_DATA);

if (6 ~= cols && 19 ~= cols && 7 ~= cols && 20 ~= cols)
    error('invalid data set!');
end

lrIndex  = [3; 14];
xyIndex = [lrIndex - 2, lrIndex - 1];
if (6 == cols) || (7 == cols)
    lrIndex  = [5; 6];
    xyIndex = [lrIndex - 4, lrIndex - 2]';
end

lrPaint = GPS_DATA(:, lrIndex);

lxyData = GPS_DATA(:, xyIndex(1, :));
rxyData = GPS_DATA(:, xyIndex(2, :));

if 3 == nargin
    plot(lxyData(lrPaint(:, 1) == 1, 2), lxyData(lrPaint(:, 1) == 1, 1), ...
        color, 'MarkerSize', mkrsz); hold on;
    plot(rxyData(lrPaint(:, 2) == 1, 2), rxyData(lrPaint(:, 2) == 1, 1), ...
        color, 'MarkerSize', mkrsz); hold on;
else
    plot(lxyData(lrPaint(:, 1) == 1, 2), lxyData(lrPaint(:, 1) == 1, 1), ...
        '.', 'Color', [0.66, 0.66, 0.66], 'MarkerSize', 1); hold on;
    plot(rxyData(lrPaint(:, 2) == 1, 2), rxyData(lrPaint(:, 2) == 1, 1), ...
        '.', 'Color', [0.66, 0.66, 0.66], 'MarkerSize', 1); hold on;
end