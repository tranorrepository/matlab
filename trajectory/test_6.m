% TEST_6.m
% T cross merge algorithm
% use virtual data to merge T cross road
%
% use four configure points to describe a T cross
%           A                B
%           *                *
%                .        .
%                     *O
%                     .
%
%                     *
%                     C
%
%
% and all possible roads are
%    A -> O -> B or B -> O -> A    ---- 1 or 2
%    A -> O -> C or C -> O -> A    ---- 3 or 4
%    B -> O -> C or C -> O -> B    ---- 5 or 6
%
% only one full possible road is valid, which means cars cannot start
% from the middle of these roads
%
% need to save 6 data group for each direction and reverse direction
%
%

clear variables; clc;

clf(figure(326))
clf(figure(325))

num_of_db_groups = 6;

%% load source data
% cfg_pnts             % 4x2 (x, y)
% num_of_cfg_pnts = 4
% ref_cfg_pnts         % .x | .y
                       % 4 points O A B C
% ref_pnt              % .x | .y
% theta
% xlimits              % rotated x limitation of each direction
% 
load('ref_data.mat');

% num_of_valid_group = 17
% valid_group_* [1~17]
% *.left.x *.left.y *.right.x *.right.y *.gps.x *.gps.y
load('valid_group_data.mat');


%% direction estimation
group_index = zeros(num_of_valid_group, 1);

for ii = 1:num_of_valid_group
    eval(['valid_group_data = valid_group_' num2str(ii) ';']); 
    
    % start point nearest cfg point
    tmp_ones = ones(num_of_cfg_pnts - 1, 2);
    tmp_ones(:, 1) = tmp_ones(:, 1) * valid_group_data.gps.x(1);
    tmp_ones(:, 2) = tmp_ones(:, 2) * valid_group_data.gps.y(1);
    tmp_dist = tmp_ones - cfg_pnts(2:end, :);
    tmp_dist = tmp_dist .* tmp_dist;
    dist = tmp_dist(:, 1) + tmp_dist(:, 2);
    [~, st_ind] = min(dist);
    
    % end point nearest cfg point
    tmp_ones = ones(num_of_cfg_pnts - 1, 2);
    tmp_ones(:, 1) = tmp_ones(:, 1) * valid_group_data.gps.x(end);
    tmp_ones(:, 2) = tmp_ones(:, 2) * valid_group_data.gps.y(end);
    tmp_dist = tmp_ones - cfg_pnts(2:end, :);
    tmp_dist = tmp_dist .* tmp_dist;
    dist = tmp_dist(:, 1) + tmp_dist(:, 2);
    [~, ed_ind] = min(dist);
    
    % data group index
    if st_ind == ed_ind
        fprintf('valid_group_%d\n', ii);
    else
        if st_ind == 1 && ed_ind == 2 % AB
            group_index(ii) = 2;
        elseif st_ind == 2 && ed_ind == 1 % BA
            group_index(ii) = 1;
        elseif st_ind == 1 && ed_ind == 3 % AC
            group_index(ii) = 4;
        elseif st_ind == 3 && ed_ind == 1 % CA
            group_index(ii) = 3;
        elseif st_ind == 2 && ed_ind == 3 % BC
            group_index(ii) = 6;
        elseif st_ind == 3 && ed_ind == 2 % CB
            group_index(ii) = 5;
        else
            fprintf('invalid start and end matched index\n');
        end
    end
end


%% merge the same group
group_data = struct('left', struct('x', [], 'y', []), ...
    'right', struct('x', [], 'y', []));

for ii = 1:num_of_db_groups
    group_data(ii).left = [];
    group_data(ii).right = [];
end

new_group_data = group_data;

