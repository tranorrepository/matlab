% TEST_2.m
%

clf(figure(221))
for group_id = 0:90
   for seg_id = 1:115
       lane_fmt = sprintf('C:/Users/Ming.Chen/Desktop/results/11_13_2/fg_%d_sec_%d_group_0_lane_0.txt', group_id, seg_id);
       if exist(lane_fmt, 'file')
           lane_data = load(lane_fmt);
           
           numOfPnts = size(lane_data, 1) / 2;
           left_line.x = lane_data(1:numOfPnts, 1);
           left_line.y = lane_data(1:numOfPnts, 2);
           left_line.p = lane_data(1:numOfPnts, 3);
           
           right_line.x = lane_data(numOfPnts + 1 : end, 1);
           right_line.y = lane_data(numOfPnts + 1 : end, 2);
           right_line.p = lane_data(numOfPnts + 1 : end, 3);
           
           
           figure(221)
           plot(left_line.x(left_line.p > 0), ...
               left_line.y(left_line.p > 0), 'g.', ...
               right_line.x(right_line.p > 0), ...
               right_line.y(right_line.p > 0), 'b.' ...
               ); axis equal;
           title(['Group = ' num2str(group_id) ', SegId = ' num2str(seg_id)]);
           
           fprintf('group_id = %d, seg_id = %d\n', group_id, seg_id);
           
           pause(1);
       end
   end
end