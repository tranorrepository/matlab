function merge_Tcrossing()
% MERGE_TCROSSING
%
%


%% initialization
clear variables; clc;
clf(figure(1000))


% load reference data
% num_of_Tcrossing = 4;
% ref_pnt.x = 11.76378193414014;
% ref_pnt.y = 48.35042162483494;
% abs_cfg_pnts = struct('lon', [], 'lat', []);
% ref_cfg_pnts = struct('x', [], 'y', []);
% theta = struct('AB', 0, 'AC', 0, 'BC', 0, 'AO', 0, 'BO', 0, 'CO', 0);
% xlimits = struct('AB', struct('minx', 0, 'maxx', 0), ...
%    'AC', struct('minx', 0, 'maxx', 0), ...
%    'BC', struct('minx', 0, 'maxx', 0));

load('ref_cfg_data.mat');

% merged_lane_data = struct('lines', ...
%     struct('left', struct('x', [], 'y', []), ...
%     'right', struct('x', [], 'y', [])));
load('merged_lane_data.mat');


%% convert struct to matrix
num_of_angles = 3;
rot_angle = zeros(num_of_Tcrossing, num_of_angles);
part_rot_angle = zeros(num_of_Tcrossing, num_of_angles);
for ii = 1:num_of_Tcrossing
    rot_angle(ii, 1) = theta(ii).AB;
    rot_angle(ii, 2) = theta(ii).AC;
    rot_angle(ii, 3) = theta(ii).BC;
    
    part_rot_angle(ii, 1) = theta(ii).AO;
    part_rot_angle(ii, 2) = theta(ii).BO;
    part_rot_angle(ii, 3) = theta(ii).CO;
end


%% split each lane data to two subdirections
% AB, BA, AC, CA, BC, CB
% AB: AO-OB, BA: BO-OA, AC: AO-OC, CA: CO-OA, BC: BO-OC, CB: CO-OB
% AO, BO, CO

sub_lane_data = struct('lines', ...
    struct('left', struct('x', [], 'y', []), ...
    'right', struct('x', [], 'y', [])));
num_of_dir = 6;

for ii = 1:num_of_Tcrossing
    for dd = 1:num_of_dir
        left_line = merged_lane_data(ii).lines(dd).left;
        right_line = merged_lane_data(ii).lines(dd).right;
        
        if isempty(left_line) || isempty(left_line.x)
            sub_lane_data(ii).lines(dd).left = [];
            sub_lane_data(ii).lines(dd).right = [];
            continue;
        end
        
        num_of_pnts = length(left_line.x);
        tmp_ones = ones(num_of_pnts, 2);
        tmp_ones(:, 1) = tmp_ones(:, 1) * ref_cfg_pnts(ii).x(1);
        tmp_ones(:, 2) = tmp_ones(:, 2) * ref_cfg_pnts(ii).y(1);
        
        tmp_dist = zeros(num_of_pnts, 2);
        tmp_dist(:, 1) = tmp_ones(:, 1) - left_line.x;
        tmp_dist(:, 2) = tmp_ones(:, 2) - left_line.y;
        tmp_dist = tmp_dist .* tmp_dist;
        dist = tmp_dist(:, 1) + tmp_dist(:, 2);
        [~, min_ind] = min(dist);
        
        figure(1000); subplot(211)
        plot(left_line.x, left_line.y, 'r', ...
            right_line.x, right_line.y, 'b', ...
            left_line.x(min_ind), left_line.y(min_ind), 'go', ...
            right_line.x(min_ind), right_line.y(min_ind), 'go');
        hold on; axis equal;
        title(['Closest point to Tcrossing center ' num2str(ii) ...
            ' direction ' num2str(dd)]);
        
        pause(0.1);
        
        % first part
        sub_lane_data(ii).lines(dd).left(1).x = ...
            left_line.x(1:min_ind);
        sub_lane_data(ii).lines(dd).left(1).y = ...
            left_line.y(1:min_ind);
        sub_lane_data(ii).lines(dd).right(1).x = ...
            right_line.x(1:min_ind);
        sub_lane_data(ii).lines(dd).right(1).y = ...
            right_line.y(1:min_ind);
        
        
        figure(1000); subplot(212)
        plot(sub_lane_data(ii).lines(dd).left(1).x, ...
            sub_lane_data(ii).lines(dd).left(1).y, ...
            sub_lane_data(ii).lines(dd).right(1).x, ...
            sub_lane_data(ii).lines(dd).right(1).y);
        hold on; axis equal;
        title(['Tcrossing ' num2str(ii) ...
            ' subdirection ' num2str(dd) ...
            ' part 1']);
        
        pause(0.1);
        
        % second part
        sub_lane_data(ii).lines(dd).left(2).x = ...
            left_line.x(min_ind+1:end);
        sub_lane_data(ii).lines(dd).left(2).y = ...
            left_line.y(min_ind+1:end);
        sub_lane_data(ii).lines(dd).right(2).x = ...
            right_line.x(min_ind+1:end);
        sub_lane_data(ii).lines(dd).right(2).y = ...
            right_line.y(min_ind+1:end);
        
        
        figure(1000); subplot(212)
        plot(sub_lane_data(ii).lines(dd).left(2).x, ...
            sub_lane_data(ii).lines(dd).left(2).y, ...
            sub_lane_data(ii).lines(dd).right(2).x, ...
            sub_lane_data(ii).lines(dd).right(2).y);
        axis equal;
        title(['Tcrossing ' num2str(ii) ...
            ' subdirection ' num2str(dd) ...
            ' part 2']);
        
        pause(0.1);
    end