for ii = 1:num_of_valid_group
    eval(['valid_group_data = valid_group_' num2str(ii) ';']);
    
    % plot the data
    figure(326)
    subplot(2, 1, 1)
    plot(valid_group_data.gps.x, valid_group_data.gps.y, 'g.', ...
        valid_group_data.gps.x(1), valid_group_data.gps.y(1), 'r*', ...
        valid_group_data.gps.x(end), valid_group_data.gps.y(end), 'b*', ...
        valid_group_data.left.x, valid_group_data.left.y, 'k.', ...
        valid_group_data.right.x, valid_group_data.right.y, 'k.');
    axis equal;
    title(['Group ' num2str(ii), ', Direction ' num2str(group_index(ii))]);
    
    % for reverse direction, change left/right order
    if mod(group_index(ii), 2) == 0
        rot_data_left = rotateLine(valid_group_data.right, ...
            -theta(floor((group_index(ii) + 1) / 2)));
        rot_data_right = rotateLine(valid_group_data.left, ...
            -theta(floor((group_index(ii) + 1) / 2)));
    else
        rot_data_left = rotateLine(valid_group_data.left, ...
            -theta(floor((group_index(ii) + 1) / 2)));
        rot_data_right = rotateLine(valid_group_data.right, ...
            -theta(floor((group_index(ii) + 1) / 2)));
    end
    
    % x resample limits
    index = mod(group_index(ii), 2) * (group_index(ii):group_index(ii) + 1) + ...
        (1 - mod(group_index(ii), 2)) * (group_index(ii) - 1:group_index(ii));
    tmpx = linspace(xlimits.x(index(1)), xlimits.x(index(2)), 1000)';
    
    lfhdl = fit(rot_data_left.x, rot_data_left.y, 'poly9');
    tmply = feval(lfhdl, tmpx);
    rfhdl = fit(rot_data_right.x, rot_data_right.y, 'poly9');
    tmpry = feval(rfhdl, tmpx);
    
    if isempty(group_data(group_index(ii)).left)
        group_data(group_index(ii)).left.x = tmpx;
        group_data(group_index(ii)).left.y = tmply;
        group_data(group_index(ii)).right.x = tmpx;
        group_data(group_index(ii)).right.y = tmpry;
    else
        group_data(group_index(ii)).left.y = 0.5 * group_data(group_index(ii)).left.y + ...
            0.5 * tmply;
        group_data(group_index(ii)).right.y = 0.5 * group_data(group_index(ii)).right.y + ...
            0.5 * tmpry;
    end
    
    figure(326)
    subplot(2, 1, 2)
    plot(rot_data_left.x, rot_data_left.y, 'k.', ...
        rot_data_right.x, rot_data_right.y, 'k.', ...
        tmpx, tmply, 'r.', tmpx, tmpry, 'b.'); axis equal
    title(['Group ' num2str(ii), ', Direction ' num2str(group_index(ii))]);
    
    pause(0.1);
end


%% merge new group data to output T cross

% merge the same direction
num_of_directions = num_of_db_groups / 2;

output_group_data = struct('lines', struct('x', [], 'y', []));

