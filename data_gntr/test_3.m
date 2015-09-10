
addpath('.\data_sec11_1');

clf(figure(101));

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
        hold on; grid on; axis equal;
        plot(nl2(nl2(:, 3) > 0, 1), nl2(nl2(:, 3) > 0, 2), 'r.');
        
%         ind1 = find(nl1(:, 3) == 1);
%         ind2 = find(nl2(:, 3) == 1);
%         ind = intersect(ind1, ind2);
%         dx = mean(nl1(ind, 1) - nl2(ind, 1));
%         dy = mean(nl1(ind, 2) - nl2(ind, 2));
%         
%         if size(ind1) < size(ind2)
%             nl2(ind2, 1) = nl1(ind2, 1) - dx;
%             nl2(ind2, 2) = nl1(ind2, 2) - dy;
%             nl2(ind2, 3) = nl1(ind2, 3);
%         else    
%             nl1(ind2, 1) = nl2(ind2, 1) + dx;
%             nl1(ind2, 2) = nl2(ind2, 2) + dy;
%             nl1(ind2, 3) = nl2(ind2, 3);
%         end
        
        nl3 = nl2;
        nl3(:, 1) = nl3(:, 1) + 5;

        plot(nl3(nl2(:, 3) > 0, 1), nl3(nl2(:, 3) > 0, 2), 'g.');
        title(['SecID = 11, Count = ' num2str(ii)]);
        hold off;
    end
    pause(0.1);
end