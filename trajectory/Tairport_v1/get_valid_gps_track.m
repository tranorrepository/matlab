function get_valid_gps_track()
% GET_VALID_GPS_TRACK
%
% split gps track to small segments according to configuration points
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

% GPS track files
gps_files = [
    'gps_20151125144031';
    'gps_20151125144532';
    'gps_20151125145033';
    'gps_20151125145534';
    'gps_20151125150034';
    'gps_20151125150535';
    'gps_20151125151035';
    'gps_20151125151536';
    'gps_20151125152037';
    ];

% GPS track data of segments
gps_track_data = struct('x', [], 'y', []);


%% iterate each GPS file to get segment data
num_of_gps_files = size(gps_files, 1);
for ii = 1:num_of_gps_files
    gps_path = sprintf('./gps_track_files/%s', gps_files(ii, :));
    if exist(gps_path, 'file')
        % read GPS data
        frid = fopen(gps_path, 'r');
        if frid < 0
            continue;
        end
        
        gps_track = textscan(frid, '%*s %*s %f64 %f64 %f64', 'Delimiter', ',');
        fclose(frid);
        
        gps_data.lat = gps_track{1};
        gps_data.lon = gps_track{2};
        gps_data.alt = gps_track{3};
        
        % calculate reference GPS data
        ref_gps_data = calRefGPS(gps_data, ref_pnt);
        
        % interpolate more points
        index = 1;
        pola_gps_data = struct('x', [], 'y', []);
        num_of_pnts = length(ref_gps_data.x);
        for np = 2:num_of_pnts
            if ref_gps_data.x(np - 1) == ref_gps_data.x(np)
                pola_gps_data.x(index) = ref_gps_data.x(np - 1);
                pola_gps_data.y(index) = ref_gps_data.y(np - 1);
                index = index + 1;
            else
                lon = [ref_gps_data.x(np - 1), ref_gps_data.x(np)];
                lat = [ref_gps_data.y(np - 1), ref_gps_data.y(np)];
                xlon = linspace(ref_gps_data.x(np - 1), ref_gps_data.x(np), 50);
                
                xlat = interp1(lon, lat, xlon, 'linear');
                pola_gps_data.x(index:index+49) = xlon;
                pola_gps_data.y(index:index+49) = xlat;
                
                index = index + 50;
            end
        end
        
        gps_track_data(ii).x = pola_gps_data.x;
        gps_track_data(ii).y = pola_gps_data.y;
        
        figure(1000); subplot(211)
        plot(pola_gps_data.x, pola_gps_data.y);
        hold on; axis equal;
        title('Souce GPS tracks');
        
        pause(0.1);
    end
end

figure(1000); subplot(211);
for ii = 1:num_of_Tcrossing
    plot(ref_cfg_pnts(ii).x, ref_cfg_pnts(ii).y, 'g*');
end
hold off;


%% within 100 meters to T crossing center points
valid_gps_track_data = struct('x', [], 'y', []);
num_of_gps_tracks = length(gps_track_data);

% center cfg points
center_cfg_pnts = zeros(num_of_Tcrossing, 2);
for ii = 1:num_of_Tcrossing
    center_cfg_pnts(ii, :) = [ref_cfg_pnts(ii).x(1), ref_cfg_pnts(ii).y(1)];
end

ii_ind = 0;
for ii = 1:num_of_gps_tracks
    % for new track, add valid index automatically
    ii_ind = ii_ind + 1;
    
    % valid point index
    jj_ind = 0;
    pre_valid_jj = 0;
    
    num_of_pnts = length(gps_track_data(ii).x);
    for jj = 1:num_of_pnts
        tmp_ones = ones(num_of_Tcrossing, 2);
        tmp_ones(:, 1) = tmp_ones(:, 1) * gps_track_data(ii).x(jj);
        tmp_ones(:, 2) = tmp_ones(:, 2) * gps_track_data(ii).y(jj);
        
        tmp_dist = tmp_ones - center_cfg_pnts;
        tmp_dist = tmp_dist .* tmp_dist;
        dist = tmp_dist(:, 1) + tmp_dist(:, 2);
        if min(dist) <= 10000
            if pre_valid_jj ~= 0 && (jj - pre_valid_jj) > 2
                pre_valid_jj = 0;
                ii_ind = ii_ind + 1;
                jj_ind = 1;
            else
                pre_valid_jj = jj;
                jj_ind = jj_ind + 1;
            end
            
            valid_gps_track_data(ii_ind).x(jj_ind) = gps_track_data(ii).x(jj);
            valid_gps_track_data(ii_ind).y(jj_ind) = gps_track_data(ii).y(jj);
        end
    end
end


%% plot and save out data
% plot valid gps tracks
figure(1000); subplot(212);
num_of_valid_gps_tracks = length(valid_gps_track_data);
for ii = 1:num_of_valid_gps_tracks
    plot(valid_gps_track_data(ii).x, valid_gps_track_data(ii).y, '.');
    hold on; axis equal;
    title('Valid GPS tracks within 100 meters to T crossing center')
    pause(0.1);
end

for ii = 1:num_of_Tcrossing
    plot(ref_cfg_pnts(ii).x, ref_cfg_pnts(ii).y, 'g*');
end
hold off;

% save data out
% valid_gps_track_data = struct('x', [], 'y', []);
save('valid_gps_data.mat', 'valid_gps_track_data');