% TEST_4.m
% plot one section data together
%

clear variables; clc;

if ~exist('cfg.mat', 'file')
    theta = load('theta.txt');
    cfg_pnts = load('cfgpnts.txt');
    num_of_segs = length(theta);
    cfgpnts = struct('ports', []);
    rot_cfgpnts = struct('ports', []);
    
    for ii = 1:num_of_segs
        cfgpnts(ii).ports.x = cfg_pnts(ii, 2:2:8);
        cfgpnts(ii).ports.y = cfg_pnts(ii, 1:2:7);
        
        rot_cfgpnts(ii).ports = rotateLine(cfgpnts(ii).ports, -theta(ii));
    end
else
    load('cfg.mat');
end

clf(figure(221))
for group_id = 39:57
   for seg_id = 1:121
       lane_fmt = sprintf('C:/Users/Ming.Chen/Desktop/results/11_27_0/fg_%d_sec_%d_group_0_lane_0.txt', group_id, seg_id);
       side_lane_fmt = sprintf('C:/Users/Ming.Chen/Desktop/results/11_27_0/fg_%d_sec_%d_group_0_lane_0_side_lane.txt', group_id, seg_id);
       if exist(lane_fmt, 'file')
           has_side_lane_data = 0;
           
           lane_data = load(lane_fmt);
           
           % road lane data
           numOfPnts = size(lane_data, 1) / 2;
           left_line.x = lane_data(1:numOfPnts, 1);
           left_line.y = lane_data(1:numOfPnts, 2);
           left_line.paint = lane_data(1:numOfPnts, 3);
           
           right_line.x = lane_data(numOfPnts + 1 : end, 1);
           right_line.y = lane_data(numOfPnts + 1 : end, 2);
           right_line.paint = lane_data(numOfPnts + 1 : end, 3);
           
           % side lane data
           if exist(side_lane_fmt, 'file')
%                has_side_lane_data = 1;
               side_lane_data = load(side_lane_fmt);
               numOfSideLanePnts = size(side_lane_data, 1) / 2;
               
               side_left_line.x = side_lane_data(1:numOfSideLanePnts, 1);
               side_left_line.y = side_lane_data(1:numOfSideLanePnts, 2);
               side_left_line.paint = side_lane_data(1:numOfSideLanePnts, 3);
               
               side_right_line.x = side_lane_data(numOfSideLanePnts + 1 : end, 1);
               side_right_line.y = side_lane_data(numOfSideLanePnts + 1 : end, 2);
               side_right_line.paint = side_lane_data(numOfSideLanePnts + 1 : end, 3);
               
           end
           
           % plot source data
           figure(221)
           subplot(2, 2, 1)
           plot(left_line.x(left_line.paint > 0), ...
               left_line.y(left_line.paint > 0), 'r.', ...
               right_line.x(right_line.paint > 0), ...
               right_line.y(right_line.paint > 0), 'b.', ...
               cfgpnts(seg_id).ports.x, cfgpnts(seg_id).ports.y, 'g*' ...
               ); axis equal;
           title(['Group = ' num2str(group_id) ', SegId = ' num2str(seg_id)]);
           if has_side_lane_data
               hold on;
               plot(side_left_line.x(side_left_line.paint > 0), ...
                   side_left_line.y(side_left_line.paint > 0), 'm.', ...
                   side_right_line.x(side_right_line.paint > 0), ...
                   side_right_line.y(side_right_line.paint > 0), 'c.' ...
                   ); hold off;
           end
           
           
           % rotation and resampling
           rot_left_line = rotateLine(left_line, -theta(seg_id));
           rot_left_line.paint = left_line.paint;
           rot_right_line = rotateLine(right_line, -theta(seg_id));
           rot_right_line.paint = right_line.paint;
           if has_side_lane_data
               rot_side_left_line = rotateLine(side_left_line, -theta(seg_id));
               rot_side_left_line.paint = side_left_line.paint;
               rot_side_right_line = rotateLine(side_right_line, -theta(seg_id));
               rot_side_right_line.paint = side_right_line.paint;
           end
           
           % plot rotation and resampling data
           figure(221)
           subplot(2, 2, 2)
           plot(rot_left_line.x(rot_left_line.paint > 0), ...
               rot_left_line.y(rot_left_line.paint > 0), 'r.', ...
               rot_right_line.x(rot_right_line.paint > 0), ...
               rot_right_line.y(rot_right_line.paint > 0), 'b.', ...
               rot_cfgpnts(seg_id).ports.x, rot_cfgpnts(seg_id).ports.y, 'g*' ...
               ); axis equal;
           title(['Rotated Group = ' num2str(group_id) ', SegId = ' num2str(seg_id)]);
           if has_side_lane_data
               hold on;
               plot(rot_side_left_line.x(rot_side_left_line.paint > 0), ...
                   rot_side_left_line.y(rot_side_left_line.paint > 0), 'm.', ...
                   rot_side_right_line.x(rot_side_right_line.paint > 0), ...
                   rot_side_right_line.y(rot_side_right_line.paint > 0), 'c.' ...
                   ); hold off;
           end
           
           clear left_blk right_blk left_length right_length ...
               max_left_length max_right_length left_val right_val ...
               tmpl tmpr all_left all_right
           
           % body points only
           minx = min(rot_cfgpnts(seg_id).ports.x(2:3));
           maxx = max(rot_cfgpnts(seg_id).ports.x(2:3));
           ind = intersect(find(rot_left_line.x >= minx), find(rot_left_line.x <= maxx));
           body_left_line.x = rot_left_line.x(ind);
           body_left_line.y = rot_left_line.y(ind);
           body_left_line.paint = rot_left_line.paint(ind);
           body_right_line.x = rot_right_line.x(ind);
           body_right_line.y = rot_right_line.y(ind);
           body_right_line.paint = rot_right_line.paint(ind);
           
           % dash line block length
           left_blk = dotLineBlockIndex(body_left_line);
           right_blk = dotLineBlockIndex(body_right_line);
           
           left_length = left_blk(:, 2) - left_blk(:, 1);
           right_length = right_blk(:, 2) - right_blk(:, 1);
           
           ml = mean(left_length);
           stdl = std(left_length);
           mr = mean(right_length);
           stdr = std(right_length);
           
           vl = [ml stdl];
           vr = [mr stdr];
           
           % line type estimation
           if ml > 100
               ltype = 1;
           else
               if ((ml + stdl) > 100) && (stdl / ml > 0.5)
                   ltype = 1;
               else
                   ltype = 0;
               end
           end
           if mr > 100
               rtype = 1;
           else
               if ((mr + stdr) > 100) && (stdr / mr > 0.5)
                   rtype = 1;
               else
                   rtype = 0;
               end
           end
           
           figure(221)
           subplot(2, 2, 3);
           b = bar([vl; vr], 'stacked');
           title({['left: ' num2str(stdl / ml) ', right: ' num2str(stdr / mr)]; ...
               ['left-right: ' num2str(ltype) ' - ' num2str(rtype)]});
           
           % full points
           % dash line block length
           full_left_blk = dotLineBlockIndex(rot_left_line);
           full_right_blk = dotLineBlockIndex(rot_right_line);
           
           full_left_length = full_left_blk(:, 2) - full_left_blk(:, 1);
           full_right_length = full_right_blk(:, 2) - full_right_blk(:, 1);
           
           mfl = mean(full_left_length);
           stdfl = std(full_left_length);
           mfr = mean(full_right_length);
           stdfr = std(full_right_length);
           
           vfl = [mfl stdfl];
           vfr = [mfr stdfr];
           
           % line type estimation
           if mfl > 100
               fltype = 1;
           else
               if ((mfl + stdfl) > 100) && (stdfl / mfl > 0.5)
                   fltype = 1;
               else
                   fltype = 0;
               end
           end
           if mfr > 100
               frtype = 1;
           else
               if ((mfr + stdfr) > 100) && (stdfr / mfr > 0.5)
                   frtype = 1;
               else
                   frtype = 0;
               end
           end
           
           figure(221)
           subplot(2, 2, 4);
           b = bar([vfl; vfr], 'stacked');
           title({['left: ' num2str(stdfl / mfl) ', right: ' num2str(stdfr / mfr)]; ...
               ['left-right: ' num2str(fltype) ' - ' num2str(frtype)]});
           
           
           
           
           
           
