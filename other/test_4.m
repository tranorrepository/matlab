function test_4()
% TEST_4
%
%


clear variables; clc;
clf(figure(200))

folder_str = 'C:/Users/Ming.Chen/Desktop/results/12_10_1/';
src_str = [folder_str 'fg_%d_sec_36_lane_%d_merging_%d_0_source.txt'];
rot_str = [folder_str 'fg_%d_sec_36_lane_%d_merging_%d_1_rotated.txt'];
pla_str = [folder_str 'fg_%d_sec_36_lane_%d_merging_%d_2_interpolate_sample.txt'];
ply_str = [folder_str 'fg_%d_sec_36_lane_%d_merging_%d_3_polyval_sample.txt'];

lanes = [0, 1, 16];
fg_num = [9, 10, 11, 12, 13, 14, 15, 16, 60, 61, 62, 63, 64, 65];
merged_num = 22;

for mm = 1:merged_num
    for ll = 1:length(lanes)
        for ff = 1:length(fg_num)
            src_file = sprintf(src_str, fg_num(ff), lanes(ll), mm);
            rot_file = sprintf(rot_str, fg_num(ff), lanes(ll), mm);
            pla_file = sprintf(pla_str, fg_num(ff), lanes(ll), mm);
            ply_file = sprintf(ply_str, fg_num(ff), lanes(ll), mm);
            if exist(src_file, 'file')
                [src_left, src_right, ~] = get_lines(src_file);
                [rot_left, rot_right, ~] = get_lines(rot_file);
                [pla_left, pla_right, ~] = get_lines(pla_file);
                [ply_left, ply_right, ~] = get_lines(ply_file);
                
                figure(200); subplot(221);
                plot(src_left.x, src_left.y, '.', src_right.x, src_right.y, '.');
                axis equal;
                title(['Source of merged ' num2str(mm) ' lane ' num2str(lanes(ll))]);

                figure(200); subplot(222);
                plot(rot_left.x(rot_left.p > 0), rot_left.y(rot_left.p > 0), '.', ...
                    rot_right.x(rot_right.p > 0), rot_right.y(rot_right.p > 0), '.');
                axis equal;
                title(['Rotated of merged ' num2str(mm) ' lane ' num2str(lanes(ll))]);

                figure(200); subplot(223);
                plot(pla_left.x, pla_left.y, '.', pla_right.x, pla_right.y, '.');
                axis equal;
                title(['Pola of merged ' num2str(mm) ' lane ' num2str(lanes(ll))]);

                figure(200); subplot(224);
                plot(ply_left.x, ply_left.y, '.', ply_right.x, ply_right.y, '.');
                axis equal;
                title(['Poly of merged ' num2str(mm) ' lane ' num2str(lanes(ll))]);

                pause(0.1);
            end
        end
    end
end