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

% num_of_db_groups = 6;
% gps_seg_data = struct('AB', struct('x', [], 'y', []), ...
%     'BA', struct('x', [], 'y', []), ...
%     'AC', struct('x', [], 'y', []), ...
%     'CA', struct('x', [], 'y', []), ...
%     'BC', struct('x', [], 'y', []), ...
%     'CB', struct('x', [], 'y', []));
load('gps_seg_data.mat');

% merged_rot_gps_data = struct('AB', struct('x', [], 'y', []), ...
%     'BA', struct('x', [], 'y', []), ...
%     'AC', struct('x', [], 'y', []), ...
%     'CA', struct('x', [], 'y', []), ...
%     'BC', struct('x', [], 'y', []), ...
%     'CB', struct('x', [], 'y', []));
load('merged_rot_gps_data.mat');


%% create left and right line data
ROAD_WIDTH = 5;
num_of_directions = num_of_db_groups / 2;
merged_rot_gps = struct('gps', struct('x', [], 'y', []));
rot_angle = zeros(num_of_Tcrossing, num_of_directions);
part_rot_angle = zeros(num_of_Tcrossing, num_of_directions);
for ii = 1:num_of_Tcrossing
    merged_rot_gps(ii).gps(1).x = merged_rot_gps_data(ii).AB.x;
    merged_rot_gps(ii).gps(1).y = merged_rot_gps_data(ii).AB.y;
    merged_rot_gps(ii).gps(2).x = merged_rot_gps_data(ii).BA.x;
    merged_rot_gps(ii).gps(2).y = merged_rot_gps_data(ii).BA.y;
    merged_rot_gps(ii).gps(3).x = merged_rot_gps_data(ii).AC.x;
    merged_rot_gps(ii).gps(3).y = merged_rot_gps_data(ii).AC.y;
    merged_rot_gps(ii).gps(4).x = merged_rot_gps_data(ii).CA.x;
    merged_rot_gps(ii).gps(4).y = merged_rot_gps_data(ii).CA.y;
    merged_rot_gps(ii).gps(5).x = merged_rot_gps_data(ii).BC.x;
    merged_rot_gps(ii).gps(5).y = merged_rot_gps_data(ii).BC.y;
    merged_rot_gps(ii).gps(6).x = merged_rot_gps_data(ii).CB.x;
    merged_rot_gps(ii).gps(6).y = merged_rot_gps_data(ii).CB.y;
    
    rot_angle(ii, 1) = theta(ii).AB;
    rot_angle(ii, 2) = theta(ii).AC;
    rot_angle(ii, 3) = theta(ii).BC;
    
    part_rot_angle(ii, 1) = theta(ii).AO;
    part_rot_angle(ii, 2) = theta(ii).BO;
    part_rot_angle(ii, 3) = theta(ii).CO;
end

merged_rot_data = struct('lines', struct('left', struct('x', [], 'y', []), ...
    'right', struct('x', [], 'y', [])));
