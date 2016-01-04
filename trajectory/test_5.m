% TEST_5.m
% extract whole lane data to group data

clear variables; clc;

% valid_data_?
% *.left *.right *.gps
% *.*.x *.*.y
load('valid_lane_data.mat');

num_of_groups = 6;

% valid index for each group
valid_ind_1 = [0; 319; 731];
valid_ind_2 = [0; 263; 593];
valid_ind_3 = [0; 287];
valid_ind_4 = [0; 833; 1359; 2199; 2933];
valid_ind_5 = [0; 405; 1129; 1857; 2277; 3016];
valid_ind_6 = [0; 691; 1134; 1926];

clf(figure(326))

index = 1;

for ii = 1:num_of_groups
    eval(['valid_data = valid_data_' num2str(ii) ';']);
    eval(['valid_ind = valid_ind_' num2str(ii) ';']);
    
    valid_group_num = length(valid_ind) - 1;
    for jj = 1:valid_group_num
        eval(['valid_group_' num2str(index) '.left.x = ' ...
            'valid_data.left.x(valid_ind(jj) + 1 : valid_ind(jj+1));']);
        eval(['valid_group_' num2str(index) '.left.y = ' ...
            'valid_data.left.y(valid_ind(jj) + 1 : valid_ind(jj+1));']);
        eval(['valid_group_' num2str(index) '.right.x = ' ...
            'valid_data.right.x(valid_ind(jj) + 1 : valid_ind(jj+1));']);
        eval(['valid_group_' num2str(index) '.right.y = ' ...
            'valid_data.right.y(valid_ind(jj) + 1 : valid_ind(jj+1));']);
        eval(['valid_group_' num2str(index) '.gps.x = ' ...
            'valid_data.gps.x(valid_ind(jj) + 1 : valid_ind(jj+1));']);
        eval(['valid_group_' num2str(index) '.gps.y = ' ...
            'valid_data.gps.y(valid_ind(jj) + 1 : valid_ind(jj+1));']);
        
        eval(['valid_group = valid_group_' num2str(index) ';']);
        
        figure(326)
        plot(valid_group.left.x, valid_group.left.y, 'r.', ...
            valid_group.right.x, valid_group.right.y, 'b.', ...
            valid_group.gps.x, valid_group.gps.y, 'g.'); axis equal;
        
        index = index + 1;
    end
    
end