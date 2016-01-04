function test_6()
% TEST_6
% show T crossing output to check heart-beat issue
%
%

clear variables; clc;
clf(figure(121))

folder_str = 'C:/Users/Ming.Chen/Desktop/results/12_25_0/';
file_str = [folder_str 'fgdatabase_merged_%d.txt'];

for ii = 0:59
    file_name = sprintf(file_str, ii);
    if exist(file_name, 'file')
        data = load(file_name);
        
        %ind = find(data(:, 3) > 0);
        
        figure(121)
        plot(data(:, 1), data(:, 2), '.'); axis equal;
        
        pause(0.01);
    end
end