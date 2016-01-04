% TEST_3.m
% plot one section data together
%


clf(figure(221))
for seg_id = 1:115
   for group_id = 0:90
       lane_fmt = sprintf('C:/Users/Ming.Chen/Desktop/results/11_13_2/fg_%d_sec_%d_group_0_lane_0.txt', group_id, seg_id);
       side_lane_fmt = sprintf('C:/Users/Ming.Chen/Desktop/results/11_13_2/fg_%d_sec_%d_group_0_lane_0_side_lane.txt', group_id, seg_id);
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
               left_line.y(left_line.p > 0), 'r.', ...
               right_line.x(right_line.p > 0), ...
               right_line.y(right_line.p > 0), 'b.' ...
               ); axis equal;
           title(['Group = ' num2str(group_id) ', SegId = ' num2str(seg_id)]);
           
           if exist(side_lane_fmt, 'file')
               side_lane_data = load(side_lane_fmt);
               numOfSideLanePnts = size(side_lane_data, 1) / 2;
               
               side_left_line.x = side_lane_data(1:numOfSideLanePnts, 1);
               side_left_line.y = side_lane_data(1:numOfSideLanePnts, 2);
               side_left_line.p = side_lane_data(1:numOfSideLanePnts, 3);
               
               side_right_line.x = side_lane_data(numOfSideLanePnts + 1 : end, 1);
               side_right_line.y = side_lane_data(numOfSideLanePnts + 1 : end, 2);
               side_right_line.p = side_lane_data(numOfSideLanePnts + 1 : end, 3);
               
               hold on;
               plot(side_left_line.x(side_left_line.p > 0), ...
                   side_left_line.y(side_left_line.p > 0), 'm.', ...
                   side_right_line.x(side_right_line.p > 0), ...
                   side_right_line.y(side_right_line.p > 0), 'c.' ...
                   ); hold off;
           end
           
           
           fprintf('group_id = %d, seg_id = %d\n', group_id, seg_id);
           
           pause(0.1);
       end
   end
   pause(0.1);
end