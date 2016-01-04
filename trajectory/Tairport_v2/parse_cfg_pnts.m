function parse_cfg_pnts()
% PARSE_CFG_PNTS
%
% read config points in KML files to generate T crossing configurations
%
% O[1-9]+, A[1-9]+, B[1-9]+, C[1-9]+
%

format long

clear variables; clc;

clf(figure(1000))

% how many T crossings
num_of_Tcrossing = 4;

% reference point absolute GPS
ref_pnt.x = 11.76378193414014;
ref_pnt.y = 48.35042162483494;

% cfg point
abs_cfg_pnts = struct('lon', [], 'lat', []);
ref_cfg_pnts = struct('x', [], 'y', []);

% rotation angle and x limits
theta = struct('AB', 0, 'AC', 0, 'BC', 0, 'AO', 0, 'BO', 0, 'CO', 0);
xlimits = struct('AB', struct('minx', 0, 'maxx', 0), ...
    'AC', struct('minx', 0, 'maxx', 0), ...
    'BC', struct('minx', 0, 'maxx', 0));

% read KML files
for ii = 1:num_of_Tcrossing
    O_kml = sprintf('./cfg_kml_pnts/O%d.kml', ii);
    A_kml = sprintf('./cfg_kml_pnts/A%d.kml', ii);
    B_kml = sprintf('./cfg_kml_pnts/B%d.kml', ii);
    C_kml = sprintf('./cfg_kml_pnts/C%d.kml', ii);
    
    if exist(O_kml, 'file') && ...
            exist(A_kml, 'file') && ...
            exist(B_kml, 'file') && ...
            exist(C_kml, 'file')
        
        O_fid = fopen(O_kml, 'r');
        A_fid = fopen(A_kml, 'r');
        B_fid = fopen(B_kml, 'r');
        C_fid = fopen(C_kml, 'r');
        if O_fid > 0 && A_fid > 0 && B_fid > 0 && C_fid > 0
            % center point O
            gps_kml = textscan(O_fid, '%s');  fclose(O_fid);
            cordinates = sscanf(gps_kml{1, 1}{72, 1}, ...
                '<coordinates>%f,%f,%f</coordinates>');
            abs_cfg_pnts(ii).lon(1) = cordinates(1);
            abs_cfg_pnts(ii).lat(1) = cordinates(2);
            
            % end point A
            gps_kml = textscan(A_fid, '%s'); fclose(A_fid);
            cordinates = sscanf(gps_kml{1, 1}{72, 1}, ...
                '<coordinates>%f,%f,%f</coordinates>');
            abs_cfg_pnts(ii).lon(2) = cordinates(1);
            abs_cfg_pnts(ii).lat(2) = cordinates(2);
            
            % end_point B
            gps_kml = textscan(B_fid, '%s'); fclose(B_fid);
            cordinates = sscanf(gps_kml{1, 1}{72, 1}, ...
                '<coordinates>%f,%f,%f</coordinates>');
            abs_cfg_pnts(ii).lon(3) = cordinates(1);
            abs_cfg_pnts(ii).lat(3) = cordinates(2);
            
            % end_point C
            gps_kml = textscan(C_fid, '%s'); fclose(C_fid);
            cordinates = sscanf(gps_kml{1, 1}{72, 1}, ...
                '<coordinates>%f,%f,%f</coordinates>');
            abs_cfg_pnts(ii).lon(4) = cordinates(1);
            abs_cfg_pnts(ii).lat(4) = cordinates(2);
            
            % reference GPS points
            ref_gps = calRefGPS(abs_cfg_pnts(ii), ref_pnt);
            ref_cfg_pnts(ii).x = ref_gps.x;
            ref_cfg_pnts(ii).y = ref_gps.y;
            
            % rotation angle
            theta(ii).AB = atan2(ref_cfg_pnts(ii).y(3) - ref_cfg_pnts(ii).y(2), ...
                ref_cfg_pnts(ii).x(3) - ref_cfg_pnts(ii).x(2));
            theta(ii).AC = atan2(ref_cfg_pnts(ii).y(4) - ref_cfg_pnts(ii).y(2), ...
                ref_cfg_pnts(ii).x(4) - ref_cfg_pnts(ii).x(2));
            theta(ii).BC = atan2(ref_cfg_pnts(ii).y(4) - ref_cfg_pnts(ii).y(3), ...
                ref_cfg_pnts(ii).x(4) - ref_cfg_pnts(ii).x(3));
            theta(ii).AO = atan2(ref_cfg_pnts(ii).y(2) - ref_cfg_pnts(ii).y(1), ...
                ref_cfg_pnts(ii).x(2) - ref_cfg_pnts(ii).x(1));
            theta(ii).BO = atan2(ref_cfg_pnts(ii).y(3) - ref_cfg_pnts(ii).y(1), ...
                ref_cfg_pnts(ii).x(3) - ref_cfg_pnts(ii).x(1));
            theta(ii).CO = atan2(ref_cfg_pnts(ii).y(4) - ref_cfg_pnts(ii).y(1), ...
                ref_cfg_pnts(ii).x(4) - ref_cfg_pnts(ii).x(1));
            
            % x limits
            AB.x = [ref_cfg_pnts(ii).x(2); ref_cfg_pnts(ii).x(3)];
            AB.y = [ref_cfg_pnts(ii).y(2); ref_cfg_pnts(ii).y(3)];
            rot_AB = rotateLine(AB, -theta(ii).AB);
            xlimits(ii).AB.minx = min(rot_AB.x);
            xlimits(ii).AB.maxx = max(rot_AB.x);
            
            AC.x = [ref_cfg_pnts(ii).x(2); ref_cfg_pnts(ii).x(4)];
            AC.y = [ref_cfg_pnts(ii).y(2); ref_cfg_pnts(ii).y(4)];
            rot_AC = rotateLine(AC, -theta(ii).AC);
            xlimits(ii).AC.minx = min(rot_AC.x);
            xlimits(ii).AC.maxx = max(rot_AC.x);
            
            BC.x = [ref_cfg_pnts(ii).x(3); ref_cfg_pnts(ii).x(4)];
            BC.y = [ref_cfg_pnts(ii).y(3); ref_cfg_pnts(ii).y(4)];
            rot_BC = rotateLine(BC, -theta(ii).BC);
            xlimits(ii).BC.minx = min(rot_BC.x);
            xlimits(ii).BC.maxx = max(rot_BC.x);
            
            % plot cfg points
            figure(1000)
            subplot(211)
            plot(abs_cfg_pnts(ii).lon, abs_cfg_pnts(ii).lat, 'g*');
            hold on; axis equal;
            title('Absolute Cfg Points');
            
            figure(1000)
            subplot(212)
            plot(ref_cfg_pnts(ii).x, ref_cfg_pnts(ii).y, 'g*');
            hold on; axis equal;
            title('Reference Cfg Points');
            
            pause(0.1);
        end
    end
end

figure(1000); subplot(211); hold off; subplot(212); hold off;

% save relative data
% num_of_Tcrossing = 4;
% ref_pnt.x = 11.76378193414014;
% ref_pnt.y = 48.35042162483494;
% abs_cfg_pnts = struct('lon', [], 'lat', []);
% ref_cfg_pnts = struct('x', [], 'y', []);
% theta = struct('AB', 0, 'AC', 0, 'BC', 0, 'AO', 0, 'BO', 0, 'CO', 0);
% xlimits = struct('AB', struct('minx', 0, 'maxx', 0), ...
%    'AC', struct('minx', 0, 'maxx', 0), ...
%    'BC', struct('minx', 0, 'maxx', 0));
save('ref_cfg_data.mat', 'ref_pnt', 'abs_cfg_pnts', 'ref_cfg_pnts', ...
    'theta', 'xlimits', 'num_of_Tcrossing');
