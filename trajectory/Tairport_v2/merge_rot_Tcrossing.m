function merge_rot_Tcrossing()
% MERGE_ROT_TCROSSING
%
% merge T-crossing road of airport
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

%% save data out
% seg_lane_data = struct('lines', ...
%     struct('left', struct('x', [], 'y', []), ...
%     'right', struct('x', [], 'y', [])));
load('seg_lane_data.mat', 'seg_lane_data');


%% merge each direction data of T crossing
num_of_dir = 6;
num_of_angles = 3;
% convert struct to matrix
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

merged_rot_lane_data = struct('lines', ...
    struct('left', struct('x', [], 'y', []), ...
    'right', struct('x', [], 'y', [])));

% AB, BA, AC, CA, BC, CB
angle_ind = [1, 1, 2, 2, 3, 3];

for ii = 1:num_of_Tcrossing
    for dd = 1:num_of_dir
        
        % initialization
        merged_rot_lane_data(ii).lines(dd).left = [];
        merged_rot_lane_data(ii).lines(dd).left = [];
        merged_rot_lane_data(ii).lines(dd).right = [];
        merged_rot_lane_data(ii).lines(dd).righ = [];
        
        num_of_lines = length(seg_lane_data(ii).lines(dd).left);
        for ll = 1:num_of_lines
            % resampling
            if angle_ind(dd) == 1
                tmpx = linspace(xlimits(ii).AB.minx, xlimits(ii).AB.maxx, 1000)';
            elseif angle_ind(dd) == 2
                tmpx = linspace(xlimits(ii).AC.minx, xlimits(ii).AC.maxx, 1000)';
            elseif angle_ind(dd) == 3
                tmpx = linspace(xlimits(ii).BC.minx, xlimits(ii).BC.maxx, 1000)';
            end
            
            % ratation
            left_line = seg_lane_data(ii).lines(dd).left(ll);
            right_line = seg_lane_data(ii).lines(dd).right(ll);
            rot_left = rotateLine(left_line, -rot_angle(ii, angle_ind(dd)));
            rot_right = rotateLine(right_line, -rot_angle(ii, angle_ind(dd)));
            
            fit_left = fit(rot_left.x, rot_left.y, 'poly9');
            tmpy_left = feval(fit_left, tmpx);
            fit_right = fit(rot_right.x, rot_right.y, 'poly9');
            tmpy_right = feval(fit_right, tmpx);
            
            figure(1000); subplot(211);
            plot(rot_left.x, rot_left.y, 'k', ...
                rot_right.x, rot_right.y, 'k', ...
                tmpx, tmpy_left, 'r', tmpx, tmpy_right, 'b');
            axis equal;
            title(['rotate and resample ' ...
                'Tcrossing ' num2str(ii) ...
                ' direction ' num2str(dd) ...
                ' line ' num2str(ll)]);
            
            if (min(rot_left.x) - 5) > tmpx(1) || ...
                    (max(rot_left.x) + 5) < tmpx(end)
                fprintf('Tcrossing %d, direction %d\n', ii, dd);
                continue;
            end
            
            % if db is empty, add directly. otherwise merge it with db
            if isempty(merged_rot_lane_data(ii).lines(dd).left)
                merged_rot_lane_data(ii).lines(dd).left.x = tmpx;
                merged_rot_lane_data(ii).lines(dd).left.y = tmpy_left;
                merged_rot_lane_data(ii).lines(dd).right.x = tmpx;
                merged_rot_lane_data(ii).lines(dd).right.y = tmpy_right;
            else
                merged_rot_lane_data(ii).lines(dd).left.x = tmpx;
                merged_rot_lane_data(ii).lines(dd).left.y = ...
                    0.5 * merged_rot_lane_data(ii).lines(dd).left.y + ...
                    0.5 * tmpy_left;
                merged_rot_lane_data(ii).lines(dd).right.x = tmpx;
                merged_rot_lane_data(ii).lines(dd).right.y = ...
                    0.5 * merged_rot_lane_data(ii).lines(dd).right.y + ...
                    0.5 * tmpy_right;
            end
            
            figure(1000); subplot(212);
            plot(merged_rot_lane_data(ii).lines(dd).left.x, ...
                merged_rot_lane_data(ii).lines(dd).left.y, 'r', ...
                merged_rot_lane_data(ii).lines(dd).right.x, ...
                merged_rot_lane_data(ii).lines(dd).right.y, 'b');
            axis equal; title(['Tcrosing ' num2str(ii) ' direction ' num2str(dd)]);
            
            pause(0.1);
        end
    end
end


%% plot merged lane data
clf(figure(1000))
color = ['r'; 'g'; 'b'; 'k'; 'm'; 'c';];
merged_lane_data = struct('lines', ...
    struct('left', struct('x', [], 'y', []), ...
    'right', struct('x', [], 'y', [])));
for ii = 1:num_of_Tcrossing
    for dd = 1:num_of_dir
        if ~isempty(merged_rot_lane_data(ii).lines(dd).left)
            % roate back
            merged_lane_data(ii).lines(dd).left = ...
                rotateLine(merged_rot_lane_data(ii).lines(dd).left, ...
                rot_angle(ii, angle_ind(dd)));
            merged_lane_data(ii).lines(dd).right = ...
                rotateLine(merged_rot_lane_data(ii).lines(dd).right, ...
                rot_angle(ii, angle_ind(dd)));
            figure(1000)
            plot(merged_lane_data(ii).lines(dd).left.x, ...
                merged_lane_data(ii).lines(dd).left.y, color(dd), ...
                merged_lane_data(ii).lines(dd).right.x, ...
                merged_lane_data(ii).lines(dd).right.y, color(dd));
            hold on; axis equal;
            title('Merged lane data');
            
            pause(0.1);
        else
            merged_lane_data(ii).lines(dd).left = [];
            merged_lane_data(ii).lines(dd).right = [];
        end
    end
end
figure(1000); hold off;


%% save data out
% merged_lane_data = struct('lines', ...
%     struct('left', struct('x', [], 'y', []), ...
%     'right', struct('x', [], 'y', [])));
save('merged_lane_data.mat', 'merged_lane_data');