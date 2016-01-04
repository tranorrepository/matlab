function get_segment_gps_data()
% GET_SEGMENT_GPS_DATA
%
% extract valid GPS track to small segmentations
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

% valid_gps_track_data = struct('x', [], 'y', []);
load('valid_gps_data.mat');


% center cfg points
center_cfg_pnts = zeros(num_of_Tcrossing, 2);
for ii = 1:num_of_Tcrossing
    center_cfg_pnts(ii, :) = [ref_cfg_pnts(ii).x(1), ref_cfg_pnts(ii).y(1)];
    
    figure(1000); subplot(211)
    plot(ref_cfg_pnts(ii).x, ref_cfg_pnts(ii).y, 'g*');
    hold on; axis equal;
end


%% iterate each valid GPS tracks to get segment data
gps_seg_group_data = struct('group', struct('x', [], 'y', []));

num_of_valid_gps_tracks = length(valid_gps_track_data);

grp_ind = zeros(num_of_Tcrossing, 1);

for ii = 1:num_of_valid_gps_tracks
    grp_ind = grp_ind + ones(num_of_Tcrossing, 1);
    
    pnt_ind = zeros(num_of_Tcrossing, 1);
    pre_valid_jj = zeros(num_of_Tcrossing, 1);
    
    num_of_pnts = length(valid_gps_track_data(ii).x);
    for jj = 1:num_of_pnts
        tmp_ones = ones(num_of_Tcrossing, 2);
        tmp_ones(:, 1) = tmp_ones(:, 1) * valid_gps_track_data(ii).x(jj);
        tmp_ones(:, 2) = tmp_ones(:, 2) * valid_gps_track_data(ii).y(jj);
        
        tmp_dist = tmp_ones - center_cfg_pnts;
        tmp_dist = tmp_dist .* tmp_dist;
        dist = tmp_dist(:, 1) + tmp_dist(:, 2);
        [~, min_ind] = min(dist);
        
        if pre_valid_jj(min_ind) ~= 0 && (jj - pre_valid_jj(min_ind)) > 2
            pre_valid_jj(min_ind) = 0;
            grp_ind(min_ind) = grp_ind(min_ind) + 1;
            pnt_ind(min_ind) = 1;
        else
            pre_valid_jj(min_ind) = jj;
            pnt_ind(min_ind) = pnt_ind(min_ind) + 1;
        end
        
        gps_seg_group_data(min_ind).group(grp_ind(min_ind)).x(pnt_ind(min_ind)) = ...
            valid_gps_track_data(ii).x(jj);
        gps_seg_group_data(min_ind).group(grp_ind(min_ind)).y(pnt_ind(min_ind)) = ...
            valid_gps_track_data(ii).y(jj);
    end
    
    figure(1000); subplot(211)
    plot(valid_gps_track_data(ii).x, valid_gps_track_data(ii).y);
    pause(0.1);
end

figure(1000); subplot(211); hold off;


%% put segmented data to correct directions

num_of_db_groups = 6;
gps_seg_data = struct('AB', struct('x', [], 'y', []), ...
    'BA', struct('x', [], 'y', []), ...
    'AC', struct('x', [], 'y', []), ...
    'CA', struct('x', [], 'y', []), ...
    'BC', struct('x', [], 'y', []), ...
    'CB', struct('x', [], 'y', []));

% AB, BA, AC, CA, BC, CB
dir_ind = ones(num_of_Tcrossing, num_of_db_groups);

