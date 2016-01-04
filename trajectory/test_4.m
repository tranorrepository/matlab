% TEST_4.m
% construct valid data
%
%

clear variables; clc

clf(figure(326))

%% load GPS track data and road lane data
% CFG_SQR_DIST
% num_of_groups
% ref_cfg_pnts         % .x | .y
                       % 4 points O A B C
% ref_pnt              % .x | .y
% source_data_*        % .left | .right
                       % .x | .y for a point
% source_gps_data_*    % .x | .y
load('gps_data.mat');

num_of_cfg_pnts = length(ref_cfg_pnts.x);
cfg_pnts(:, 1) = ref_cfg_pnts.x;
cfg_pnts(:, 2) = ref_cfg_pnts.y;


%% assign nearest point flag for each reported GPS track


for gid = 1:num_of_groups
    eval(['data = source_gps_data_' num2str(gid) ';']);
    num_of_pnts = size(data.x, 1);
    pnts_min_index = zeros(num_of_pnts, 1);
    
    index = 1;
    valid = [];
    valid_data = [];
    
    for ii = 1:num_of_pnts
        tmp_ones = ones(num_of_cfg_pnts, 2);
        tmp_ones(:, 1) = tmp_ones(:, 1) * data.x(ii);
        tmp_ones(:, 2) = tmp_ones(:, 2) * data.y(ii);
        
        tmp_dist = tmp_ones - cfg_pnts;
        tmp_dist = tmp_dist .* tmp_dist;
        dist = tmp_dist(:, 1) + tmp_dist(:, 2);
        [min_dist, min_ind] = min(dist);
        pnts_min_index(ii) = min_ind;
        
        % valid points
        if (min_ind ~= 1 && (min_dist <= 144 || ...
                (sign(data.x(ii) - ref_cfg_pnts.x(min_ind))) * ...
                sign(data.x(ii) - ref_cfg_pnts.x(1)) < 0 ) ...
                ) ||  (min_ind == 1)
            valid_data.x(index) = data.x(ii);
            valid_data.y(index) = data.y(ii);
            valid.index(index) = ii;
            
            index = index + 1;
        end
        
        %
    end
    
    
    eval(['valid_data_' num2str(gid) '.left.x = source_data_' num2str(gid) '.left.x(valid.index);']);
    eval(['valid_data_' num2str(gid) '.left.y = source_data_' num2str(gid) '.left.y(valid.index);']);
    eval(['valid_data_' num2str(gid) '.right.x = source_data_' num2str(gid) '.right.x(valid.index);']);
    eval(['valid_data_' num2str(gid) '.right.y = source_data_' num2str(gid) '.right.y(valid.index);']);
    eval(['valid_data_' num2str(gid) '.gps.x = valid_data.x;']);
    eval(['valid_data_' num2str(gid) '.gps.y = valid_data.y;']);
    
    figure(326)
%     plot(ref_cfg_pnts.x, ref_cfg_pnts.y, 'g*', ...
%         data.x(pnts_min_index == 1), data.y(pnts_min_index == 1), 'r', ...
%         data.x(pnts_min_index == 2), data.y(pnts_min_index == 2), 'b', ...
%         data.x(pnts_min_index == 3), data.y(pnts_min_index == 3), 'c', ...
%         data.x(pnts_min_index == 4), data.y(pnts_min_index == 4), 'm'...
%         ); axis equal;
    
    %

    plot(ref_cfg_pnts.x, ref_cfg_pnts.y, 'g*', ...
        data.x, data.y, 'k', valid_data.x, valid_data.y, 'g.' ...
        ); axis equal;
    
    
    pause(0.1);
end