for ii = 1:num_of_Tcrossing
    for mm = 1:num_of_db_groups
        ref_gps_data = merged_rot_gps(ii).gps(mm);
        
        if isempty(ref_gps_data.x)
            merged_rot_data(ii).lines(mm).left.x = [];
            merged_rot_data(ii).lines(mm).left.y = [];
            merged_rot_data(ii).lines(mm).right.x = [];
            merged_rot_data(ii).lines(mm).right.y = [];
            continue;
        end
        
        num_of_pnts = length(ref_gps_data.x);
        
        left.x = zeros(num_of_pnts, 1);
        left.y = zeros(num_of_pnts, 1);
        right.x = zeros(num_of_pnts, 1);
        right.y = zeros(num_of_pnts, 1);
        
        % for previous points_num - 1 points
        for jj = 1:num_of_pnts - 1
            kk = jj + 1;
            for kk = jj+1 : num_of_pnts
                if 0.005 <= abs(ref_gps_data.y(kk) - ref_gps_data.y(jj))
                    break;
                end
            end
            theta = atan2(ref_gps_data.y(kk) - ref_gps_data.y(jj), ...
                ref_gps_data.x(kk) - ref_gps_data.x(jj));
            
            left.x(jj) = ref_gps_data.x(jj) - 0.5 * ROAD_WIDTH * sin(theta);
            left.y(jj) = ref_gps_data.y(jj) + 0.5 * ROAD_WIDTH * cos(theta);
            
            right.x(jj) = ref_gps_data.x(jj) + 0.5 * ROAD_WIDTH * sin(theta);
            right.y(jj) = ref_gps_data.y(jj) - 0.5 * ROAD_WIDTH * cos(theta);
        end
        
        % for last point
        theta = atan2(ref_gps_data.y(end) - ref_gps_data.y(end - 1), ...
            ref_gps_data.x(end) - ref_gps_data.x(end - 1));
        left.x(end) = ref_gps_data.x(end) - 0.5 * ROAD_WIDTH * sin(theta);
        left.y(end) = ref_gps_data.y(end) + 0.5 * ROAD_WIDTH * cos(theta);
        right.x(end) = ref_gps_data.x(end) + 0.5 * ROAD_WIDTH * sin(theta);
        right.y(end) = ref_gps_data.y(end) - 0.5 * ROAD_WIDTH * cos(theta);
        
        merged_rot_data(ii).lines(mm).left = left;
        merged_rot_data(ii).lines(mm).right = right;
        
        figure(1000)
        plot(merged_rot_data(ii).lines(mm).left.x, ...
            merged_rot_data(ii).lines(mm).left.y, 'r', ...
            merged_rot_data(ii).lines(mm).right.x, ...
            merged_rot_data(ii).lines(mm).right.y, 'b', ...
            ref_gps_data.x, ref_gps_data.y, 'k');
        axis equal; title('Created lane data, Tcrossing');
        pause(0.1);
        
    end
end


%% merge AB/BA, AC/CA, BC/CB
% merge the same direction
merged_direction_data = struct('dir', ...
    struct('lines', struct('x', [], 'y', [])));
for ii = 1:num_of_Tcrossing
    for mm = 1:num_of_directions
        merged_rot_data(ii).lines(mm).left;
        merged_rot_data(ii).lines(mm).right;
        
        if ~isempty(merged_rot_data(ii).lines(2*mm-1).left.x) && ...
            ~isempty(merged_rot_data(ii).lines(2*mm).left.x)
            % 2nd line AB left, BA right
            merged_direction_data(ii).dir(mm).lines(2).x = ...
                merged_rot_data(ii).lines(2*mm).left.x;
            merged_direction_data(ii).dir(mm).lines(2).y = ...
                0.5 * merged_rot_data(ii).lines(2*mm-1).left.y + ...
                0.5 * merged_rot_data(ii).lines(2*mm).right.y;
            
            d1 = merged_direction_data(ii).dir(mm).lines(2).y - ...
                merged_rot_data(ii).lines(2*mm-1).left.y;
            d2 = merged_direction_data(ii).dir(mm).lines(2).y - ...
                merged_rot_data(ii).lines(2*mm).right.y;
            
            % 1st line BA left
            merged_direction_data(ii).dir(mm).lines(1).x = ...
                merged_rot_data(ii).lines(2*mm).left.x;
            merged_direction_data(ii).dir(mm).lines(1).y = ...
                merged_rot_data(ii).lines(2*mm).left.y + d2;
            
            % 3rd line AB right
            merged_direction_data(ii).dir(mm).lines(3).x = ...
                merged_rot_data(ii).lines(2*mm).left.x;
            merged_direction_data(ii).dir(mm).lines(3).y = ...
                merged_rot_data(ii).lines(2*mm-1).right.y + d1;
            
        else
            % AB
            if ~isempty(merged_rot_data(ii).lines(2*mm-1).left.x)
                % 1st line
                merged_direction_data(ii).dir(mm).lines(1).x = [];
                merged_direction_data(ii).dir(mm).lines(1).y = [];
                
                % 2nd line
                merged_direction_data(ii).dir(mm).lines(2).x = ...
                    merged_rot_data(ii).lines(2*mm-1).left.x;
                merged_direction_data(ii).dir(mm).lines(2).y = ...
                    merged_rot_data(ii).lines(2*mm-1).left.y;
                
                % 3rd line
                merged_direction_data(ii).dir(mm).lines(3).x = ...
                    merged_rot_data(ii).lines(2*mm-1).right.x;
                merged_direction_data(ii).dir(mm).lines(3).y = ...
                    merged_rot_data(ii).lines(2*mm-1).right.y;
            % BA
            elseif ~isempty(merged_rot_data(ii).lines(2*mm).left.x)
                % 1st line
                merged_direction_data(ii).dir(mm).lines(1).x = ...
                    merged_rot_data(ii).lines(2*mm).left.x;
                merged_direction_data(ii).dir(mm).lines(1).y = ...
                    merged_rot_data(ii).lines(2*mm).left.y;
                
                % 2ndd line
                merged_direction_data(ii).dir(mm).lines(2).x = ...
                    merged_rot_data(ii).lines(2*mm).right.x;
                merged_direction_data(ii).dir(mm).lines(2).y = ...
                    merged_rot_data(ii).lines(2*mm).right.y;
                
                % 3rd line
                merged_direction_data(ii).dir(mm).lines(3).x = [];
                merged_direction_data(ii).dir(mm).lines(3).y = [];
            end
        end
    end