for ii = 1:num_of_directions
    output_group_data(ii).lines = [];
    
    if ~isempty(group_data(2 * ii - 1).left) && ...
            ~isempty(group_data(2 * ii).left)
        num_of_pnts = length(group_data(2 * ii - 1).left.x);
        
        dl1r2 = sum(group_data(2 * ii - 1).left.y - ...
            group_data(2 * ii).right.y);
        dr1l2 = sum(group_data(2 * ii - 1).right.y - ...
            group_data(2 * ii).left.y);
        if abs(dl1r2) < abs(dr1l2)
            % 2nd line
            output_group_data(ii).lines(2).x = group_data(2 * ii).left.x;
            output_group_data(ii).lines(2).y = 0.5 * group_data(2*ii).right.y + ...
                0.5 * group_data(2*ii - 1).left.y;
            
            dr2 = output_group_data(ii).lines(2).y - group_data(2*ii).right.y;
            dl1 = output_group_data(ii).lines(2).y - group_data(2*ii - 1).left.y;
            
            % 1st line
            output_group_data(ii).lines(1).x = group_data(2 * ii).left.x;
            output_group_data(ii).lines(1).y = group_data(2 * ii).left.y + dr2;
            
            % 3rd line
            output_group_data(ii).lines(3).x = group_data(2 * ii).left.x;
            output_group_data(ii).lines(3).y = group_data(2 * ii - 1).right.y + dl1;
        else
            % 2nd line
            output_group_data(ii).lines(2).x = group_data(2 * ii).left.x;
            output_group_data(ii).lines(2).y = 0.5 * group_data(2*ii- 1).right.y + ...
                0.5 * group_data(2*ii).left.y;
            
            dr1 = output_group_data(ii).lines(2).y - group_data(2*ii - 1).right.y;
            dl2 = output_group_data(ii).lines(2).y - group_data(2*ii).left.y;
            
            % 1st line
            output_group_data(ii).lines(1).x = group_data(2 * ii).left.x;
            output_group_data(ii).lines(1).y = group_data(2 * ii - 1).left.y + dr1;
            
            % 3rd line
            output_group_data(ii).lines(3).x = group_data(2 * ii).left.x;
            output_group_data(ii).lines(3).y = group_data(2 * ii).right.y + dl2;
        end
    else
        % backward direction
        if ~isempty(group_data(2*ii-1).left)
            
            % 1st line
            output_group_data(ii).lines(1).x = [];
            output_group_data(ii).lines(1).y = [];
            
            % 1nd line
            output_group_data(ii).lines(2).x = group_data(2*ii-1).left.x;
            output_group_data(ii).lines(2).y = group_data(2*ii-1).left.y;
            
            % 2rd line
            output_group_data(ii).lines(3).x = group_data(2*ii-1).right.x;
            output_group_data(ii).lines(3).y = group_data(2*ii-1).right.y;
            
        % foreward direction
        else
            
            % 1st line
            output_group_data(ii).lines(1).x = group_data(2*ii).left.x;
            output_group_data(ii).lines(1).y = group_data(2*ii).left.y;
            
            % 2nd line
            output_group_data(ii).lines(2).x = group_data(2*ii).right.x;
            output_group_data(ii).lines(2).y = group_data(2*ii).right.y;
            
            % 3rd line
            output_group_data(ii).lines(3).x = [];
            output_group_data(ii).lines(3).y = [];
            
        end
    end
    
end


%% rotate back
% for ii = 1:num_of_db_groups
%     if ~isempty(group_data(ii).left)
%         new_group_data(ii).left = rotateLine(group_data(ii).left, ...
%             theta(floor((ii + 1) / 2)));
%         new_group_data(ii).right = rotateLine(group_data(ii).right, ...
%             theta(floor((ii + 1) / 2)));
%         
%         figure(325)
%         plot(new_group_data(ii).left.x, new_group_data(ii).left.y, ...
%             new_group_data(ii).right.x, new_group_data(ii).right.y);
%         hold on; axis equal;
%     end
% end
% figure(325)
% plot(cfg_pnts(:, 1), cfg_pnts(:, 2), 'g*');
% hold off;


%% rotate back output data and plot out
output_data = struct('lines', struct('x', [], 'y', []));
for ii = 1:num_of_directions
    num_of_lines = length(output_group_data(ii).lines);
    for jj = 1:num_of_lines
        if ~isempty(output_group_data(ii).lines(jj).x)
            output_data(ii).lines(jj) = rotateLine(output_group_data(ii).lines(jj), ...
                theta(ii));
            
            figure(325)
            plot(output_data(ii).lines(jj).x, ...
                output_data(ii).lines(jj).y);
            hold on; axis equal;
        else
            output_data(ii).lines(jj).x = [];
            output_data(ii).lines(jj).y = [];
        end
    end
end
figure(325)
plot(cfg_pnts(:, 1), cfg_pnts(:, 2), 'g*');
hold off;


