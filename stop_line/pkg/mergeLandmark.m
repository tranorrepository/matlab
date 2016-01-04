function lm_database = mergeLandmark(lm_db, lm_feature)
% MERGELANDMARK
%    merge landmark
%
%    INPUT:
%    lm_db - stop line landmark database data
%    lm_feature - new stop line feature data
%
%    OUTPUT:
%    lm_database - updated new database landmark
%
%


% feature data structure definition
% lm_database = struct('center', struct(struct('x', 0, 'y', 0, 'g', 0)), ...
%    'length', 0, 'theta', 0.0, ...
%    'start', struct('x', 0, 'y', 0), ...
%    'stop', struct('x', 0, 'y', 0));

lm_database = lm_db;

num_of_db_groups = size(lm_db, 2);
num_of_new_groups = size(lm_feature, 2);

% center points of database
db_centers = zeros(num_of_db_groups, 2);
db_start_stop = zeros(2 * num_of_db_groups, 2);
for ii = 1:num_of_db_groups
    db_centers(ii, 1:2) = [lm_db(ii).center.x, lm_db(ii).center.y];
    db_start_stop(2 * ii - 1, 1:2) = [lm_db(ii).start.x, lm_db(ii).start.y];
    db_start_stop(2 * ii, 1:2) = [lm_db(ii).stop.x, lm_db(ii).stop.y];
end

tempDistData = ones(num_of_db_groups, 2);
for ii = 1:num_of_new_groups
    tempDistData(:, 1:2) = 1;
    tempDistData(:, 1) = tempDistData(:, 1) * lm_feature(ii).center.x;
    tempDistData(:, 2) = tempDistData(:, 2) * lm_feature(ii).center.y;
    distData = tempDistData - db_centers;
    distData = distData .* distData;
    dist = sqrt(distData(:, 1) + distData(:, 2));
    [minDist, minInd] = min(dist);
    minInd = ii;
    
    % if minimum distance is greater than a threshold, it's a new landmark
    if minDist > 20
        lm_database(end + 1) = lm_feature(ii);
    else
        % merge
        lm_database(minInd).center.x = 0.75 * lm_db(minInd).center.x + ...
            (1 - 0.75) * lm_feature(ii).center.x;
        lm_database(minInd).center.y = 0.75 * lm_db(minInd).center.y + ...
            (1 - 0.75) * lm_feature(ii).center.y;
        
        % length
        lm_database(minInd).length = 0.75 * lm_db(minInd).length + ...
            (1 - 0.75) * lm_feature(ii).length;
        
        % theta
        lm_database(minInd).theta = atan(0.75 * tan(lm_db(minInd).theta) + ...
            (1 - 0.75) * tan(lm_feature(ii).theta));
        
        % start and stop point
        [lm_database(minInd).start, lm_database(minInd).stop] = calcEndPoints(...
            lm_database(minInd).center, ...
            lm_database(minInd).length, ...
            lm_database(minInd).theta);
    end
end


% center points of new landmark
new_centers = zeros(num_of_new_groups, 2);
new_start_stop = zeros(2 * num_of_new_groups, 2);
for ii = 1:num_of_new_groups
    new_centers(ii, 1:2) = [lm_feature(ii).center.x, lm_feature(ii).center.y];
    new_start_stop(2 * ii - 1, 1:2) = [lm_feature(ii).start.x, lm_feature(ii).start.y];
    new_start_stop(2 * ii, 1:2) = [lm_feature(ii).stop.x, lm_feature(ii).stop.y];
end


% center points of new database
num_of_new_db_groups = size(lm_database, 2);
new_db_centers = zeros(num_of_new_db_groups, 2);
new_db_start_stop = zeros(2 * num_of_new_db_groups, 2);
for ii = 1:num_of_new_db_groups
    new_db_centers(ii, 1:2) = [lm_database(ii).center.x, lm_database(ii).center.y];
    new_db_start_stop(2 * ii - 1, 1:2) = [lm_database(ii).start.x, lm_database(ii).start.y];
    new_db_start_stop(2 * ii, 1:2) = [lm_database(ii).stop.x, lm_database(ii).stop.y];
end

figure(111)
plot(db_centers(:, 1), db_centers(:, 2), 'k*', 'MarkerSize', 5);
hold on; axis equal;
for ii = 1:num_of_db_groups
    plot(db_start_stop(2*ii - 1:2*ii, 1), db_start_stop(2*ii - 1:2*ii, 2), 'k');
end

% plot(new_centers(:, 1), new_centers(:, 2), 'b*', 'MarkerSize', 5);
% for ii = 1:num_of_new_groups
%     plot(new_start_stop(2*ii - 1:2*ii, 1), new_start_stop(2*ii - 1:2*ii, 2), 'b');
% end

plot(new_db_centers(:, 1), new_db_centers(:, 2), 'g*', 'MarkerSize', 5);
for ii = 1:num_of_new_db_groups
    plot(new_db_start_stop(2*ii - 1:2*ii, 1), new_db_start_stop(2*ii - 1:2*ii, 2), 'g', 'MarkerSize', 5);
end
hold off;
% title('merging stop line');

end
