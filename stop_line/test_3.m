% TEST_3.m
% landmark merge
%


clear variables; clc;

clf(figure(111));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data
for ii = 0:19
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
    
    % extract each group data
    blast = 0;
     
    if (blast == 0 && (ii == 11 || ii == 17)) || ...
            (blast == 1 && ii == 14) || ...
        (blast == 1 && num_of_groups < 8) || ...
            (blast == 0 && ((num_of_groups < 4) || (group_items(4) >= 4)))
        continue;
    end
    
    for jj = 1:4
        fprintf('set: %d, group: %d\n', ii, jj);
        
        lm_groups(jj).x = lm_data{ii}.x(lm_data{ii}.g == group_items(jj + 4 * blast));
        lm_groups(jj).y = lm_data{ii}.y(lm_data{ii}.g == group_items(jj + 4 * blast));
        lm_groups(jj).g = lm_data{ii}.g(lm_data{ii}.g == group_items(jj + 4 * blast));
                
        [lm_feature(jj).center, lm_feature(jj).length, lm_feature(jj).theta, ...
            lm_feature(jj).start, lm_feature(jj).stop] = extractStopLine(lm_groups(jj));

        if jj == 5
            clf(figure(111));
        end
        figure(111)
        plot(lm_groups(jj).x, lm_groups(jj).y, '.'); hold on; axis equal;
        plot(lm_feature(jj).center.x, lm_feature(jj).center.y, '*', 'MarkerSize', 5);
        plot([lm_feature(jj).start.x, lm_feature(jj).stop.x], ...
            [lm_feature(jj).start.y, lm_feature(jj).stop.y], 'b');
        title(['extract feature set: ' num2str(ii) ', group: '  num2str(lm_feature(jj).center.g)]);
    end
    
    lm_features_all{ii} = lm_feature;
    
    % merge
    if isempty(lm_database)
        lm_database = lm_features_all{ii};
    else
        % merge landmark feature
        lm_database = mergeLandmark(lm_database, lm_features_all{ii});
    end
    
    pause(1);
end

lm_database = [];
for ii = 1:num_of_data
    if isempty(lm_data{ii})
        continue;
    end
    
    % number of landmark groups
    group_items = unique(lm_data{ii}.g);
    num_of_groups = length(group_items);
    
    if num_of_groups ~= 8 || ii == 14
        continue;
    end
    
    for jj = 1:8
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
        title(['extract feature set: ' num2str(ii) ', group: '  num2str(lm_feature(jj).center.g)]);
    end
    
    lm_features_all{ii} = lm_feature;
    
    % merge
    if isempty(lm_database)
        lm_database = lm_features_all{ii};
    else
        % merge landmark feature
        lm_database = mergeLandmark(lm_database, lm_features_all{ii});
    end
    
    pause(1);
end