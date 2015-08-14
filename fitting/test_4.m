load('0.mat');
newdata = matchReportData;

numOfNew = size(newdata, 1);

for ns = 1:numOfNew
    line1 = newdata{ns, 2}{1, 1};
    line2 = newdata{ns, 2}{1, 2};
    
    plot(line1(line1(:, 3) == 1, 1), line1(line1(:, 3) == 1, 2), ...
        'k.', 'MarkerSize', 3); hold on;
    plot(line2(line2(:, 3) == 1, 1), line2(line2(:, 3) == 1, 2), ...
        'b.', 'MarkerSize', 3); hold on;
    axis equal
end