end

figure(1000); subplot(211); hold off;
figure(1000); subplot(212); hold off;


%% merge sub-direction lane data
clf(figure(1000))

% AO: AB/AC, BA/CA
% BO: BA/BC, AB/CB
% CO: CA/CB, AC/BC
num_of_lanes = 2;
same_lane_ind = cell(num_of_angles, num_of_lanes);
same_lane_ind{1, 1} = {[1, 1], [3, 1]};
same_lane_ind{1, 2} = {[2, 1], [4, 1]};
same_lane_ind{2, 1} = {[1, 2], [6, 1]};
same_lane_ind{2, 2} = {[2, 2], [5, 1]};
same_lane_ind{3, 1} = {[3, 2], [5, 2]};
same_lane_ind{3, 2} = {[4, 2], [6, 2]};

merged_same_lane = struct('lines', ...
    struct('left', struct('x', [], 'y', []), ...
    'right', struct('x', [], 'y', [])));

for ii = 1:num_of_Tcrossing
    for aa = 1:num_of_angles
        for ll = 1:num_of_lanes
            dir1 = same_lane_ind{aa, ll}{1, 1}(1, 1);
            dir2 = same_lane_ind{aa, ll}{1, 2}(1, 1);
            line1 = same_lane_ind{aa, ll}{1, 1}(1, 2);
            line2 = same_lane_ind{aa, ll}{1, 2}(1, 2);
            if ~isempty(sub_lane_data(ii).lines(dir1).left) && ...
                    ~isempty(sub_lane_data(ii).lines(dir2).left)
                left_line1 = sub_lane_data(ii).lines(dir1).left(line1);
                right_line1 = sub_lane_data(ii).lines(dir1).right(line1);
                left_line2 = sub_lane_data(ii).lines(dir2).left(line2);
                right_line2 = sub_lane_data(ii).lines(dir2).right(line2);
                
                % rotate
                rot_left1 = rotateLine(left_line1, -part_rot_angle(ii, aa));
                rot_right1 = rotateLine(right_line1, -part_rot_angle(ii, aa));
                rot_left2 = rotateLine(left_line2, -part_rot_angle(ii, aa));
                rot_right2 = rotateLine(right_line2, -part_rot_angle(ii, aa));
                
                % xlimits
                minx = max(min(rot_left1.x), min(rot_left2.x));
                maxx = min(max(rot_left1.x), max(rot_left2.x));
                tmpx = (minx:0.1:maxx)';
                
                % re-sample
                fit_left1 = fit(rot_left1.x, rot_left1.y, 'poly9');
                tmpy_left1 = feval(fit_left1, tmpx);
                fit_right1 = fit(rot_right1.x, rot_right1.y, 'poly9');
                tmpy_right1 = feval(fit_right1, tmpx);
                fit_left2 = fit(rot_left2.x, rot_left2.y, 'poly9');
                tmpy_left2 = feval(fit_left2, tmpx);
                fit_right2 = fit(rot_right2.x, rot_right2.y, 'poly9');
                tmpy_right2 = feval(fit_right2, tmpx);
                
                % merge
                tmpy_left = 0.5 * tmpy_left1 + 0.5 * tmpy_left2;
                tmpy_right = 0.5 * tmpy_right1 + 0.5 * tmpy_right2;
                
                merged_same_lane(ii).lines(aa).left(ll).x = tmpx;
                merged_same_lane(ii).lines(aa).left(ll).y = tmpy_left;
                merged_same_lane(ii).lines(aa).right(ll).x = tmpx;
                merged_same_lane(ii).lines(aa).right(ll).y = tmpy_right;
                
                figure(1000)
                plot(merged_same_lane(ii).lines(aa).left(ll).x, ...
                    merged_same_lane(ii).lines(aa).left(ll).y, ...
                    merged_same_lane(ii).lines(aa).right(ll).x, ...
                    merged_same_lane(ii).lines(aa).right(ll).y);
                hold on; axis equal;
                title(['Merged same lane of Tcrossing ' num2str(ii) ...
                    ' lane ' num2str(aa)]);
                
                pause(0.1);
            elseif ~isempty(sub_lane_data(ii).lines(dir1).left)
                left_line1 = sub_lane_data(ii).lines(dir1).left(line1);
                right_line1 = sub_lane_data(ii).lines(dir1).right(line1);
                rot_left1 = rotateLine(left_line1, -part_rot_angle(ii, aa));
                rot_right1 = rotateLine(right_line1, -part_rot_angle(ii, aa));
                
                % xlimits
                tmpx = (min(rot_left1.x):0.1:max(rot_left1.x))';
                
                % re-sample
                fit_left1 = fit(rot_left1.x, rot_left1.y, 'poly9');
                tmpy_left1 = feval(fit_left1, tmpx);
                fit_right1 = fit(rot_right1.x, rot_right1.y, 'poly9');
                tmpy_right1 = feval(fit_right1, tmpx);
                
                merged_same_lane(ii).lines(aa).left(ll).x = tmpx;
                merged_same_lane(ii).lines(aa).left(ll).y = tmpy_left1;
                merged_same_lane(ii).lines(aa).right(ll).x = tmpx;
                merged_same_lane(ii).lines(aa).right(ll).y = tmpy_right1;
            elseif ~isempty(sub_lane_data(ii).lines(dir2).left)
                left_line2 = sub_lane_data(ii).lines(dir2).left(line2);
                right_line2 = sub_lane_data(ii).lines(dir2).right(line2);
                rot_left2 = rotateLine(left_line2, -part_rot_angle(ii, aa));
                rot_right2 = rotateLine(right_line2, -part_rot_angle(ii, aa));
                
                % x limitations
                tmpx = (min(rot_left2.x):0.1:max(rot_left2.x))';
                
                % resample
                fit_left2 = fit(rot_left2.x, rot_left2.y, 'poly9');
                tmpy_left2 = feval(fit_left2, tmpx);
                fit_right2 = fit(rot_right2.x, rot_right2.y, 'poly9');
                tmpy_right2 = feval(fit_right2, tmpx);
                
                merged_same_lane(ii).lines(aa).left(ll).x = tmpx;
                merged_same_lane(ii).lines(aa).left(ll).y = tmpy_left2;
                merged_same_lane(ii).lines(aa).right(ll).x = tmpx;
                merged_same_lane(ii).lines(aa).right(ll).y = tmpy_right2;
            else
                merged_same_lane(ii).lines(aa).left(ll) = [];
                merged_same_lane(ii).lines(aa).right(ll) = [];
            end
        end
    end