%% find nearest point to center pointoutput_data_segs = struct('lines', struct('x', 0.0, 'y', 0.0));
half_index = [1, 2; 1, 3; 2, 3];
segs_index = [1; 1; 1];
output_data_segs = struct('lines', struct('x', [], 'y', []));
for ii = 1:num_of_directions
    num_of_lines = length(output_data(ii).lines);
    for jj = 1:num_of_lines
        if ~isempty(output_data(ii).lines(jj).x)
            
            % find closest point on line
            num_of_pnts = length(output_data(ii).lines(jj).x);
            tmp_ones = ones(num_of_pnts, 2);
            tmp_ones(:, 1) = tmp_ones(:, 1) * cfg_pnts(1, 1);
            tmp_ones(:, 2) = tmp_ones(:, 2) * cfg_pnts(1, 2);
            
            tmp_dist = [tmp_ones(:, 1) - output_data(ii).lines(jj).x, ...
                tmp_ones(:, 2) - output_data(ii).lines(jj).y];
            tmp_dist = tmp_dist .* tmp_dist;
            dist = tmp_dist(:, 1) + tmp_dist(:, 2);
            [~, minind] = min(dist);
            
            figure(325)
            plot(output_data(ii).lines(jj).x, ...
                output_data(ii).lines(jj).y, ...
                output_data(ii).lines(jj).x(minind), ...
                output_data(ii).lines(jj).y(minind), 'go');
            hold on; axis equal;
            
            % extract direction data
            output_data_segs(half_index(ii, 1)).lines(segs_index(half_index(ii, 1))).x = ...
                output_data(ii).lines(jj).x(1:minind);
            output_data_segs(half_index(ii, 1)).lines(segs_index(half_index(ii, 1))).y = ...
                output_data(ii).lines(jj).y(1:minind);
            segs_index(half_index(ii, 1)) = segs_index(half_index(ii, 1)) + 1;
            
            output_data_segs(half_index(ii, 2)).lines(segs_index(half_index(ii, 2))).x = ...
                output_data(ii).lines(jj).x(minind+1:end);
            output_data_segs(half_index(ii, 2)).lines(segs_index(half_index(ii, 2))).y = ...
                output_data(ii).lines(jj).y(minind+1:end);
            segs_index(half_index(ii, 2)) = segs_index(half_index(ii, 2)) + 1;
            
            
        else
            output_data_segs(half_index(ii, 1)).lines(segs_index(half_index(ii, 1))).x = [];
            output_data_segs(half_index(ii, 1)).lines(segs_index(half_index(ii, 1))).y = [];
            segs_index(half_index(ii, 1)) = segs_index(half_index(ii, 1)) + 1;
            
            output_data_segs(half_index(ii, 2)).lines(segs_index(half_index(ii, 2))).x = [];
            output_data_segs(half_index(ii, 2)).lines(segs_index(half_index(ii, 2))).y = [];
            segs_index(half_index(ii, 2)) = segs_index(half_index(ii, 2)) + 1;
        end
    end
end
figure(325)
plot(cfg_pnts(:, 1), cfg_pnts(:, 2), 'g*');
hold off;


%% plot output segs data

color = ['r'; 'g'; 'b'; 'k'; 'm'; 'c'];
for ii = 1:num_of_directions
    num_of_lines = length(output_data_segs(ii).lines);
    for jj = 1:num_of_lines
        if ~isempty(output_data_segs(ii).lines(jj).x)
            
            figure(325)
            plot(output_data_segs(ii).lines(jj).x, ...
                output_data_segs(ii).lines(jj).y, color(jj));
            hold on; axis equal;
        end
    end
end
figure(325)
plot(cfg_pnts(:, 1), cfg_pnts(:, 2), 'g*');
hold off;


%% merge same direction lines
% suppose there is tree lines

theta_ABCO = zeros(num_of_directions, 1);
% AO direction
theta_ABCO(1) = atan2(cfg_pnts(1, 2) - cfg_pnts(2, 2), cfg_pnts(1, 1) - cfg_pnts(2, 1));
% BO direction
theta_ABCO(2) = atan2(cfg_pnts(1, 2) - cfg_pnts(3, 2), cfg_pnts(1, 1) - cfg_pnts(3, 1));
% CO direction
theta_ABCO(3) = atan2(cfg_pnts(1, 2) - cfg_pnts(4, 2), cfg_pnts(1, 1) - cfg_pnts(4, 1));

