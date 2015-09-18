data0 = load('dataStruct_0.txt');
data1 = load('datastruct_1.txt');
data2 = load('datastruct_2.txt');
data3 = load('datastruct_3.txt');

figure(1)
plot(data0(data0(:, 3) >= 0, 2), data0(data0(:, 3) >= 0, 1), '.', ...
    data0(data0(:, 14) >= 0, 13), data0(data0(:, 14) >= 0, 12), 'o');
hold on; axis equal; grid on;
plot(data1(data1(:, 3) >= 0, 2), data1(data1(:, 3) >= 0, 1), '.', ...
    data1(data1(:, 14) >= 0, 13), data1(data1(:, 14) >= 0, 12), 'o');
plot(data2(data2(:, 3) >= 0, 2), data2(data2(:, 3) >= 0, 1), '.', ...
    data2(data2(:, 14) >= 0, 13), data2(data2(:, 14) >= 0, 12), 'o');
plot(data3(data3(:, 3) >= 0, 2), data3(data3(:, 3) >= 0, 1), '.', ...
    data3(data3(:, 14) >= 0, 13), data3(data3(:, 14) >= 0, 12), 'o');
hold off