for ii = 1:num_of_Tcrossing
    % ii-th center configuration points
    cfg_pnts = [ref_cfg_pnts(ii).x, ref_cfg_pnts(ii).y];
    
    num_of_seg_groups = length(gps_seg_group_data(ii).group);
    for jj = 1:num_of_seg_groups
        if ~isempty(gps_seg_group_data(ii).group(jj).x)
            group_data.x = gps_seg_group_data(ii).group(jj).x;
            group_data.y = gps_seg_group_data(ii).group(jj).y;            
            
            for nn = 1:num_of_Tcrossing
                figure(1000); subplot(212)
                plot(ref_cfg_pnts(nn).x, ref_cfg_pnts(nn).y, 'g*');
                hold on; axis equal;
            end
            
            figure(1000); subplot(212);
            plot(group_data.x, ...
                group_data.y);
            figure(1000); subplot(212); hold off;
            
            pause(0.1);
            
            % minimum distance to end points
            num_of_pnts = length(group_data.x);
            tmp_ones = ones(num_of_pnts, 6);
            tmp_ones(:, 1) = tmp_ones(:, 1) * cfg_pnts(2, 1);
            tmp_ones(:, 2) = tmp_ones(:, 2) * cfg_pnts(2, 2);
            tmp_ones(:, 3) = tmp_ones(:, 3) * cfg_pnts(3, 1);
            tmp_ones(:, 4) = tmp_ones(:, 4) * cfg_pnts(3, 2);
            tmp_ones(:, 5) = tmp_ones(:, 5) * cfg_pnts(4, 1);
            tmp_ones(:, 6) = tmp_ones(:, 6) * cfg_pnts(4, 2);
            
            tmp_data = zeros(num_of_pnts, 6);
            tmp_data(:, 1) = group_data.x;
            tmp_data(:, 2) = group_data.y;
            tmp_data(:, 3) = group_data.x;
            tmp_data(:, 4) = group_data.y;
            tmp_data(:, 5) = group_data.x;
            tmp_data(:, 6) = group_data.y;
            
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
                
                if min(other_dist) <= 225
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
                    if st_ind == 1 && other_ind == 2
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 1) = dir_ind(ii, 1) + 1;
                        
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 2) = dir_ind(ii, 2) + 1;
                    elseif st_ind == 1 && other_ind == 3
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 3) = dir_ind(ii, 3) + 1;
                        
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 4) = dir_ind(ii, 4) + 1;
                    elseif st_ind == 2 && other_ind == 1
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 2) = dir_ind(ii, 2) + 1;
                        
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 1) = dir_ind(ii, 1) + 1;
                    elseif st_ind == 2 && other_ind == 3
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 5) = dir_ind(ii, 5) + 1;
                        
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 6) = dir_ind(ii, 6) + 1;
                    elseif st_ind == 3 && other_ind == 1
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 4) = dir_ind(ii, 4) + 1;
                        
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 3) = dir_ind(ii, 3) + 1;
                    elseif st_ind == 3 && other_ind == 2
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).y = group_data.y(1:min_other_ind);
                        dir_ind(6) = dir_ind(6) + 1;
                        
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 5) = dir_ind(ii, 5) + 1;
                    end
                end
            else
                if st_ind == 1 && ed_ind == 2 % AB
                    if has_two_parts == 1
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 3) = dir_ind(ii, 3) + 1;
                        
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 6) = dir_ind(ii, 6) + 1;
                    else
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).x = group_data.x;
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).y = group_data.y;
                        dir_ind(ii, 1) = dir_ind(ii, 1) + 1;
                    end
                elseif st_ind == 2 && ed_ind == 1 % BA
                    if has_two_parts == 1
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 5) = dir_ind(ii, 5) + 1;
                        
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 4) = dir_ind(ii, 4) + 1;
                    else
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).x = group_data.x;
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).y = group_data.y;
                        dir_ind(ii, 2) = dir_ind(ii, 2) + 1;
                    end
                elseif st_ind == 1 && ed_ind == 3 % AC
                    if has_two_parts == 1
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 1) = dir_ind(ii, 1) + 1;
                        
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 5) = dir_ind(ii, 5) + 1;
                    else
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).x = group_data.x;
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).y = group_data.y;
                        dir_ind(ii, 3) = dir_ind(ii, 3) + 1;
                    end
                elseif st_ind == 3 && ed_ind == 1 % CA
                    if has_two_parts == 1
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 6) = dir_ind(ii, 6) + 1;
                        
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 2) = dir_ind(ii, 2) + 1;
                    else
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).x = group_data.x;
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).y = group_data.y;
                        dir_ind(ii, 4) = dir_ind(ii, 4) + 1;
                    end
                elseif st_ind == 2 && ed_ind == 3 % BC
                    if has_two_parts == 1
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).BA(dir_ind(ii, 2)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 2) = dir_ind(ii, 2) + 1;
                        
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).AC(dir_ind(ii, 3)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 3) = dir_ind(ii, 3) + 1;
                    else
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).x = group_data.x;
                        gps_seg_data(ii).BC(dir_ind(ii, 5)).y = group_data.y;
                        dir_ind(ii, 5) = dir_ind(ii, 5) + 1;
                    end
                elseif st_ind == 3 && ed_ind == 2 % CB
                    if has_two_parts == 1
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).x = group_data.x(1:min_other_ind);
                        gps_seg_data(ii).CA(dir_ind(ii, 4)).y = group_data.y(1:min_other_ind);
                        dir_ind(ii, 4) = dir_ind(ii, 4) + 1;
                        
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).x = group_data.x(min_other_ind:end);
                        gps_seg_data(ii).AB(dir_ind(ii, 1)).y = group_data.y(min_other_ind:end);
                        dir_ind(ii, 1) = dir_ind(ii, 1) + 1;
                    else
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).x = group_data.x;
                        gps_seg_data(ii).CB(dir_ind(ii, 6)).y = group_data.y;
                        dir_ind(ii, 6) = dir_ind(ii, 6) + 1;
                    end
                end
            end
        end
    end