rot_output_minx = Inf * ones(num_of_directions, num_of_db_groups);
rot_output_maxx = -Inf * ones(num_of_directions, num_of_db_groups);
rot_output_data_segs = struct('lines', struct('x', [], 'y', []));
% rotate along direction to center
for ii = 1:num_of_directions
    num_of_lines = length(output_data_segs(ii).lines);
    for jj = 1:num_of_lines
        if ~isempty(output_data_segs(ii).lines(jj).x)
            
            valid_line(1) = 1;
            rot_output_data_segs(ii).lines(jj) = ...
                rotateLine(output_data_segs(ii).lines(jj), -theta_ABCO(ii));
            
            rot_output_minx(ii, jj) = min(rot_output_data_segs(ii).lines(jj).x);
            rot_output_maxx(ii, jj) = max(rot_output_data_segs(ii).lines(jj).x);
        else
            rot_output_data_segs(ii).lines(jj).x = [];
            rot_output_data_segs(ii).lines(jj).y = [];
        end
    end
end

% resample and merge
merge_relations = [4, 5, 6; 6, 5, 4; 4, 5, 6;];
is_merged = zeros(num_of_directions, 3);
diff_y = struct('lines', struct('y1', [], 'y2', []));
rot_out_data_segs_merged = struct('lines', struct('x', [], 'y', []));
for ii = 1:num_of_directions
    minx = max(rot_output_minx(ii, (rot_output_minx(ii, :) ~= Inf)));
    maxx = min(rot_output_maxx(ii, (rot_output_maxx(ii, :) ~= -Inf)));
    tmpx = linspace(minx, maxx, 500)';
    
    num_of_lines = length(rot_output_data_segs(ii).lines);
    for jj = 1:3 % three lines
        if ~isempty(rot_output_data_segs(ii).lines(jj).x) && ...
                ~isempty(rot_output_data_segs(ii).lines(merge_relations(ii, jj)).x)
            
            fitline1 = fit(rot_output_data_segs(ii).lines(jj).x, ...
                rot_output_data_segs(ii).lines(jj).y, 'poly9');
            tmpline1y = feval(fitline1, tmpx);
            fitline2 = fit(rot_output_data_segs(ii).lines(merge_relations(ii, jj)).x, ...
                rot_output_data_segs(ii).lines(merge_relations(ii, jj)).y, 'poly9');
            tmpline2y = feval(fitline2, tmpx);
            
            tmpy = 0.5 * tmpline1y + 0.5 * tmpline2y;
            
            diff_y(ii).lines(jj).y1 = tmpy - tmpline1y;
            diff_y(ii).lines(jj).y2 = tmpy - tmpline2y;
            
            is_merged(ii, jj) = 1;
            
            rot_out_data_segs_merged(ii).lines(jj).x = tmpx;
            rot_out_data_segs_merged(ii).lines(jj).y = tmpy;
        elseif ~isempty(rot_output_data_segs(ii).lines(jj).x)
            
            fitline1 = fit(rot_output_data_segs(ii).lines(jj).x, ...
                rot_output_data_segs(ii).lines(jj).y, 'poly9');
            tmpy = feval(fitline1, tmpx);
            
            rot_out_data_segs_merged(ii).lines(jj).x = tmpx;
            rot_out_data_segs_merged(ii).lines(jj).y = tmpy;
        elseif ~isempty(rot_output_data_segs(ii).lines(merge_relations(ii, jj)).x)
            
            fitline2 = fit(rot_output_data_segs(ii).lines(merge_relations(ii, jj)).x, ...
                rot_output_data_segs(ii).lines(merge_relations(ii, jj)).y, 'poly9');
            tmpy = feval(fitline2, tmpx);
            
            rot_out_data_segs_merged(ii).lines(jj).x = tmpx;
            rot_out_data_segs_merged(ii).lines(jj).y = tmpy;
        end
    end
end

% adjust unmerged
% for ii = 1:num_of_directions
%     for jj = 1:3 % three lines
%         if is_merged(ii, jj) == 0 && sum(is_merged(ii, :), 2) > 0 
%             
%         end
%     end
% end


rot_out_data_segs_merged(1).lines(3).y = rot_out_data_segs_merged(1).lines(3).y + ...
    diff_y(1).lines(2).y2;

rot_out_data_segs_merged(2).lines(1).y = rot_out_data_segs_merged(2).lines(1).y + ...
    diff_y(2).lines(2).y1;
rot_out_data_segs_merged(2).lines(3).y = rot_out_data_segs_merged(2).lines(3).y + ...
    diff_y(2).lines(2).y2;