end


%% plot data
% merged_direction_data = struct('dir', ...
%     struct('lines', struct('x', [], 'y', [])));
color = ['r', 'g', 'b'];
closest_ind = struct('dir', struct('index', 0));
num_of_lines = 3;
for ii = 1:num_of_Tcrossing
    for mm = 1:num_of_directions
        for nn = 1:num_of_lines
            if ~isempty(merged_direction_data(ii).dir(mm).lines(nn).x)
                rot_line = rotateLine(...
                    merged_direction_data(ii).dir(mm).lines(nn), ...
                    rot_angle(ii, mm));
                
                % find closest point on line
                num_of_pnts = length(rot_line.x);
                tmp_ones = ones(num_of_pnts, 2);
                tmp_ones(:, 1) = tmp_ones(:, 1) * ref_cfg_pnts(ii).x(1);
                tmp_ones(:, 2) = tmp_ones(:, 2) * ref_cfg_pnts(ii).y(1);
                
                tmp_dist = [tmp_ones(:, 1) - rot_line.x, ...
                    tmp_ones(:, 2) - rot_line.y];
                tmp_dist = tmp_dist .* tmp_dist;
                dist = tmp_dist(:, 1) + tmp_dist(:, 2);
                [~, minind] = min(dist);
                
                closest_ind(ii).dir(mm).index(nn) = minind;
                
                figure(1000);
                plot(rot_line.x, rot_line.y, color(mm), ...
                    rot_line.x(minind), rot_line.y(minind), 'go');
                hold on; axis equal;
                title('Closest center point');
                
                pause(0.1);
            end
        end
    end
end
figure(1000); hold off;


%% find nearest point to center point
% closest_ind = struct('dir', struct('index', 0));
% merged_direction_data = struct('dir', ...
%     struct('lines', struct('x', [], 'y', [])));
seg_dir_data = struct('dir', ...
    struct('lines', struct('x', [], 'y', [])));
part = [1, 2; 1, 3; 2, 3];
for ii = 1:num_of_Tcrossing
    lind = ones(num_of_directions, 1);
    for mm = 1:num_of_directions
        for nn = 1:num_of_lines
            if ~isempty(merged_direction_data(ii).dir(mm).lines(nn).x)
                % first part
                index = closest_ind(ii).dir(mm).index(nn);
                seg_dir_data(ii).dir(part(mm, 1)).lines(lind(part(mm, 1))).x = ...
                    merged_direction_data(ii).dir(mm).lines(nn).x(1:index);
                seg_dir_data(ii).dir(part(mm, 1)).lines(lind(part(mm, 1))).y = ...
                    merged_direction_data(ii).dir(mm).lines(nn).y(1:index);
                lind(part(mm, 1)) = lind(part(mm, 1)) + 1;
                
                % second part
                seg_dir_data(ii).dir(part(mm, 2)).lines(lind(part(mm, 2))).x = ...
                    merged_direction_data(ii).dir(mm).lines(nn).x(index:end);
                seg_dir_data(ii).dir(part(mm, 2)).lines(lind(part(mm, 2))).y = ...
                    merged_direction_data(ii).dir(mm).lines(nn).y(index:end);
                lind(part(mm, 2)) = lind(part(mm, 2)) + 1;
            else
                % first part
                seg_dir_data(ii).dir(part(mm, 1)).lines(lind(part(mm, 1))).x = ...
                    [];
                seg_dir_data(ii).dir(part(mm, 1)).lines(lind(part(mm, 1))).y = ...
                    [];
                lind(part(mm, 1)) = lind(part(mm, 1)) + 1;
                
                % second part
                seg_dir_data(ii).dir(part(mm, 2)).lines(lind(part(mm, 2))).x = ...
                    [];
                seg_dir_data(ii).dir(part(mm, 2)).lines(lind(part(mm, 2))).y = ...
                    [];
                lind(part(mm, 2)) = lind(part(mm, 2)) + 1;
            end
        end
    end
