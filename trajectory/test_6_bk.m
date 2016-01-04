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
group_data = struct('left', struct('x', 0.0, 'y', 0.0), ...
    'right', struct('x', 0.0, 'y', 0.0));

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

output_group_data = struct('lines', struct('x', 0.0, 'y', 0.0));

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
output_data = struct('lines', struct('x', 0.0, 'y', 0.0));
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
output_data_segs = struct('lines', struct('x', 0.0, 'y', 0.0));
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

out_data_segs_merged = struct('lines', struct('x', 0.0, 'y', 0.0));
% suppose there is tree lines
% AO direction
theta_AO = atan2(cfg_pnts(1, 2) - cfg_pnts(2, 2), cfg_pnts(1, 1) - cfg_pnts(2, 1));
if ~isempty(output_data_segs(1).lines(1).x) && ...
        ~isempty(output_data_segs(1).lines(4).x)
    
    line1 = rotateLine(output_data_segs(1).lines(1), -theta_AO);
    line2 = rotateLine(output_data_segs(1).lines(4), -theta_AO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(1).lines(1) = rotateLine(linein, theta_AO);
else
    if ~isempty(output_data_segs(1).lines(1).x)
        out_data_segs_merged(1).lines(1) = output_data_segs(1).lines(1);
    else
        out_data_segs_merged(1).lines(1) = output_data_segs(1).lines(4);
    end
    
end

if ~isempty(output_data_segs(1).lines(2).x) && ...
        ~isempty(output_data_segs(1).lines(5).x)
    
    line1 = rotateLine(output_data_segs(1).lines(2), -theta_AO);
    line2 = rotateLine(output_data_segs(1).lines(5), -theta_AO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(1).lines(2) = rotateLine(linein, theta_AO);
else
    if ~isempty(output_data_segs(1).lines(2).x)
        out_data_segs_merged(1).lines(2) = output_data_segs(1).lines(2);
    else
        out_data_segs_merged(1).lines(2) = output_data_segs(1).lines(5);
    end
    
end

if ~isempty(output_data_segs(1).lines(3).x) && ...
        ~isempty(output_data_segs(1).lines(6).x)
    
    line1 = rotateLine(output_data_segs(1).lines(3), -theta_AO);
    line2 = rotateLine(output_data_segs(1).lines(6), -theta_AO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(1).lines(3) = rotateLine(linein, theta_AO);
else
    if ~isempty(output_data_segs(1).lines(3).x)
        out_data_segs_merged(1).lines(3) = output_data_segs(1).lines(3);
    else
        out_data_segs_merged(1).lines(3) = output_data_segs(1).lines(6);
    end
    
end

% BO direction
theta_BO = atan2(cfg_pnts(1, 2) - cfg_pnts(3, 2), cfg_pnts(1, 1) - cfg_pnts(3, 1));
if ~isempty(output_data_segs(2).lines(1).x) && ...
        ~isempty(output_data_segs(2).lines(6).x)
    
    line1 = rotateLine(output_data_segs(2).lines(1), -theta_BO);
    line2 = rotateLine(output_data_segs(2).lines(6), -theta_BO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(2).lines(1) = rotateLine(linein, theta_BO);
else
    if ~isempty(output_data_segs(2).lines(1).x)
        out_data_segs_merged(2).lines(1) = output_data_segs(2).lines(1);
    else
        out_data_segs_merged(2).lines(1) = output_data_segs(2).lines(6);
    end
    
end

if ~isempty(output_data_segs(2).lines(2).x) && ...
        ~isempty(output_data_segs(2).lines(5).x)
    
    line1 = rotateLine(output_data_segs(2).lines(2), -theta_BO);
    line2 = rotateLine(output_data_segs(2).lines(5), -theta_BO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(2).lines(2) = rotateLine(linein, theta_BO);
else
    if ~isempty(output_data_segs(2).lines(2).x)
        out_data_segs_merged(2).lines(2) = output_data_segs(2).lines(2);
    else
        out_data_segs_merged(2).lines(2) = output_data_segs(2).lines(5);
    end
    
end

if ~isempty(output_data_segs(2).lines(3).x) && ...
        ~isempty(output_data_segs(2).lines(4).x)
    
    line1 = rotateLine(output_data_segs(2).lines(3), -theta_BO);
    line2 = rotateLine(output_data_segs(2).lines(4), -theta_BO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(2).lines(3) = rotateLine(linein, theta_BO);
else
    if ~isempty(output_data_segs(2).lines(3).x)
        out_data_segs_merged(2).lines(3) = output_data_segs(2).lines(3);
    else
        out_data_segs_merged(2).lines(3) = output_data_segs(2).lines(4);
    end
    
end

% CO direction
theta_CO = atan2(cfg_pnts(1, 2) - cfg_pnts(4, 2), cfg_pnts(1, 1) - cfg_pnts(4, 1));
if ~isempty(output_data_segs(3).lines(1).x) && ...
        ~isempty(output_data_segs(3).lines(4).x)
    
    line1 = rotateLine(output_data_segs(3).lines(1), -theta_CO);
    line2 = rotateLine(output_data_segs(3).lines(4), -theta_CO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(3).lines(1) = rotateLine(linein, theta_CO);
else
    if ~isempty(output_data_segs(3).lines(1).x)
        out_data_segs_merged(3).lines(1) = output_data_segs(3).lines(1);
    else
        out_data_segs_merged(3).lines(1) = output_data_segs(3).lines(4);
    end
    
end

if ~isempty(output_data_segs(3).lines(2).x) && ...
        ~isempty(output_data_segs(3).lines(5).x)
    
    line1 = rotateLine(output_data_segs(3).lines(2), -theta_CO);
    line2 = rotateLine(output_data_segs(3).lines(5), -theta_CO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(3).lines(2) = rotateLine(linein, theta_CO);
else
    if ~isempty(output_data_segs(3).lines(2).x)
        out_data_segs_merged(3).lines(2) = output_data_segs(3).lines(2);
    else
        out_data_segs_merged(3).lines(2) = output_data_segs(3).lines(5);
    end
    
end

if ~isempty(output_data_segs(3).lines(3).x) && ...
        ~isempty(output_data_segs(3).lines(6).x)
    
    line1 = rotateLine(output_data_segs(3).lines(3), -theta_CO);
    line2 = rotateLine(output_data_segs(3).lines(6), -theta_CO);
    
    minx = max(min(line1.x), min(line2.x));
    maxx = min(max(line1.x), max(line2.x));
    linein.x = linspace(minx, maxx, 500)';
    
    fitline1 = fit(line1.x, line1.y, 'poly9');
    tmpline1y = feval(fitline1, linein.x);
    fitline2 = fit(line2.x, line2.y, 'poly9');
    tmpline2y = feval(fitline2, linein.x);
    
    linein.y = 0.5 * tmpline1y + 0.5 * tmpline2y;
    
    out_data_segs_merged(3).lines(3) = rotateLine(linein, theta_CO);
else
    if ~isempty(output_data_segs(3).lines(3).x)
        out_data_segs_merged(3).lines(3) = output_data_segs(3).lines(3);
    else
        out_data_segs_merged(3).lines(3) = output_data_segs(3).lines(6);
    end
    
end

color = ['r'; 'g'; 'b'; 'k'; 'm'; 'c'];
for ii = 1:num_of_directions
    num_of_lines = length(out_data_segs_merged(ii).lines);
    for jj = 1:num_of_lines
        if ~isempty(out_data_segs_merged(ii).lines(jj).x)
            
            figure(325)
            plot(out_data_segs_merged(ii).lines(jj).x, ...
                out_data_segs_merged(ii).lines(jj).y, color(jj), ...
                output_data(ii).lines(jj).x, ...
                output_data(ii).lines(jj).y, 'k');
            hold on; axis equal;
        end
    end
end
figure(325)
plot(cfg_pnts(:, 1), cfg_pnts(:, 2), 'g*');
hold off;