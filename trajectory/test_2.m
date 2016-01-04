% TEST_2.m
% read GPS file and save GPS track as .mat

clear variables; clc;

% folder_str = ['20151111143352';
% '20151111143852';
% '20151111144353';
% '20151111144853';
% '20151111145354';
% '20151111145854';
% '20151111150340';
% '20151111150841';
% '20151111151343';
% '20151111151654';
% '20151111152155';
% '20151111152656';
% '20151111152810';
% '20151111153311';
% '20151112152019';
% '20151112152520';
% '20151112153021';
% '20151112153521'];
% dir_str = 'C:/Projects/datavideo/samsung_GT-I8190_356507052235334';

% folder_str = [
% %     '20151119030112';
% %     '20151119030611';
% %     '20151119031111';
% %     '20151119031923';
% %     '20151119032422';
%     '20151119032922';
%     '20151119033422';
%     '20151119033922';
% %     '20151119034406';
%     '20151119034905';
%     '20151119035405';
%     '20151119035905';
% %     '20151119040405';
% %     '20151119040905';
% %     '20151119041405';
% %     '20151119041905';
% %     '20151119042405'
%     ];
% dir_str = 'C:/Projects/datavideo/iPhone_6S_20151119';

folder_str = ['20151206175428';
    '20151206181153'];

dir_str = 'C:/Projects/datavideo/iPhone_7C24DF5B-E31D-4127-A5B2-12791D9EB10F';

files_num = size(folder_str, 1);

ROAD_WIDTH = 4;

load('ref_data.mat');

index = 1;

clf(figure(325))
for ii = 1:files_num
%     filename_str = sprintf('%s/cap_%s/gps_%s', dir_str, folder_str(ii, :), folder_str(ii, :));
    filename_str = sprintf('%s/list_%s.txt', dir_str, folder_str(ii, :));
    if exist(filename_str, 'file')
        frid = fopen(filename_str, 'r');
        if frid < 0
            continue;
        end
        
%         gps_track = textscan(frid, '%*s %*s %f64 %f64 %f64', 'Delimiter', ',');
        gps_track = textscan(frid, '%f64 %f64', 'Delimiter', ',');
        fclose(frid);
        
        gps_data.lat = gps_track{1};
        gps_data.lon = gps_track{2};
%         gps_data.alt = gps_track{3};
        
        ref_gps_data = calRefGPS(gps_data, ref_pnt);
        
        points_num = length(ref_gps_data.x);
        
        left.x = zeros(points_num, 1);
        left.y = zeros(points_num, 1);
        right.x = zeros(points_num, 1);
        right.y = zeros(points_num, 1);
        
        % for previous points_num - 1 points
        for jj = 1:points_num - 1
            kk = jj + 1;
            for kk = jj+1 : points_num
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
        
        eval(['source_gps_data_' num2str(index) ' = ref_gps_data;']);
        eval(['source_data_' num2str(index) '.left = left;']);
        eval(['source_data_' num2str(index) '.right = right;']);
        index = index + 1;
        
        figure(325)
%         plot(gps_data.lon, gps_data.lat, 'g'); hold on; axis equal;

        plot(ref_gps_data.x, ref_gps_data.y, 'g', ...
            left.x, left.y, 'r', right.x, right.y, 'b' ...
            ); hold on; axis equal;
        
%         plot(ref_gps_data.x, ref_gps_data.y, 'g'); hold on; axis equal;
%         pause(0.1);
    end
end
hold off;