end


%% plot sub-direction data
color = ['r', 'g', 'b', 'r', 'g', 'b'];
back_seg_dir_data = struct('dir', ...
    struct('lines', struct('x', [], 'y', [])));
for ii = 1:num_of_Tcrossing
    for mm = 1:num_of_directions
        num_of_seg_lines = length(seg_dir_data(ii).dir(mm).lines);
        for nn = 1:num_of_seg_lines
            if ~isempty(seg_dir_data(ii).dir(mm).lines(nn).x)
                
                rot_line = rotateLine(seg_dir_data(ii).dir(mm).lines(nn), ...
                    rot_angle(ii, part(mm, floor((nn + 2) / 3))));
                
                back_seg_dir_data(ii).dir(mm).lines(nn) = rot_line;
                
                figure(1000);
                plot(rot_line.x, rot_line.y, color(nn));
                hold on; axis equal;
                title(['Tcrossing ' num2str(ii) ' direction ' num2str(mm)]);
                
                pause(0.1);
            else
                back_seg_dir_data(ii).dir(mm).lines(nn).x = [];
                back_seg_dir_data(ii).dir(mm).lines(nn).y = [];
            end
        end
    end
end

figure(1000); hold off;


%% merge each sub-direction data
% back_seg_dir_data = struct('dir', ...
%     struct('lines', struct('x', [], 'y', [])));
rot_seg_dir_data = struct('dir', ...
    struct('lines', struct('x', [], 'y', [])));
merged_seg_dir_data = struct('dir', ...
    struct('lines', struct('x', [], 'y', [])));
merged_rot_seg_dir_data = struct('dir', ...
    struct('lines', struct('x', [], 'y', [])));
shift_dist = struct('dir', ...
    struct('d', struct('y', [])));

