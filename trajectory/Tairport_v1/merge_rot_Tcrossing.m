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

% num_of_db_groups = 6;
% gps_seg_data = struct('AB', struct('x', [], 'y', []), ...
%     'BA', struct('x', [], 'y', []), ...
%     'AC', struct('x', [], 'y', []), ...
%     'CA', struct('x', [], 'y', []), ...
%     'BC', struct('x', [], 'y', []), ...
%     'CB', struct('x', [], 'y', []));
load('gps_seg_data.mat');


%% merge each direction data of T crossing
merged_rot_gps_data = struct('AB', struct('x', [], 'y', []), ...
    'BA', struct('x', [], 'y', []), ...
    'AC', struct('x', [], 'y', []), ...
    'CA', struct('x', [], 'y', []), ...
    'BC', struct('x', [], 'y', []), ...
    'CB', struct('x', [], 'y', []));

num_of_seg_groups = length(gps_seg_data);
for ii = 1:num_of_seg_groups
    merged_rot_gps_data(ii).AB.x = [];
    merged_rot_gps_data(ii).AB.y = [];
    merged_rot_gps_data(ii).BA.x = [];
    merged_rot_gps_data(ii).BA.y = [];
    merged_rot_gps_data(ii).AC.x = [];
    merged_rot_gps_data(ii).AC.y = [];
    merged_rot_gps_data(ii).CA.x = [];
    merged_rot_gps_data(ii).CA.y = [];
    merged_rot_gps_data(ii).BC.x = [];
    merged_rot_gps_data(ii).BC.y = [];
    merged_rot_gps_data(ii).CB.x = [];
    merged_rot_gps_data(ii).CB.y = [];
    
    % AB
    tmpx = linspace(xlimits(ii).AB.minx, xlimits(ii).AB.maxx, 1000)';
    num_of_AB_segs = length(gps_seg_data(ii).AB);
    for jj = 1:num_of_AB_segs
        if ~isempty(gps_seg_data(ii).AB(jj))
            rot_line = rotateLine(gps_seg_data(ii).AB(jj), -theta(ii).AB);
            
            if (min(rot_line.x) - 5) > tmpx(1) || ...
                    (max(rot_line.x) + 5) < tmpx(end)
                fprintf('Tcrossing %d, AB group %d\n', ii, jj);
                continue;
            end
            
            fit_line = fit(rot_line.x', rot_line.y', 'poly9');
            tmpy = feval(fit_line, tmpx);
            
            figure(1000); subplot(211);
            plot(rot_line.x, rot_line.y, 'k', tmpx, tmpy, 'r'); axis equal;
            
            % if db is empty, add directly. otherwise merge it with db
            if isempty(merged_rot_gps_data(ii).AB.x)
                merged_rot_gps_data(ii).AB.x = tmpx;
                merged_rot_gps_data(ii).AB.y = tmpy;
            else
                merged_rot_gps_data(ii).AB.x = tmpx;
                merged_rot_gps_data(ii).AB.y = 0.5 * tmpy + ...
                    0.5 * merged_rot_gps_data(ii).AB.y;
            end
            
            figure(1000); subplot(212);
            plot(merged_rot_gps_data(ii).AB.x, merged_rot_gps_data(ii).AB.y);
            axis equal; title(['Tcrosing ' num2str(ii) ', AB ' num2str(jj)]);
            
            pause(0.1);
        end
    end
    
    % BA
    num_of_BA_segs = length(gps_seg_data(ii).BA);
    for jj = 1:num_of_BA_segs
        if ~isempty(gps_seg_data(ii).BA(jj))
            rot_line = rotateLine(gps_seg_data(ii).BA(jj), -theta(ii).AB);
            
            if (min(rot_line.x) - 5) > tmpx(1) || ...
                    (max(rot_line.x) + 5) < tmpx(end)
                fprintf('Tcrossing %d, BA group %d\n', ii, jj);
                continue;
            end
            
            fit_line = fit(rot_line.x', rot_line.y', 'poly9');
            tmpy = feval(fit_line, tmpx);
            
            figure(1000); subplot(211);
            plot(rot_line.x, rot_line.y, 'k', tmpx, tmpy, 'r'); axis equal;
            
            if isempty(merged_rot_gps_data(ii).BA.x)
                merged_rot_gps_data(ii).BA.x = tmpx;
                merged_rot_gps_data(ii).BA.y = tmpy;
            else
                merged_rot_gps_data(ii).BA.x = tmpx;
                merged_rot_gps_data(ii).BA.y = 0.5 * tmpy + ...
                    0.5 * merged_rot_gps_data(ii).BA.y;
            end
            
            figure(1000); subplot(212);
            plot(merged_rot_gps_data(ii).BA.x, merged_rot_gps_data(ii).BA.y);
            axis equal; title(['Tcrosing ' num2str(ii) ', BA ' num2str(jj)]);
            
            pause(0.1);
        end
    end
    
    % AC
    tmpx = linspace(xlimits(ii).AC.minx, xlimits(ii).AC.maxx, 1000)';
    num_of_AC_segs = length(gps_seg_data(ii).AC);
    for jj = 1:num_of_AC_segs
        if ~isempty(gps_seg_data(ii).AC(jj))
            rot_line = rotateLine(gps_seg_data(ii).AC(jj), -theta(ii).AC);
            
            if (min(rot_line.x) - 5) > tmpx(1) || ...
                    (max(rot_line.x) + 5) < tmpx(end)
                fprintf('Tcrossing %d, AC group %d\n', ii, jj);
                continue;
            end
            
            fit_line = fit(rot_line.x', rot_line.y', 'poly9');
            tmpy = feval(fit_line, tmpx);
            
            figure(1000); subplot(211);
            plot(rot_line.x, rot_line.y, 'k', tmpx, tmpy, 'r'); axis equal;
            
            if isempty(merged_rot_gps_data(ii).AC.x)
                merged_rot_gps_data(ii).AC.x = tmpx;
                merged_rot_gps_data(ii).AC.y = tmpy;
            else
                merged_rot_gps_data(ii).AC.x = tmpx;
                merged_rot_gps_data(ii).AC.y = 0.5 * tmpy + ...
                    0.5 * merged_rot_gps_data(ii).AC.y;
            end
            
            figure(1000); subplot(212);
            plot(merged_rot_gps_data(ii).AC.x, merged_rot_gps_data(ii).AC.y);
            axis equal; title(['Tcrosing ' num2str(ii) ', AC ' num2str(jj)]);
            
            pause(0.1);
        end
    end
    
    % CA
    num_of_CA_segs = length(gps_seg_data(ii).CA);
    for jj = 1:num_of_CA_segs
        if ~isempty(gps_seg_data(ii).CA(jj))
            rot_line = rotateLine(gps_seg_data(ii).CA(jj), -theta(ii).AC);
            
            if (min(rot_line.x) - 5) > tmpx(1) || ...
                    (max(rot_line.x) + 5) < tmpx(end)
                fprintf('Tcrossing %d, CA group %d\n', ii, jj);
                continue;
            end
            
            fit_line = fit(rot_line.x', rot_line.y', 'poly9');
            tmpy = feval(fit_line, tmpx);
            
            figure(1000); subplot(211);
            plot(rot_line.x, rot_line.y, 'k', tmpx, tmpy, 'r'); axis equal;
            
            if isempty(merged_rot_gps_data(ii).CA.x)
                merged_rot_gps_data(ii).CA.x = tmpx;
                merged_rot_gps_data(ii).CA.y = tmpy;
            else
                merged_rot_gps_data(ii).CA.x = tmpx;
                merged_rot_gps_data(ii).CA.y = 0.5 * tmpy + ...
                    0.5 * merged_rot_gps_data(ii).CA.y;
            end
            
            figure(1000); subplot(212);
            plot(merged_rot_gps_data(ii).CA.x, merged_rot_gps_data(ii).CA.y);
            axis equal; title(['Tcrosing ' num2str(ii) ', CA ' num2str(jj)]);
            
            pause(0.1);
        end
    end
    
    % BC
    tmpx = linspace(xlimits(ii).BC.minx, xlimits(ii).BC.maxx, 1000)';
    num_of_BC_segs = length(gps_seg_data(ii).BC);
    for jj = 1:num_of_BC_segs
        if ~isempty(gps_seg_data(ii).BC(jj))
            rot_line = rotateLine(gps_seg_data(ii).BC(jj), -theta(ii).BC);
            
            if (min(rot_line.x) - 5) > tmpx(1) || ...
                    (max(rot_line.x) + 5) < tmpx(end)
                fprintf('Tcrossing %d, BC group %d\n', ii, jj);
                continue;
            end
            
            fit_line = fit(rot_line.x', rot_line.y', 'poly9');
            tmpy = feval(fit_line, tmpx);
            
            figure(1000); subplot(211);
            plot(rot_line.x, rot_line.y, 'k', tmpx, tmpy, 'r'); axis equal;
            
            if isempty(merged_rot_gps_data(ii).BC.x)
                merged_rot_gps_data(ii).BC.x = tmpx;
                merged_rot_gps_data(ii).BC.y = tmpy;
            else
                merged_rot_gps_data(ii).BC.x = tmpx;
                merged_rot_gps_data(ii).BC.y = 0.5 * tmpy + ...
                    0.5 * merged_rot_gps_data(ii).BC.y;
            end
            
            figure(1000); subplot(212);
            plot(merged_rot_gps_data(ii).BC.x, merged_rot_gps_data(ii).BC.y);
            axis equal; title(['Tcrosing ' num2str(ii) ', BC ' num2str(jj)]);
            
            pause(0.1);
        end
    end
    
    % CB
    num_of_CB_segs = length(gps_seg_data(ii).CB);
    for jj = 1:num_of_CB_segs
        if ~isempty(gps_seg_data(ii).CB(jj))
            rot_line = rotateLine(gps_seg_data(ii).CB(jj), -theta(ii).BC);
            
            if (min(rot_line.x) - 5) > tmpx(1) || ...
                    (max(rot_line.x) + 5) < tmpx(end)
                fprintf('Tcrossing %d, CB group %d\n', ii, jj);
                continue;
            end
            
            fit_line = fit(rot_line.x', rot_line.y', 'poly9');
            tmpy = feval(fit_line, tmpx);
            
            figure(1000); subplot(211);
            plot(rot_line.x, rot_line.y, 'k', tmpx, tmpy, 'r'); axis equal;
            
            if isempty(merged_rot_gps_data(ii).CB.x)
                merged_rot_gps_data(ii).CB.x = tmpx;
                merged_rot_gps_data(ii).CB.y = tmpy;
            else
                merged_rot_gps_data(ii).CB.x = tmpx;
                merged_rot_gps_data(ii).CB.y = 0.5 * tmpy + ...
                    0.5 * merged_rot_gps_data(ii).CB.y;
            end
            
            figure(1000); subplot(212);
            plot(merged_rot_gps_data(ii).CB.x, merged_rot_gps_data(ii).CB.y);
            axis equal; title(['Tcrosing ' num2str(ii) ', CB ' num2str(jj)]);
            
            pause(0.1);
        end
    end
    
