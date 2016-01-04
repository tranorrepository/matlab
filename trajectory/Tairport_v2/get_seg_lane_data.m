function get_seg_lane_data()
% GET_SEG_lane_DATA
%
% extract valid lane data to small segmentations
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

% valid_lane_data = struct('left', struct('x', [], 'y', []), ...
%     'right', struct('x', [], 'y', []));
load('valid_lane_data.mat');

% center cfg points
center_cfg_pnts = zeros(num_of_Tcrossing, 2);
for ii = 1:num_of_Tcrossing
    center_cfg_pnts(ii, :) = [ref_cfg_pnts(ii).x(1), ref_cfg_pnts(ii).y(1)];
    
    figure(1000); subplot(211)
    plot(ref_cfg_pnts(ii).x, ref_cfg_pnts(ii).y, 'g*');
    hold on; axis equal;
end


%% iterate each valid GPS tracks to get segment data
seg_group_data = struct('group', ...
    struct('left', struct('x', [], 'y', []), ...
    'right', struct('x', [], 'y', [])));
num_of_valid_lanes = length(valid_lane_data);
grp_ind = zeros(num_of_Tcrossing, 1);
for ii = 1:num_of_valid_lanes
    
    for jj = 1:num_of_Tcrossing
        num_of_pnts = length(valid_lane_data(ii).left.x);
        tmp_ones = ones(num_of_pnts,2);
        tmp_ones(:, 1) = tmp_ones(:, 1) * center_cfg_pnts(jj, 1);
        tmp_ones(:, 2) = tmp_ones(:, 2) * center_cfg_pnts(jj, 2);
        
        tmp_dist = zeros(num_of_pnts, 1);
        tmp_dist(:, 1) = tmp_ones(:, 1) - valid_lane_data(ii).left.x;
        tmp_dist(:, 2) = tmp_ones(:, 2) - valid_lane_data(ii).left.y;
        tmp_dist = tmp_dist .* tmp_dist;
        dist = tmp_dist(:, 1) + tmp_dist(:, 2);
        valid_ind = find(dist <= 10000);
        
        if ~isempty(valid_ind)
            diff_ind = valid_ind(2:end) - valid_ind(1:end-1);
            jump_ind = [0; find(diff_ind ~= 1); length(valid_ind)];
            for kk = 1 : length(jump_ind)-1
                data_ind = valid_ind(jump_ind(kk)+1:jump_ind(kk+1));
                
                grp_ind(jj) = grp_ind(jj) + 1;
                seg_group_data(jj).group(grp_ind(jj)).left.x = ...
                    valid_lane_data(ii).left.x(data_ind);
                seg_group_data(jj).group(grp_ind(jj)).left.y = ...
                    valid_lane_data(ii).left.y(data_ind);
                seg_group_data(jj).group(grp_ind(jj)).right.x = ...
                    valid_lane_data(ii).right.x(data_ind);
                seg_group_data(jj).group(grp_ind(jj)).right.y = ...
                    valid_lane_data(ii).right.y(data_ind);
            end
        end
    end
    
    figure(1000); subplot(211)
    plot(valid_lane_data(ii).left.x, valid_lane_data(ii).left.y, 'r', ...
        valid_lane_data(ii).right.x, valid_lane_data(ii).right.y, 'b');
    axis equal;
    title([ num2str(ii) ' valid lane data of Tcrossing ']);
    
    pause(0.1);
end
figure(1000); subplot(211); hold off;


%% segment each lane data to correct direction
num_of_dir = 6;

% A:1, B:2, C:3
% AB:1, BA:2, AC:3, CA:4, BC:5, CB:6
line_ind = ones(num_of_Tcrossing, num_of_dir);

% row first, column second
%   A B C
% A 0 1 3
% B 2 0 5
% C 4 6 0
dir_ind = [0, 1, 3; 2, 0, 5; 4, 6, 0];

seg_lane_data = struct('lines', ...
    struct('left', struct('x', [], 'y', []), ...
    'right', struct('x', [], 'y', [])));