ind = [4, 5, 6; 6, 5, 4; 4, 5, 6];
for ii = 1:num_of_Tcrossing
    for mm = 1:num_of_directions
        num_of_seg_lines = length(back_seg_dir_data(ii).dir(mm).lines);
        minx_maxx = ones(num_of_seg_lines, 2);
        minx_maxx(:, 1) = minx_maxx(:, 1) * (-Inf);
        minx_maxx(:, 2) = minx_maxx(:, 2) * Inf;
        for nn = 1:num_of_seg_lines
            if ~isempty(back_seg_dir_data(ii).dir(mm).lines(nn).x)
                rot_seg_dir_data(ii).dir(mm).lines(nn) = rotateLine( ...
                    back_seg_dir_data(ii).dir(mm).lines(nn), ...
                    -part_rot_angle(ii, mm));
                
                figure(1000); subplot(211);
                plot(back_seg_dir_data(ii).dir(mm).lines(nn).x, ...
                    back_seg_dir_data(ii).dir(mm).lines(nn).y, color(nn));
                hold on; axis equal;
                title(['Rotated back data of Tcrossing ' ...
                    num2str(ii) ' direction ' num2str(mm)]);
                
                figure(1000); subplot(212);
                plot(rot_seg_dir_data(ii).dir(mm).lines(nn).x, ...
                    rot_seg_dir_data(ii).dir(mm).lines(nn).y, color(nn));
                hold on; axis equal;
                title(['Rotated data of Tcrossing ' ...
                    num2str(ii) ' direction ' num2str(mm)]);
                
                
                pause(0.1);
                
                minx_maxx(nn, 1) = min(rot_seg_dir_data(ii).dir(mm).lines(nn).x);
                minx_maxx(nn, 2) = max(rot_seg_dir_data(ii).dir(mm).lines(nn).x);
            else
                rot_seg_dir_data(ii).dir(mm).lines(nn).x = [];
                rot_seg_dir_data(ii).dir(mm).lines(nn).y = [];
            end
        end
        
        figure(1000); subplot(211); hold off;
        
        tmpx = linspace(max(minx_maxx(:, 1)), min(minx_maxx(:, 2)), 500)';
        
        % merge lines
        for nn = 1:num_of_lines
            line1 = rot_seg_dir_data(ii).dir(mm).lines(nn);
            line2 = rot_seg_dir_data(ii).dir(mm).lines(ind(mm, nn));
            if ~isempty(line1.x) && ~isempty(line2.x)
                fit_line1 = fit(line1.x, line1.y, 'poly9');
                tmpy1 = feval(fit_line1, tmpx);
                
                fit_line2 = fit(line2.x, line2.y, 'poly9');
                tmpy2 = feval(fit_line2, tmpx);
                
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).x = tmpx;
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y = ...
                    0.5 * tmpy1 + 0.5 * tmpy2;
                
                shift_dist(ii).dir(mm).d(nn).y = ...
                    merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y - tmpy1;
                shift_dist(ii).dir(mm).d(ind(mm, nn)).y = ...
                    merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y - tmpy2;
                
            elseif ~isempty(line1.x)
                fit_line1 = fit(line1.x, line1.y, 'poly9');
                tmpy1 = feval(fit_line1, tmpx);
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).x = tmpx;
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y = tmpy1;
                
                shift_dist(ii).dir(mm).d(nn).y = zeros(500, 1);
                shift_dist(ii).dir(mm).d(ind(mm, nn)).y = zeros(500, 1);
            elseif ~isempty(line2.x)
                fit_line2 = fit(line2.x, line2.y, 'poly9');
                tmpy2 = feval(fit_line2, tmpx);
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).x = tmpx;
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y = tmpy2;
                
                shift_dist(ii).dir(mm).d(nn).y = zeros(500, 1);
                shift_dist(ii).dir(mm).d(ind(mm, nn)).y = zeros(500, 1);
            else
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).x = [];
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y = [];
                
                shift_dist(ii).dir(mm).d(nn).y = zeros(500, 1);
                shift_dist(ii).dir(mm).d(ind(mm, nn)).y = zeros(500, 1);
            end
        end
        
        % add shift distance to non-matched lines
        for nn = 1:num_of_lines
            line1 = rot_seg_dir_data(ii).dir(mm).lines(nn);
            line2 = rot_seg_dir_data(ii).dir(mm).lines(ind(mm, nn));
            if ~isempty(line1.x) && ~isempty(line2.x)
                continue;
            elseif ~isempty(line1.x)
                d_ind = find([1, 2, 3] ~= nn);
                
                if mean(shift_dist(ii).dir(mm).d(d_ind(1)).y) * ...
                        mean(shift_dist(ii).dir(mm).d(d_ind(2)).y) > 0
                    if nn > d_ind(2)
                        dist = shift_dist(ii).dir(mm).d(d_ind(2)).y;
                    else
                        dist = shift_dist(ii).dir(mm).d(d_ind(1)).y;
                    end
                else
                    dist = shift_dist(ii).dir(mm).d(d_ind(1)).y + ...
                        shift_dist(ii).dir(mm).d(d_ind(2)).y;
                end
                
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y = ...
                    merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y + dist;
            elseif ~isempty(line2.x)
                d_ind = find([1, 2, 3] ~= ind(mm, nn));
                
                if mean(shift_dist(ii).dir(mm).d(d_ind(1)).y) * ...
                        mean(shift_dist(ii).dir(mm).d(d_ind(2)).y) > 0
                    dist = shift_dist(ii).dir(mm).d(d_ind(1)).y - ...
                        shift_dist(ii).dir(mm).d(d_ind(2)).y;
                else
                    dist = shift_dist(ii).dir(mm).d(d_ind(1)).y + ...
                        shift_dist(ii).dir(mm).d(d_ind(2)).y;
                end
                
                merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y = ...
                    merged_rot_seg_dir_data(ii).dir(mm).lines(nn).y + dist;
            else
                continue;
            end
        end
        
        % rotate back
        for nn = 1:num_of_lines
            if ~isempty(merged_rot_seg_dir_data(ii).dir(mm).lines(nn).x)
                line = merged_rot_seg_dir_data(ii).dir(mm).lines(nn);
                
                rot_line = rotateLine(line, part_rot_angle(ii, mm));
                
                merged_seg_dir_data(ii).dir(mm).lines(nn) = rot_line;
                
                figure(1000); subplot(211)
                plot(rot_line.x, rot_line.y, color(nn));
                hold on; axis equal;
                title(['Rotated back merged data of Tcrossing ' ...
                    num2str(ii) ' direction ' num2str(mm)]);
                
                figure(1000); subplot(212)
                plot(line.x, line.y, 'c');
                hold on; axis equal;
                title(['Rotated merge data of Tcrossing ' ...
                    num2str(ii) ' direction ' num2str(mm)]);
                
                pause(0.1);
            end
        end
        figure(1000); subplot(211); hold off;
        figure(1000); subplot(212); hold off;
    end