rot_out_data_segs_merged(3).lines(3).y = rot_out_data_segs_merged(3).lines(3).y + ...
    diff_y(3).lines(2).y1;


% output data - rotate back
out_data_segs_merged = struct('lines', struct('x', 0.0, 'y', 0.0));
for ii = 1:num_of_directions
    num_of_lines = length(rot_out_data_segs_merged(ii).lines);
    for jj = 1:num_of_lines
        if ~isempty(rot_out_data_segs_merged(ii).lines(jj).x)
            
            out_data_segs_merged(ii).lines(jj) = rotateLine(rot_out_data_segs_merged(ii).lines(jj), ...
                theta_ABCO(ii));
        end
    end
end


%% plot output T cross data
color = ['r'; 'g'; 'b'; 'k'; 'm'; 'c'];
for ii = 1:num_of_directions
    num_of_lines = length(out_data_segs_merged(ii).lines);
    for jj = 1:num_of_lines
        if ~isempty(out_data_segs_merged(ii).lines(jj).x)
            
            figure(325)
            plot(...
                out_data_segs_merged(ii).lines(jj).x, ...
                out_data_segs_merged(ii).lines(jj).y, color(jj));
            hold on; axis equal;
        end
    end
end
figure(325)
plot(cfg_pnts(:, 1), cfg_pnts(:, 2), 'g*');
hold off;


%% fit data to get better result
output_ref_gps = struct('x', 0.0, 'y', 0.0);

% AC left most
num1 = length(out_data_segs_merged(1).lines(3).x);
num2 = length(out_data_segs_merged(3).lines(3).x);
line.x = zeros(num1 + num2, 1);
line.y = zeros(num1 + num2, 1);
line.x(1:num1) = out_data_segs_merged(1).lines(3).x;
line.x(num1+1:end) = flip(out_data_segs_merged(3).lines(3).x);
line.y(1:num1) = out_data_segs_merged(1).lines(3).y;
line.y(num1+1:end) = flip(out_data_segs_merged(3).lines(3).y);

rot_line = rotateLine(line, -theta(2));

minx = min(rot_line.x);
maxx = max(rot_line.x);
line_sample.x = linspace(minx, maxx, 1000)';

fitline1 = fit(rot_line.x, rot_line.y, 'poly9');
line_sample.y = feval(fitline1, line_sample.x);

new_line = rotateLine(line_sample, theta(2));
output_ref_gps(1).x = new_line.x;
output_ref_gps(1).y = new_line.y;

figure(325)
plot(new_line.x, new_line.y, 'r'); hold on; axis equal;

% AB right most
num1 = length(out_data_segs_merged(1).lines(1).x);
num2 = length(out_data_segs_merged(2).lines(1).x);
line.x = zeros(num1 + num2, 1);
line.y = zeros(num1 + num2, 1);
line.x(1:num1) = out_data_segs_merged(1).lines(1).x;
line.x(num1+1:end) = flip(out_data_segs_merged(2).lines(1).x);
line.y(1:num1) = out_data_segs_merged(1).lines(1).y;
line.y(num1+1:end) = flip(out_data_segs_merged(2).lines(1).y);

rot_line = rotateLine(line, -theta(1));

minx = min(rot_line.x);
maxx = max(rot_line.x);
line_sample.x = linspace(minx, maxx, 1000)';

fitline1 = fit(rot_line.x, rot_line.y, 'poly9');
line_sample.y = feval(fitline1, line_sample.x);

new_line = rotateLine(line_sample, theta(1));
output_ref_gps(2).x = new_line.x;
output_ref_gps(2).y = new_line.y;


figure(325)
plot(new_line.x, new_line.y, 'r');

% BC right most
num1 = length(out_data_segs_merged(2).lines(3).x);
num2 = length(out_data_segs_merged(3).lines(1).x);
line.x = zeros(num1 + num2, 1);
line.y = zeros(num1 + num2, 1);
line.x(1:num1) = out_data_segs_merged(2).lines(3).x;
line.x(num1+1:end) = flip(out_data_segs_merged(3).lines(1).x);
line.y(1:num1) = out_data_segs_merged(2).lines(3).y;
line.y(num1+1:end) = flip(out_data_segs_merged(3).lines(1).y);

