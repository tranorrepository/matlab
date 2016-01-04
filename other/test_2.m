function test_2()
% TEST_2
%
%

clear variables; clc;

clf(figure(200))

folder_str = 'C:/Users/Ming.Chen/Desktop/results/12_11_0/';
src_str = [folder_str 'fg_%d_source.txt'];
seg_str = [folder_str 'fg_%d_sec_%d_group_0_lane_0.txt'];
hdl_str = [folder_str 'fg_%d_source_handled.txt'];

for fgId = 48:1284
    hdl_file = sprintf(hdl_str, fgId);
    src_file = sprintf(src_str, fgId);
    if exist(hdl_file, 'file')
        
        % handled data and gps track
        [hdl_left, hdl_right, gps_track.x] = get_lines(hdl_file, 1);
        
        % source data
        [src_left, src_right, ~] = get_lines(src_file);
        
        figure(200);
        plot(src_left.x, 2.5*src_left.y, 'k.', ...
            src_right.x, 2.5*src_right.y, 'k.',...
            src_left.x(src_left.p==0), 2.5*src_left.y(src_left.p==0), 'g.', ...
            src_right.x(src_right.p==0), 2.5*src_right.y(src_right.p==0), 'g.', ...
            src_left.x(src_left.p>0), 2.5*src_left.y(src_left.p>0), 'r.', ...
            src_right.x(src_right.p>0), 2.5*src_right.y(src_right.p>0), 'b.');
        hold on; axis equal;
        title(['Source and handled data ' num2str(fgId)]);
        
        
        plot(hdl_left.x+50, 2.5*hdl_left.y+50, 'k.', ...
            hdl_right.x+50, 2.5*hdl_right.y+50, 'k.', ...
            hdl_left.x(hdl_left.p==0)+50, 2.5*hdl_left.y(hdl_left.p==0)+50, 'g.', ...
            hdl_right.x(hdl_right.p==0)+50, 2.5*hdl_right.y(hdl_right.p==0)+50, 'g.', ...
            hdl_left.x(hdl_left.p>0)+50, 2.5*hdl_left.y(hdl_left.p>0)+50, 'm.', ...
            hdl_right.x(hdl_right.p>0)+50, 2.5*hdl_right.y(hdl_right.p>0)+50, 'c.');
        
        pause(0.1);
        
        figure(200); hold off;
    end
end