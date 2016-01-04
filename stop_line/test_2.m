% TEST_2.m
% Plot all landmark data and extracted features
%


clear variables; clc;

clf(figure(111));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data
for ii = 0:20
    lm_format = sprintf('./data/landmarker_%d.txt', ii);
    if exist(lm_format, 'file')
        fid = fopen(lm_format, 'r');
        A = fscanf(fid, '%f %f %f %f');
        fclose(fid);
        
        m = length(A);
        eval(['lm_source' num2str(ii) ' = reshape(A, 5, m/5)'';']);
        eval(['lm_data' num2str(ii) '.x = lm_source' num2str(ii) '(:, 2);']);
        eval(['lm_data' num2str(ii) '.y = lm_source' num2str(ii) '(:, 1);']);
        eval(['lm_data' num2str(ii) '.g = lm_source' num2str(ii) '(:, 5);']);
        
        eval(['lm_data{' num2str(ii + 1) ', 1} = lm_data' num2str(ii) ';']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handle each landmark

num_of_data = size(lm_data, 1);
lm_features_all = cell(num_of_data, 1);

lm_groups = struct('x', 0, 'y', 0, 'g', 0);
lm_feature = struct('center', struct(struct('x', 0, 'y', 0, 'g', 0)), ...
    'length', 0, 'theta', 0.0, ...
    'start', struct('x', 0, 'y', 0), ...
    'stop', struct('x', 0, 'y', 0));



lm_database = [];

for ii = 1:num_of_data
    if isempty(lm_data{ii})
        continue;
    end
    
    % number of landmark groups
    group_items = unique(lm_data{ii}.g);
    num_of_groups = length(group_items);
    
%     clf(figure(111));
    
    % extract each group data
    for jj = 1:num_of_groups
        fprintf('set: %d, group: %d\n', ii, jj);
        
        lm_groups(jj).x = lm_data{ii}.x(lm_data{ii}.g == group_items(jj));
        lm_groups(jj).y = lm_data{ii}.y(lm_data{ii}.g == group_items(jj));
        lm_groups(jj).g = lm_data{ii}.g(lm_data{ii}.g == group_items(jj));
                
        [lm_feature(jj).center, lm_feature(jj).length, lm_feature(jj).theta, ...
            lm_feature(jj).start, lm_feature(jj).stop] = extractStopLine(lm_groups(jj));

        figure(111)
        plot(lm_groups(jj).x, lm_groups(jj).y, '.'); hold on; axis equal;
        plot(lm_feature(jj).center.x, lm_feature(jj).center.y, '*', 'MarkerSize', 5);
        plot([lm_feature(jj).start.x, lm_feature(jj).stop.x], ...
            [lm_feature(jj).start.y, lm_feature(jj).stop.y], 'b');
        title(['extract feature set: ' num2str(ii) ', group: '  num2str(num_of_groups)]);
    end
    
    pause(0.1);
end