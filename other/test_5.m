function test_5()
% TEST_5
%

clear variables; clc;
clf(figure(200));


folder_str1 = 'C:/Users/Ming.Chen/Desktop/results/12_10_4/';
folder_str2 = 'C:/Users/Ming.Chen/Desktop/results/12_10_5/';
file_str = 'fg_%d_sec_36_group_0_lane_0.txt';

for fg_id = 382 % 0:1324
    src_file1 = sprintf([folder_str1 file_str], fg_id);
    src_file2 = sprintf([folder_str2 file_str], fg_id);
    if exist(src_file1, 'file') && exist(src_file2, 'file')
        [src_left1, src_right1, ~] = get_lines(src_file1);
        [src_left2, src_right2, ~] = get_lines(src_file2);
        
        figure(200);
        plot(src_left1.x, src_left1.y, 'k.', ...
            src_right1.x, src_right1.y, 'k.', ...
            src_left1.x(src_left1.p>0), src_left1.y(src_left1.p>0), 'r.', ...
            src_right1.x(src_right1.p>0), src_right1.y(src_right1.p>0), 'b.', ...
            src_left2.x+10, src_left2.y, 'k.', ...
            src_right2.x+10, src_right2.y, 'k.', ...
            src_left2.x(src_left2.p>0)+10, src_left2.y(src_left2.p>0), 'm.', ...
            src_right2.x(src_right2.p>0)+10, src_right2.y(src_right2.p>0), 'c.');
        axis equal;
        title(['Source of FG ' num2str(fg_id)]);
        
        pause(0.1);
    end
end