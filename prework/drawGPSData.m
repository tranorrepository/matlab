function drawGPSData(GPS_DATA, color)
[~, cols] = size(GPS_DATA);

if (6 ~= cols && 19 ~= cols)
    error('invalid data set!');
end

lrIndex  = [3; 14];
xyIndex = [lrIndex - 2, lrIndex - 1];
if 6 == cols
    lrIndex  = [5; 6];
    xyIndex = [lrIndex - 4, lrIndex - 2]';
end

lrPaint = GPS_DATA(:, lrIndex);

lxyData = GPS_DATA(:, xyIndex(1, :));
rxyData = GPS_DATA(:, xyIndex(2, :));

paint = sum(lrPaint);
if paint(1) < paint(2)
    plot(lxyData(lrPaint(:, 1) == 1, 2), lxyData(lrPaint(:, 1) == 1, 1), ...
         color, 'MarkerSize', 1);
    hold on
else
    plot(rxyData(lrPaint(:, 2) == 1, 2), rxyData(lrPaint(:, 2) == 1, 1), ...
         color, 'MarkerSize', 1);
    hold on
end