end


%%
% merged_seg_dir_data = struct('dir', ...
%     struct('lines', struct('x', [], 'y', [])));
clf(figure(1000))
for ii = 1:num_of_Tcrossing
    for mm = 1:num_of_directions
        for nn = 1:num_of_lines
            plot(merged_seg_dir_data(ii).dir(mm).lines(nn).x, ...
                merged_seg_dir_data(ii).dir(mm).lines(nn).y, color(nn), ...
                merged_seg_dir_data(ii).dir(mm).lines(nn).x(1), ...
                merged_seg_dir_data(ii).dir(mm).lines(nn).y(1), '*', ...
                merged_seg_dir_data(ii).dir(mm).lines(nn).x(end), ...
                merged_seg_dir_data(ii).dir(mm).lines(nn).y(end), 'o');
            hold on; axis equal;
            title(['Merged Tcrossing ' ...
                num2str(ii) ' direction ' num2str(mm)]);
            
            pause(0.1);
        end
    end
end

figure(1000); hold off;


%% save to KML
% merged_seg_dir_data = struct('dir', ...
%     struct('lines', struct('x', [], 'y', [])));

standPoint.lat = ref_pnt.y;
standPoint.lon = ref_pnt.x;
standPoint.alt = 0.000000;

COEFF_DD2METER = 111320.0;
PI = 3.1415926536;

fid = fopen('Tcrossing_roadVec.kml', 'w+');
if fid > 0
    % kml file header tags: <xml>, <kml>, <Document>
    fprintf(fid, '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kml>\n<Document>\n');
    
    % tags: <Style>, <StyleMap>
    fprintf(fid, '    <Style id=\"greenLineStyle\"><LineStyle><color>ff00ff00</color></LineStyle></Style>\n');
    fprintf(fid, '    <StyleMap id=\"greenLine\"><Pair><key>normal</key><styleUrl>#greenLineStyle</styleUrl></Pair></StyleMap>\n');
    
    % For each line data
    
    for ii = 1:num_of_Tcrossing
        for mm = 1:num_of_directions
            for nn = 1:num_of_lines
                line = merged_seg_dir_data(ii).dir(mm).lines(nn);
                
                % tags: <Placemark>, <name>
                fprintf(fid, '    <Placemark>\n        <name>Tcrossing-%d-direction-%d-Line-%d</name>\n', ii, mm, nn);
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
    end
end

% End tags
fprintf(fid, '</Document>\n</kml>');

fclose(fid);


%% save data out
% merged_seg_dir_data = struct('dir', ...
%     struct('lines', struct('x', [], 'y', [])));
save('merged_seg_dir_data.mat', 'merged_seg_dir_data');