end

figure(1000); subplot(212); hold off;


%% plot each direction separately
t_center_color = ['r*'; 'g*'; 'b*'; 'c*'; 'm*';];
color = ['r'; 'g'; 'b'; 'k'; 'm'; 'c';];
for ii = 1:num_of_Tcrossing
    
    for nn = 1:num_of_Tcrossing
        figure(1000); subplot(212)
        plot(ref_cfg_pnts(nn).x, ref_cfg_pnts(nn).y, t_center_color(nn, :));
        hold on; axis equal;
    end
    
    num_of_AB_segs = length(gps_seg_data(ii).AB);
    for jj = 1:num_of_AB_segs
        figure(1000); subplot(212);
        plot(gps_seg_data(ii).AB(jj).x, gps_seg_data(ii).AB(jj).y, color(1));
        hold on;
        axis equal;
        pause(0.1);
    end
    
    num_of_BA_segs = length(gps_seg_data(ii).BA);
    for jj = 1:num_of_BA_segs
        figure(1000); subplot(212);
        plot(gps_seg_data(ii).BA(jj).x, gps_seg_data(ii).BA(jj).y, color(2));
        hold on;
        axis equal;
        pause(0.1);
    end
    
    num_of_AC_segs = length(gps_seg_data(ii).AC);
    for jj = 1:num_of_AC_segs
        figure(1000); subplot(212);
        plot(gps_seg_data(ii).AC(jj).x, gps_seg_data(ii).AC(jj).y, color(3));
        hold on;
        axis equal;
        pause(0.1);
    end
    
    num_of_CA_segs = length(gps_seg_data(ii).CA);
    for jj = 1:num_of_CA_segs
        figure(1000); subplot(212);
        plot(gps_seg_data(ii).CA(jj).x, gps_seg_data(ii).CA(jj).y, color(4));
        hold on;
        axis equal;
        pause(0.1);
    end
    
    num_of_BC_segs = length(gps_seg_data(ii).BC);
    for jj = 1:num_of_BC_segs
        figure(1000); subplot(212);
        plot(gps_seg_data(ii).BC(jj).x, gps_seg_data(ii).BC(jj).y, color(5));
        hold on;
        axis equal;
        pause(0.1);
    end
    
    num_of_CB_segs = length(gps_seg_data(ii).CB);
    for jj = 1:num_of_CB_segs
        figure(1000); subplot(212);
        plot(gps_seg_data(ii).CB(jj).x, gps_seg_data(ii).CB(jj).y, color(6));
        hold on;
        axis equal;
        pause(0.1);
    end
    
%     figure(1000); subplot(212); hold off;
    pause(0.1);
end

% save out gps_seg_data
% num_of_db_groups = 6;
% gps_seg_data = struct('AB', struct('x', [], 'y', []), ...
%     'BA', struct('x', [], 'y', []), ...
%     'AC', struct('x', [], 'y', []), ...
%     'CA', struct('x', [], 'y', []), ...
%     'BC', struct('x', [], 'y', []), ...
%     'CB', struct('x', [], 'y', []));
save('gps_seg_data.mat', 'num_of_db_groups', 'gps_seg_data');