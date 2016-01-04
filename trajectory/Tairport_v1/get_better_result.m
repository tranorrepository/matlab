function get_better_result()
% GET_BETTER_RESULT
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

% merged_seg_dir_data = struct('dir', ...
%     struct('lines', struct('x', [], 'y', [])));
load('merged_seg_dir_data.mat');

num_of_directions = 3;
num_of_lines = 3;
color = ['r', 'g', 'b', 'r', 'g', 'b'];

for ii = 1:num_of_Tcrossing
    for mm = 1:num_of_directions
        for nn = 1:num_of_lines
            figure(1000); subplot(211);
            plot(merged_seg_dir_data(ii).dir(mm).lines(nn).x, ...
                merged_seg_dir_data(ii).dir(mm).lines(nn).y, color(nn));
            hold on; axis equal;
            title(['Merged Tcrossing ' ...
                num2str(ii) ' direction ' num2str(mm)]);
            
            pause(0.1);
        end
    end
end

figure(1000); subplot(211); hold off;


%% boundaries groups manually
all_tmp_lines = struct('x', [], 'y', []);
all_output_lines = struct('x', [], 'y', []);

tmp_lines_ind.ind(1) = {[1, 1, 1; 1, 2, 1; 4, 1, 1; 4, 2, 1]};
tmp_lines_ind.ind(2) = {[1, 1, 2; 1, 2, 2; 4, 1, 2; 4, 2, 2]};
tmp_lines_ind.ind(3) = {[2, 1, 3; 2, 2, 3; 3, 1, 3; 3, 2, 3]};
tmp_lines_ind.ind(4) = {[2, 1, 2; 2, 2, 2; 3, 1, 2; 3, 2, 2]};
tmp_lines_ind.ind(5) = {[1, 1, 3; 1, 3, 3]};
tmp_lines_ind.ind(6) = {[2, 1, 1; 2, 3, 1]};
tmp_lines_ind.ind(7) = {[1, 2, 3; 1, 3, 1]};
tmp_lines_ind.ind(8) = {[2, 2, 1; 2, 3, 3]};
tmp_lines_ind.ind(9) = {[3, 1, 1; 3, 3, 1]};
tmp_lines_ind.ind(10) = {[4, 1, 3; 4, 3, 3]};
tmp_lines_ind.ind(11) = {[3, 2, 1; 3, 3, 3]};
tmp_lines_ind.ind(12) = {[4, 2, 3; 4, 3, 1]};
tmp_lines_ind.ind(13) = {[1, 3, 2; 2, 3, 2]};
tmp_lines_ind.ind(14) = {[3, 3, 2; 4, 3, 2]};

num_of_tmp_lines = length(tmp_lines_ind.ind);
for ll = 1:num_of_tmp_lines
    grp_ind = tmp_lines_ind.ind(ll);
    num_of_parts = size(grp_ind{1, 1}, 1);
    
    num_of_added_pnts = 0;
    for pp = 1:num_of_parts
        % number of Tcrossing
        ii = grp_ind{1, 1}(pp, 1);
        mm = grp_ind{1, 1}(pp, 2);
        nn = grp_ind{1, 1}(pp, 3);
        
        num_of_pnts = length(merged_seg_dir_data(ii).dir(mm).lines(nn).x);
        pnt_ind = num_of_added_pnts + 1:num_of_added_pnts + num_of_pnts;
        
        if ll <= (num_of_tmp_lines - 2)
            if mod(pp, 2) == 1
                all_tmp_lines(ll).x(pnt_ind) = ...
                    flip(merged_seg_dir_data(ii).dir(mm).lines(nn).x);
                all_tmp_lines(ll).y(pnt_ind) = ...
                    flip(merged_seg_dir_data(ii).dir(mm).lines(nn).y);
            else
                all_tmp_lines(ll).x(pnt_ind) = ...
                    merged_seg_dir_data(ii).dir(mm).lines(nn).x;
                all_tmp_lines(ll).y(pnt_ind) = ...
                    merged_seg_dir_data(ii).dir(mm).lines(nn).y;
            end
        else
            if mod(pp, 2) == 0
                all_tmp_lines(ll).x(pnt_ind) = ...
                    flip(merged_seg_dir_data(ii).dir(mm).lines(nn).x);
                all_tmp_lines(ll).y(pnt_ind) = ...
                    flip(merged_seg_dir_data(ii).dir(mm).lines(nn).y);
            else
                all_tmp_lines(ll).x(pnt_ind) = ...
                    merged_seg_dir_data(ii).dir(mm).lines(nn).x;
                all_tmp_lines(ll).y(pnt_ind) = ...
                    merged_seg_dir_data(ii).dir(mm).lines(nn).y;
            end
        end
        num_of_added_pnts = num_of_added_pnts + num_of_pnts;
    end
    
    % rotate
    theta = atan2(all_tmp_lines(ll).y(end) - all_tmp_lines(ll).y(1), ...
        all_tmp_lines(ll).x(end) - all_tmp_lines(ll).x(1));
    
    rot_line = rotateLine(all_tmp_lines(ll), -theta);
    
    % curve fitting
    minx = min(rot_line.x);
    maxx = max(rot_line.x);
    line.x = minx:0.1:maxx;
    
    fit_line = fit(rot_line.x', rot_line.y', 'poly9');
    line.y = feval(fit_line, line.x)';
    
    all_output_lines(ll) = rotateLine(line, theta);
    
    
    figure(1000); subplot(212);
    plot(all_output_lines(ll).x, all_output_lines(ll).y, ...
        all_output_lines(ll).x(1), all_output_lines(ll).y(1), '*', ...
        all_output_lines(ll).x(end), all_output_lines(ll).y(end), 'o');
    hold on; axis equal;
    title('Output merged Tcrossing');
    
    pause(0.1);