%            % paint and non-paint
%            
%            tmpl = 0.5 * left_blk(1 : end - 1, 2) + 0.5 * left_blk(2 : end, 1);
%            tmpr = 0.5 * right_blk(1 : end - 1, 2) + 0.5 * right_blk(2 : end, 1);
%            if isempty(tmpl)
%                all_left = [1 length(body_left_line.x)];
%            else
%                if tmpl(1) > 1
%                    all_left(1) = 1;
%                    all_left(2: length(tmpl) + 1) = tmpl;
%                end
%                
%                if tmpl(end) < length(body_left_line.x)
%                    all_left(end+1) = length(body_left_line.x);
%                end
%            end
%            
%            if isempty(tmpr)
%                all_right = [1 length(body_right_line.x)];
%            else
%                if tmpr(1) > 1
%                    all_right(1) = 1;
%                    all_right(2: length(tmpr) + 1) = tmpr;
%                end
%                
%                if tmpr(end) < length(body_right_line.x)
%                    all_right(end+1) = length(body_right_line.x);
%                end
%            end
%            
%            mal = mean(all_left(2 : end) - all_left(1 : end - 1));
%            stdal = std(all_left(2 : end) - all_left(1 : end - 1));
%            mar = mean(all_right(2 : end) - all_right(1 : end - 1));
%            stdar = std(all_right(2 : end) - all_right(1 : end - 1));
%            
%            figure(221)
%            subplot(2, 2, 4);
%            b = bar([mal stdal; mar stdar], 'stacked');
%            title(['left: ' num2str(stdal / mal) ', right: ' num2str(stdar / mar)]);
           
%          % length sum  
%            
%            max_left_length = max(left_length);
%            max_right_length = max(right_length);
%            
%            left_val.x = 0 : max_left_length;
%            left_val.y = 0 * left_val.x;
%            right_val.x = 0 : max_right_length;
%            right_val.y = 0 * right_val.x;
%            
%            for ii = 1:length(left_length)
%                ind = floor(0.5 * max_left_length - 0.5 * left_length(ii) + 1) : ...
%                    floor(0.5 * max_left_length + 0.5 * left_length(ii) - 1);
%                left_val.y(ind) = left_val.y(ind) + 1;
%            end
%            for ii = 1:length(right_length)
%                ind = floor(0.5 * max_right_length - 0.5 * right_length(ii) + 1) : ...
%                    floor(0.5 * max_right_length + 0.5 * right_length(ii) - 1);
%                right_val.y(ind) = right_val.y(ind) + 1;
%            end
%            
%            figure(221)
%            subplot(2, 2, 3)
%            plot(left_val.x, left_val.y, 'r', right_val.x, right_val.y, 'b');
%            max_length = max([max_left_length, max_right_length]);
%            axis([0 max_length, -5 30]);
           
           if ltype ~= fltype || rtype ~= frtype
               fprintf('MING: estimated lane type of group_id = %d, seg_id = %d\nleft-right: %d - %d\n', ...
                   group_id, seg_id, fltype, frtype);
           end
           pause(0.1);
       end
   end
   pause(0.1);
end