end
figure(1000); hold off;


%% merge shared line
% left first lane + right second lane
merged_dir_lines = struct('lines', ...
    struct('line', struct('x', [], 'y', [])));

for ii = 1:num_of_Tcrossing
    for aa = 1:num_of_angles
        % x limitations
        minx = max(merged_same_lane(ii).lines(aa).left(1).x(1), ...
            merged_same_lane(ii).lines(aa).right(2).x(1));
        maxx = min(merged_same_lane(ii).lines(aa).left(1).x(end), ...
            merged_same_lane(ii).lines(aa).right(2).x(end));
        tmpx = (minx:0.1:maxx)';
        
        left_line1 = merged_same_lane(ii).lines(aa).left(1);
        right_line1 = merged_same_lane(ii).lines(aa).right(1);
        left_line2 = merged_same_lane(ii).lines(aa).left(2);
        right_line2 = merged_same_lane(ii).lines(aa).right(2);
        
        figure(1000); subplot(211)
        plot(left_line1.x, left_line1.y, 'r', ...
            right_line1.x, right_line1.y, 'g', ...
            left_line2.x, left_line2.y, 'b', ...
            right_line2.x, right_line2.y, 'k');
        axis equal;
        title(['Rotated lane data of Tcrossing ' num2str(ii) ...
            ' direction ' num2str(aa)]);
        
        pause(0.1);
        
        % resample
        fit_left1 = fit(left_line1.x, left_line1.y, 'poly9');
        tmpy_left1 = feval(fit_left1, tmpx);
        fit_right1 = fit(right_line1.x, right_line1.y, 'poly9');
        tmpy_right1 = feval(fit_right1, tmpx);
        fit_left2 = fit(left_line2.x, left_line2.y, 'poly9');
        tmpy_left2 = feval(fit_left2, tmpx);
        fit_right2 = fit(right_line2.x, right_line2.y, 'poly9');
        tmpy_right2 = feval(fit_right2, tmpx);
        
        % merge left1 and right2
        tmpy_mid = 0.5 * tmpy_left1 + 0.5 * tmpy_left2;
        d1 = tmpy_mid - tmpy_left1;
        d2 = tmpy_mid - tmpy_left2;
        
        % output
        % 1st line
        line1.x = tmpx;
        line1.y = tmpy_right2 + d2;
        merged_dir_lines(ii).lines(aa).line(1) = ...
            rotateLine(line1, part_rot_angle(ii, aa));
        
        % 2nd line
        line2.x = tmpx;
        line2.y = tmpy_mid;
        merged_dir_lines(ii).lines(aa).line(2) = ...
            rotateLine(line2, part_rot_angle(ii, aa));
        
        % 3rd line
        line3.x = tmpx;
        line3.y = tmpy_right1 + d1;
        merged_dir_lines(ii).lines(aa).line(3) = ...
            rotateLine(line3, part_rot_angle(ii, aa));
        
        figure(1000); subplot(212);
        plot(merged_dir_lines(ii).lines(aa).line(1).x, ...
            merged_dir_lines(ii).lines(aa).line(1).y, ...
            merged_dir_lines(ii).lines(aa).line(2).x, ...
            merged_dir_lines(ii).lines(aa).line(2).y, ...
            merged_dir_lines(ii).lines(aa).line(3).x, ...
            merged_dir_lines(ii).lines(aa).line(3).y);
        hold on; axis equal;
        title(['Merged Tcrossing ' num2str(ii) ' direction ' num2str(aa)]);
        
        pause(0.1);
    end
end


%% save data out
% merged_dir_lines = struct('lines', ...
%     struct('line', struct('x', [], 'y', [])));
save('merged_dir_lines.mat', 'merged_dir_lines');