end
figure(1000); subplot(212); hold off;

%% stitch boundaries
ed_ed = [5, 6; 7, 8; 9, 10; 11, 12];

items = size(ed_ed, 1);
for ii = 1:items
    dx = all_output_lines(ed_ed(ii, 2)).x(end) - ...
        all_output_lines(ed_ed(ii, 1)).x(end);
    dy = all_output_lines(ed_ed(ii, 2)).y(end) - ...
        all_output_lines(ed_ed(ii, 1)).y(end);
    
    num_of_pnts = length(all_output_lines(ed_ed(ii, 1)).x);
    ddx = zeros(1, num_of_pnts);
    ddy = zeros(1, num_of_pnts);
    
    ddx(end-199:end) = linspace(0, dx, 200);
    ddy(end-199:end) = linspace(0, dy, 200);
    
    figure(1000); subplot(211);
    plot(all_output_lines(ed_ed(ii, 1)).x, ...
        all_output_lines(ed_ed(ii, 1)).y, ...
        all_output_lines(ed_ed(ii, 2)).x, ...
        all_output_lines(ed_ed(ii, 2)).y);
    hold on; axis equal;
    
    all_output_lines(ed_ed(ii, 1)).x = ...
        all_output_lines(ed_ed(ii, 1)).x + ddx;
    all_output_lines(ed_ed(ii, 1)).y = ...
        all_output_lines(ed_ed(ii, 1)).y + ddy;
    
    figure(1000); subplot(211);
    plot(all_output_lines(ed_ed(ii, 1)).x, ...
        all_output_lines(ed_ed(ii, 1)).y, ...
        all_output_lines(ed_ed(ii, 2)).x, ...
        all_output_lines(ed_ed(ii, 2)).y);
    axis equal;
    
    pause(0.1);
end

figure(1000); subplot(211); hold off;

st_st = [8, 9; 7, 10];
items = size(st_st, 1);
for ii = 1:items
    dx = all_output_lines(st_st(ii, 2)).x(1) - ...
        all_output_lines(st_st(ii, 1)).x(1);
    dy = all_output_lines(st_st(ii, 2)).y(1) - ...
        all_output_lines(st_st(ii, 1)).y(1);
    
    ddx = linspace(dx, 0, 200);
    ddy = linspace(dy, 0, 200);
    
    figure(1000); subplot(211);
    plot(all_output_lines(st_st(ii, 1)).x, ...
        all_output_lines(st_st(ii, 1)).y, ...
        all_output_lines(st_st(ii, 2)).x, ...
        all_output_lines(st_st(ii, 2)).y);
    hold on; axis equal;
    
    all_output_lines(st_st(ii, 1)).x(1:200) = ...
        all_output_lines(st_st(ii, 1)).x(1:200) + ddx;
    all_output_lines(st_st(ii, 1)).y(1:200) = ...
        all_output_lines(st_st(ii, 1)).y(1:200) + ddy;
    
    figure(1000); subplot(211);
    plot(all_output_lines(st_st(ii, 1)).x, ...
        all_output_lines(st_st(ii, 1)).y, ...
        all_output_lines(st_st(ii, 2)).x, ...
        all_output_lines(st_st(ii, 2)).y);
    axis equal;
    
    pause(0.1);
end


%% plot result
clf(figure(1000))
num_of_output_lines = length(all_output_lines);
for ll = 1:num_of_output_lines
    figure(1000)
    plot(all_output_lines(ll).x, all_output_lines(ll).y);
    hold on; axis equal;
    title('Output merged Tcrossing');
    
    pause(0.1);
end


%% save KML file
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
    
    for ll = 1:num_of_output_lines
        line = all_output_lines(ll);
        
        % tags: <Placemark>, <name>
        fprintf(fid, '    <Placemark>\n        <name>Line-%d</name>\n', ll);
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

% End tags
fprintf(fid, '</Document>\n</kml>');

fclose(fid);