rot_line = rotateLine(line, -theta(3));

minx = min(rot_line.x);
maxx = max(rot_line.x);
line_sample.x = linspace(minx, maxx, 1000)';

fitline1 = fit(rot_line.x, rot_line.y, 'poly9');
line_sample.y = feval(fitline1, line_sample.x);

new_line = rotateLine(line_sample, theta(3));
output_ref_gps(3).x = new_line.x;
output_ref_gps(3).y = new_line.y;


figure(325)
plot(new_line.x, new_line.y, 'r');


plot(out_data_segs_merged(1).lines(2).x, ...
    out_data_segs_merged(1).lines(2).y, 'g', ...
    out_data_segs_merged(2).lines(2).x, ...
    out_data_segs_merged(2).lines(2).y, 'g', ...
    out_data_segs_merged(3).lines(2).x, ...
    out_data_segs_merged(3).lines(2).y, 'g');

for ii = 1:num_of_valid_group
    eval(['valid_group_data = valid_group_' num2str(ii) ';']);
    plot(valid_group_data.gps.x, valid_group_data.gps.y, 'k');
end


plot(cfg_pnts(:, 1), cfg_pnts(:, 2), 'g*');
hold off;

output_ref_gps(4).x = out_data_segs_merged(1).lines(2).x;
output_ref_gps(4).y = out_data_segs_merged(1).lines(2).y;
output_ref_gps(5).x = out_data_segs_merged(2).lines(2).x;
output_ref_gps(5).y = out_data_segs_merged(2).lines(2).y;
output_ref_gps(6).x = out_data_segs_merged(3).lines(2).x;
output_ref_gps(6).y = out_data_segs_merged(3).lines(2).y;


%% generate KML file

standPoint.lat = ref_pnt.y;
standPoint.lon = ref_pnt.x;
standPoint.alt = 0.000000;

COEFF_DD2METER = 111320.0;
PI = 3.1415926536;

% Output to kml file

fid = fopen('roadVec.kml', 'w+');
if fid > 0
    % kml file header tags: <xml>, <kml>, <Document>
    fprintf(fid, '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kml>\n<Document>\n');
    
    % tags: <Style>, <StyleMap>
    fprintf(fid, '    <Style id=\"greenLineStyle\"><LineStyle><color>ff00ff00</color></LineStyle></Style>\n');
    fprintf(fid, '    <StyleMap id=\"greenLine\"><Pair><key>normal</key><styleUrl>#greenLineStyle</styleUrl></Pair></StyleMap>\n');
    
    % For each line data
    numOfLines = size(output_ref_gps, 2);
    for ll = 1:numOfLines
        line.x = output_ref_gps(ll).x;
        line.y = output_ref_gps(ll).y;
        
        % tags: <Placemark>, <name>
        fprintf(fid, '    <Placemark>\n        <name>Line-%d</name>\n', ll);
        % tag: styleUrl
        fprintf(fid, '        <styleUrl>#greenLine</styleUrl>\n');
        % tag: <LineString>
        fprintf(fid, '        <LineString>\n');
        % tag: <coordinates>
        fprintf(fid, '            <coordinates>\n                ');
        
        pntNum = length(line.x);
        
        for kk = 1:pntNum
            latitude = (standPoint.lat)*PI/180;
            
            diff_x = line.x(kk) / (111413*cos(latitude)-94*cos(3*latitude));
            diff_y = line.y(kk) / COEFF_DD2METER;
            diff_z = 0.000000;
            
            outGpsPoint.lon = standPoint.lon + diff_x;
            outGpsPoint.lat = standPoint.lat + diff_y;
            outGpsPoint.alt = standPoint.alt + diff_z;
            
            fprintf(fid, '%.7f,%.7f,%f ', outGpsPoint.lon, outGpsPoint.lat, outGpsPoint.alt);
        end
        
        fprintf(fid, '\n            </coordinates>\n        </LineString>\n    </Placemark>\n');
    end
end

% End tags
fprintf(fid, '</Document>\n</kml>');

fclose(fid);