end

clf(figure(1000))
color = ['r'; 'g'; 'b'; 'k'; 'm'; 'c';];
merged_gps_data = merged_rot_gps_data;
for ii = 1:num_of_Tcrossing
    
    merged_gps_data(ii).AB = rotateLine(merged_rot_gps_data(ii).AB, theta(ii).AB);
    merged_gps_data(ii).BA = rotateLine(merged_rot_gps_data(ii).BA, theta(ii).AB);
    merged_gps_data(ii).AC = rotateLine(merged_rot_gps_data(ii).AC, theta(ii).AC);
    merged_gps_data(ii).CA = rotateLine(merged_rot_gps_data(ii).CA, theta(ii).AC);
    merged_gps_data(ii).BC = rotateLine(merged_rot_gps_data(ii).BC, theta(ii).BC);
    merged_gps_data(ii).CB = rotateLine(merged_rot_gps_data(ii).CB, theta(ii).BC);
    
    figure(1000);
    plot(merged_gps_data(ii).AB.x, merged_gps_data(ii).AB.y, color(1), ...
        merged_gps_data(ii).BA.x, merged_gps_data(ii).BA.y, color(2), ...
        merged_gps_data(ii).AC.x, merged_gps_data(ii).AC.y, color(3), ...
        merged_gps_data(ii).CA.x, merged_gps_data(ii).CA.y, color(4), ...
        merged_gps_data(ii).BC.x, merged_gps_data(ii).BC.y, color(5), ...
        merged_gps_data(ii).CB.x, merged_gps_data(ii).CB.y, color(6)...
        ); hold on; axis equal;
    
    pause(0.1);
end


%% save data
% merged_gps_data = struct('AB', struct('x', [], 'y', []), ...
%     'BA', struct('x', [], 'y', []), ...
%     'AC', struct('x', [], 'y', []), ...
%     'CA', struct('x', [], 'y', []), ...
%     'BC', struct('x', [], 'y', []), ...
%     'CB', struct('x', [], 'y', []));
save('merged_rot_gps_data.mat', 'merged_rot_gps_data');