% TEST_7.m
% plot data of directory C:\Users\Ming.Chen\Desktop\results\11_27_0
%

clear variables; clc;

clf(figure(225))

for group_id = 0:100
    file_str = sprintf('C:/Users/Ming.Chen/Desktop/results/11_27_0/fgdatabase_merged_%d.txt', group_id);
    if exist(file_str, 'file')
        data = load(file_str);
        
        half_size = size(data, 1)  / 2;
        
        left.x = data(1:half_size, 1);
        left.y = data(1:half_size, 2);
        left.p = data(1:half_size, 3);
        
        right.x = data(half_size+1:end, 1);
        right.y = data(half_size+1:end, 2);
        right.p = data(half_size+1:end, 3);
        
        figure(225)
        plot(left.x(left.p > 0), left.y(left.p > 0), 'r.', ...
            right.x(right.p > 0), right.y(right.p > 0), 'b.');
        axis equal; title(['Group = ' num2str(group_id)])
        
        pause;
    end
end