for ii = 1:num_of_Tcrossing
    num_of_grps = length(seg_group_data(ii).group);
    
    % ii-th center configuration points
    cfg_pnts = [ref_cfg_pnts(ii).x, ref_cfg_pnts(ii).y];
    
    for jj = 1:num_of_grps
        left_data = seg_group_data(ii).group(jj).left;
        right_data = seg_group_data(ii).group(jj).right;
        
        for nn = 1:num_of_Tcrossing
            figure(1000); subplot(212)
            plot(ref_cfg_pnts(nn).x, ref_cfg_pnts(nn).y, 'g*');
            hold on; axis equal;
        end
        
        figure(1000); subplot(212);
        plot(left_data.x, left_data.y, 'r', right_data.x, right_data.y, 'b');
        title(['Tcrossing ' num2str(ii) ' data group ' num2str(jj)]);
        figure(1000); subplot(212); hold off;
        
        pause(0.1);
        
        % minimum distance to end points
        num_of_pnts = length(left_data.x);
        tmp_ones = ones(num_of_pnts, 6);
        tmp_ones(:, 1) = tmp_ones(:, 1) * cfg_pnts(2, 1);
        tmp_ones(:, 2) = tmp_ones(:, 2) * cfg_pnts(2, 2);
        tmp_ones(:, 3) = tmp_ones(:, 3) * cfg_pnts(3, 1);
        tmp_ones(:, 4) = tmp_ones(:, 4) * cfg_pnts(3, 2);
        tmp_ones(:, 5) = tmp_ones(:, 5) * cfg_pnts(4, 1);
        tmp_ones(:, 6) = tmp_ones(:, 6) * cfg_pnts(4, 2);
        
        tmp_data = zeros(num_of_pnts, 6);
        tmp_data(:, 1) = left_data.x;
        tmp_data(:, 2) = left_data.y;
        tmp_data(:, 3) = left_data.x;
        tmp_data(:, 4) = left_data.y;
        tmp_data(:, 5) = left_data.x;
        tmp_data(:, 6) = left_data.y;
        
        tmp_dist = tmp_ones - tmp_data;
        tmp_dist = tmp_dist .* tmp_dist;
        dist = tmp_dist(:, 1:2:5) + tmp_dist(:, 2:2:6);
        [min_dist, min_ind] = min(dist, [], 2);
        
        has_two_parts = 0;
        if length(unique(min_ind)) == 1
            continue;
        elseif length(unique(min_ind)) == 2
            if min_ind(1) == min_ind(end)
                has_two_parts = 1;
                index = unique(min_ind);
                if index(1) ~= min_ind(1)
                    other_ind = index(1);
                else
                    other_ind = index(2);
                end
                
                other_dist = min_dist(min_ind == other_ind);
                min_other_ind = find(min_dist == min(other_dist), 1);
            end
        elseif length(unique(min_ind)) == 3
            index = unique(min_ind);
            other_ind = intersect(find(index ~= min_ind(1)), ...
                find(index ~= min_ind(end)));
            other_dist = min_dist(min_ind == other_ind(1));
            min_other_ind = find(min_dist == min(other_dist), 1);
            
            if min(other_dist) <= 280
                has_two_parts = 1;
            end
        end
        
        st_ind = min_ind(1);
        ed_ind = min_ind(end);
        if st_ind == ed_ind
            if has_two_parts
                if length(index) == 3
                    other_ind = other_ind(1);
                end
                
                % first half
                ind_of_dir = dir_ind(st_ind, other_ind);
                ind_of_line = line_ind(ii, ind_of_dir);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).x = ...
                    left_data.x(1:min_other_ind);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).y = ...
                    left_data.y(1:min_other_ind);
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).x = ...
                    right_data.x(1:min_other_ind);
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).y = ...
                    right_data.y(1:min_other_ind);
                line_ind(ii, ind_of_dir) = line_ind(ii, ind_of_dir) + 1;
                
                % second half
                ind_of_dir = dir_ind(other_ind, st_ind);
                ind_of_line = line_ind(ii, ind_of_dir);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).x = ...
                    left_data.x(min_other_ind:end);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).y = ...
                    left_data.y(min_other_ind:end);
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).x = ...
                    right_data.x(min_other_ind:end);
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).y = ...
                    right_data.y(min_other_ind:end);
                line_ind(ii, ind_of_dir) = line_ind(ii, ind_of_dir) + 1;
            end
        else
            if has_two_parts == 1
                
                % first part
                ind_of_dir = dir_ind(st_ind, other_ind);
                ind_of_line = line_ind(ii, ind_of_dir);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).x = ...
                    left_data.x(1:min_other_ind);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).y = ...
                    left_data.y(1:min_other_ind);
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).x = ...
                    right_data.x(1:min_other_ind);
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).y = ...
                    right_data.y(1:min_other_ind);
                line_ind(ii, ind_of_dir) = line_ind(ii, ind_of_dir) + 1;
                
                % second part
                ind_of_dir = dir_ind(other_ind, ed_ind);
                ind_of_line = line_ind(ii, ind_of_dir);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).x = ...
                    left_data.x(min_other_ind:end);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).y = ...
                    left_data.y(min_other_ind:end);
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).x = ...
                    right_data.x(min_other_ind:end);
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).y = ...
                    right_data.y(min_other_ind:end);
                line_ind(ii, ind_of_dir) = line_ind(ii, ind_of_dir) + 1;
            else
                ind_of_dir = dir_ind(st_ind, ed_ind);
                ind_of_line = line_ind(ii, ind_of_dir);
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).x = ...
                    left_data.x;
                seg_lane_data(ii).lines(ind_of_dir).left(ind_of_line).y = ...
                    left_data.y;
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).x = ...
                    right_data.x;
                seg_lane_data(ii).lines(ind_of_dir).right(ind_of_line).y = ...
                    right_data.y;
                line_ind(ii, ind_of_dir) = line_ind(ii, ind_of_dir) + 1;
            end
        end % end of st_ind ~= ed_ind
    end % end of groups
    
    if length(seg_lane_data(ii).lines) < num_of_dir
        seg_lane_data(ii).lines(num_of_dir).left = [];
        seg_lane_data(ii).lines(num_of_dir).right = [];
    end
    
end % end of Tcrossing iterate


%% plot segment lane data
clf(figure(1000));
color = ['r', 'g', 'b', 'k', 'm', 'c'];
for ii = 1:num_of_Tcrossing
    for dd = 1:num_of_dir
        num_of_lines = length(seg_lane_data(ii).lines(dd).left);
        for ll = 1:num_of_lines
            figure(1000)
            plot(ref_cfg_pnts(ii).x, ref_cfg_pnts(ii).y, 'g*', ...
                seg_lane_data(ii).lines(dd).left(ll).x, ...
                seg_lane_data(ii).lines(dd).left(ll).y, color(dd), ...
                seg_lane_data(ii).lines(dd).right(ll).x, ...
                seg_lane_data(ii).lines(dd).right(ll).y, color(dd));
            axis equal;
            title(['Tcrossing ' num2str(ii) ...
                ' direction ' num2str(dd) ' line ' num2str(ll)]);
            
            pause(0.1);
        end
    end
end


%% save data out
% seg_lane_data = struct('lines', ...
%     struct('left', struct('x', [], 'y', []), ...
%     'right', struct('x', [], 'y', [])));
save('seg_lane_data.mat', 'seg_lane_data');