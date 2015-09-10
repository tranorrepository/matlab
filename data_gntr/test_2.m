
addpath('.\data_sec11_1');

clf(figure(100));

FILE_NUM = 9500;

for ii = 0:FILE_NUM
    formatSpec = 'fg_%d_sec_11_group_0_lane_0.txt';
    str = sprintf(formatSpec, ii);
    if exist(str, 'file')
        fileID = fopen(str, 'r');
        formatSpec = '%f, %f, %f';
        A = fscanf(fileID, formatSpec);
        fclose(fileID);
        
        m = length(A);
        A = reshape(A, 3, m/3)';
        n = size(A, 1);
        nl1 = A(1:n/2, :);
        nl2 = A(n/2 + 1:n, :);
        
        plot(nl1(nl1(:, 3) > 0, 1), nl1(nl1(:, 3) > 0, 2), 'b.');
        hold on; grid on;
        plot(nl2(nl2(:, 3) > 0, 1), nl2(nl2(:, 3) > 0, 2), 'r.');
        title(['SecID = 11, Count = ' num2str(ii)]);
        axis equal; hold off;
    end
    pause(0.1);
end