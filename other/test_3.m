function test_3()
% TEST_3
%
%


clear variables; clc;
clf(figure(200))

folder_str = 'C:/Users/Ming.Chen/Desktop/results/12_10_3/';
source_str = [folder_str 'fg_%d_source.txt'];
track_str = [folder_str 'fg_%d_gps.txt'];
handle_str = [folder_str 'fg_%d_source_handled.txt'];
seg_str = [folder_str 'fg_%d_sec_%d_group_0_lane_0.txt'];

all_segs = 128; % (118:129)';
num_of_segs = length(all_segs);

color = ['b.'; 'r.'; 'g.'];

for fg_id = 9 % 0:49
    src_file = sprintf(source_str, fg_id);
    hdl_file = sprintf(handle_str, fg_id);
    
    src_data = load(src_file);
    hdl_data = load(hdl_file);
    
    num_of_all_src_pnts = size(src_data, 1);
    num_of_src_pnts = floor(num_of_all_src_pnts / 2);
    src_left.x = src_data(1:num_of_src_pnts, 1);
    src_left.y = src_data(1:num_of_src_pnts, 2);
    src_left.p = src_data(1:num_of_src_pnts, 3);
    
    src_right.x = src_data(1+num_of_src_pnts:end, 1);
    src_right.y = src_data(1+num_of_src_pnts:end, 2);
    src_right.p = src_data(1+num_of_src_pnts:end, 3);
    
    num_of_all_hdl_pnts = size(hdl_data, 1);
    num_of_hdl_pnts = floor(num_of_all_hdl_pnts / 3);
    hdl_left.x = hdl_data(1:num_of_hdl_pnts, 1);
    hdl_left.y = hdl_data(1:num_of_hdl_pnts, 2);
    hdl_left.p = hdl_data(1:num_of_hdl_pnts, 3);
    
    hdl_right.x = hdl_data(1+num_of_hdl_pnts:2*num_of_hdl_pnts, 1);
    hdl_right.y = hdl_data(1+num_of_hdl_pnts:2*num_of_hdl_pnts, 2);
    hdl_right.p = hdl_data(1+num_of_hdl_pnts:2*num_of_hdl_pnts, 3);
    
    figure(200);
    subplot(211);
%     plot(src_left.x, src_left.y, 'k.', ...
%         src_right.x, src_right.y, 'k.', ...
%         src_left.x(src_left.p>0), src_left.y(src_left.p>0), 'r.', ...
%         src_right.x(src_right.p>0), src_right.y(src_right.p>0), 'b.', ...
%         hdl_left.x, hdl_left.y, 'r.', ...
%         hdl_right.x, hdl_right.y, 'b.');
    plot(src_left.x, src_left.y, 'k.', ...
        src_right.x, src_right.y, 'k.', ...
        src_left.x(src_left.p>0), src_left.y(src_left.p>0), 'r.', ...
        src_right.x(src_right.p>0), src_right.y(src_right.p>0), 'b.', ...
        hdl_left.x, hdl_left.y+100, 'k.', ...
        hdl_right.x, hdl_right.y+100, 'k.', ...
        hdl_left.x(hdl_left.p>0), hdl_left.y(hdl_left.p>0)+100, 'r.', ...
        hdl_right.x(hdl_right.p>0), hdl_right.y(hdl_right.p>0)+100, 'b.', ...
        hdl_left.x(hdl_left.p==0), hdl_left.y(hdl_left.p==0)+100, 'c.', ...
        hdl_right.x(hdl_right.p==0), hdl_right.y(hdl_right.p==0)+100, 'm.');
    axis equal;
    title(['Source and handled data of FG ' num2str(fg_id)]);
    
    figure(200);
    h2 = subplot(212);
    title(['Section data of FG ' num2str(fg_id)]);
    cla(h2);
    for ii = 1:num_of_segs
        seg_id = all_segs(ii);
        seg_file = sprintf(seg_str, fg_id, seg_id);
        if exist(seg_file, 'file')
            seg_data = load(seg_file);
            if isempty(seg_data)
                continue;
            end
            
            num_of_all_seg_pnts = size(seg_data, 1);
            num_of_seg_pnts = floor(num_of_all_seg_pnts / 2);
            
            seg_left.x = seg_data(1:num_of_seg_pnts, 1);
            seg_left.y = seg_data(1:num_of_seg_pnts, 2);
            seg_left.p = seg_data(1:num_of_seg_pnts, 3);
            
            seg_right.x = seg_data(1+num_of_seg_pnts:end, 1);
            seg_right.y = seg_data(1+num_of_seg_pnts:end, 2);
            seg_right.p = seg_data(1+num_of_seg_pnts:end, 3);
            
            figure(200);
            subplot(212);
            plot(seg_left.x, seg_left.y+10*mod(ii, 3), color(mod(ii, 3)+1, :), ...
                seg_right.x, seg_right.y+10*mod(ii, 3), color(mod(ii, 3)+1, :));
            hold on; axis equal;
            title(['Section data of FG ' num2str(fg_id)]);
        end
    end
    figure(200); subplot(212); hold off;
    
    pause(0.1);
end