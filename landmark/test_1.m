% TEST_1.m
% landmark alignment algorithm
%

clear variables; clc;

arrow_format = 'C:/Users/Ming.Chen/Desktop/results/11_05_0/fg_%d_sec_19_arrows.txt';
source_format = 'C:/Users/Ming.Chen/Desktop/results/11_05_0/fg_%d_sec_19_source.txt';

clf(figure(250))

index = 1;
for ii = 0 : 200
    arrow_file = sprintf(arrow_format, ii);
    source_file = sprintf(source_format, ii);
    if exist(arrow_file, 'file') && exist(source_file, 'file')
        
        eval(['arrow_data{' num2str(index) '} = load(arrow_file);']);
        eval(['source_data{' num2str(index) '} = load(source_file);']);
        
        eval(['linex = source_data{' num2str(index) '}(:, 1);']);
        eval(['liney = source_data{' num2str(index) '}(:, 2);']);
        eval(['linep = source_data{' num2str(index) '}(:, 3);']);
        
        eval(['arrowx = arrow_data{' num2str(index) '}(:, 1);']);
        eval(['arrowy = arrow_data{' num2str(index) '}(:, 2);']);
        
        index = index + 1;
    
        figure(250)
        plot(linex(linep > 0), liney(linep > 0), '.', ...
            arrowx, arrowy, '*', 'MarkerSize', 3);
        axis equal; title(['Index = ' num2str(index - 1)]);
        
        pause(0.1);
    end
end

clear arrow_data1 arrow_data2 source_data1 source_data2 new_source_data1 new_source_data2

% change following two items to plot data
one = 9;
two = 11;
arrow_data1 = arrow_data{one};
arrow_data2 = arrow_data{two};
source_data1 = source_data{one};
source_data2 = source_data{two};

rows = size(arrow_data1, 1);
switch rows
        %%
    case 1
        merged = 0.5 * (arrow_data1 + arrow_data2);
        shift1 = merged - arrow_data1;
        shift2 = merged - arrow_data2;
        
        new_source_data1(:, 1) = source_data1(:, 1) + shift1(1);
        new_source_data1(:, 2) = source_data1(:, 2) + shift1(2);
        new_source_data1(:, 3) = source_data1(:, 3);
        
        new_source_data2(:, 1) = source_data2(:, 1) + shift2(1);
        new_source_data2(:, 2) = source_data2(:, 2) + shift2(2);
        new_source_data2(:, 3) = source_data2(:, 3);
        
        %%
    case 2
        merged = 0.5 * (arrow_data1 + arrow_data2);
        
        % center point
        center1 = mean(arrow_data1);
        center2 = mean(arrow_data2);
        new_center = mean(merged);
        
        % angle
        angle1 = atan2(arrow_data1(1, 2) - arrow_data1(2, 2), ...
            arrow_data1(1, 1) - arrow_data1(2, 1) );
        angle2 = atan2(arrow_data2(1, 2) - arrow_data2(2, 2), ...
            arrow_data2(1, 1) - arrow_data2(2, 1) );
        new_angle = atan2(merged(1, 2) - merged(2, 2), ...
            merged(1, 1) - merged(2, 1) );
        
        % length
        length1 = sqrt(power(arrow_data1(1, 1) - arrow_data1(2, 1), 2) + ...
            power(arrow_data1(1, 2) - arrow_data1(2, 2), 2));
        length2 = sqrt(power(arrow_data2(1, 1) - arrow_data2(2, 1), 2) + ...
            power(arrow_data2(1, 2) - arrow_data2(2, 2), 2));
        new_length = sqrt(power(merged(1, 1) - merged(2, 1), 2) + ...
            power(merged(1, 2) - merged(2, 2), 2));
        
        
        % center shift variable
        shift1 = new_center - center1;
        shift2 = new_center - center2;
        
        % rotate angle
        theta1 = angle1 - new_angle;
        theta2 = angle2 - new_angle;
        
        % scale factor
        sf1 = new_length / length1;
        sf2 = new_length / length2;
        
        % shift
        new_source_data1(:, 1) = source_data1(:, 1) + shift1(1);
        new_source_data1(:, 2) = source_data1(:, 2) + shift1(2);
        new_source_data1(:, 3) = source_data1(:, 3);
        
        new_source_data2(:, 1) = source_data2(:, 1) + shift2(1);
        new_source_data2(:, 2) = source_data2(:, 2) + shift2(2);
        new_source_data2(:, 3) = source_data2(:, 3);
        
        new_arrow_data1(:, 1) = arrow_data1(:, 1) + shift1(1);
        new_arrow_data1(:, 2) = arrow_data1(:, 2) + shift1(2);
        new_arrow_data2(:, 1) = arrow_data2(:, 1) + shift2(1);
        new_arrow_data2(:, 2) = arrow_data2(:, 2) + shift2(2);
        
        % rotate
        line1.x = new_source_data1(:, 1);
        line1.y = new_source_data1(:, 2);
        out1 = rotateLine(line1, theta1);
        
        line2.x = new_source_data2(:, 1);
        line2.y = new_source_data2(:, 2);
        out2 = rotateLine(line2, theta2);
        
%         new_source_data1(:, 1) = out1.x;
%         new_source_data1(:, 2) = out1.y;
%         new_source_data2(:, 1) = out2.x;
%         new_source_data2(:, 2) = out2.y;
        %
        % scale
        minx1 = min(new_arrow_data1(:, 1));
        maxx1 = max(new_arrow_data1(:, 1));
        minx2 = min(new_arrow_data2(:, 1));
        maxx2 = max(new_arrow_data2(:, 1));
        numOfPnts1 = size(new_source_data1, 1) / 2;
        left1 = new_source_data1(1 : numOfPnts1, :);
        right1 = new_source_data1(numOfPnts1 + 1 : end, :);
        
        numOfPnts2 = size(new_source_data2, 1) / 2;
        left2 = new_source_data2(1 : numOfPnts2, :);
        right2 = new_source_data2(numOfPnts2 + 1 : end, :);
        
        mid1 = floor(size(intersect(find(left1(:, 1) > minx2), find(left1(:, 1) < maxx1)), 1) / 2);
        mid2 = floor(size(intersect(find(left2(:, 1) > minx2), find(left2(:, 1) < maxx2)), 1) / 2);
        
        left1(:, 1) = left1(mid1, 1) + sf1 * (left1(:, 1) - left1(mid1, 1));
        right1(:, 1) = right1(mid1, 1) + sf1 * (right1(:, 1) - right1(mid1, 1));
        left2(:, 1) = left2(mid2, 1) + sf2 * (left2(:, 1) - left2(mid2, 1));
        right2(:, 1) = right2(mid2, 1) + sf2 * (right2(:, 1) - right2(mid2, 1));
        
        %%
    case 4
        merged = 0.5 * (arrow_data1 + arrow_data2);
        
        % shift
        shift1 = mean(merged - arrow_data1);
        shift2 = mean(merged - arrow_data2);
        
        % angle
        angle11 = atan2(arrow_data1(1, 2) - arrow_data1(2, 2), ...
            arrow_data1(1, 1) - arrow_data1(2, 1) );
        angle12 = atan2(arrow_data1(3, 2) - arrow_data1(2, 2), ...
            arrow_data1(3, 1) - arrow_data1(2, 1) );
        angle21 = atan2(arrow_data2(1, 2) - arrow_data2(2, 2), ...
            arrow_data2(1, 1) - arrow_data2(2, 1) );
        angle22 = atan2(arrow_data2(3, 2) - arrow_data2(2, 2), ...
            arrow_data2(3, 1) - arrow_data2(2, 1) );
        new_angle1 = atan2(merged(1, 2) - merged(2, 2), ...
            merged(1, 1) - merged(2, 1) );
        new_angle2 = atan2(merged(3, 2) - merged(2, 2), ...
            merged(3, 1) - merged(2, 1) );
        
        % rotate angle
        theta11 = angle11 - new_angle1;
        theta12 = angle12 - new_angle2;
        theta21 = angle21 - new_angle1;
        theta22 = angle22 - new_angle2;
        
        %% for test
        theta11_t = angle11 - new_angle1 + 0.01;
        theta12_t = angle12 - new_angle2 - 0.01;
        theta21_t = angle21 - new_angle1 - 0.01;
        theta22_t = angle22 - new_angle2 + 0.01;
        %% end test
        
        % length
        length11 = sqrt(power(arrow_data1(1, 1) - arrow_data1(2, 1), 2) + ...
            power(arrow_data1(1, 2) - arrow_data1(2, 2), 2));
        length12 = sqrt(power(arrow_data1(3, 1) - arrow_data1(2, 1), 2) + ...
            power(arrow_data1(3, 2) - arrow_data1(2, 2), 2));
        length21 = sqrt(power(arrow_data2(1, 1) - arrow_data2(2, 1), 2) + ...
            power(arrow_data2(1, 2) - arrow_data2(2, 2), 2));
        length22 = sqrt(power(arrow_data2(3, 1) - arrow_data2(2, 1), 2) + ...
            power(arrow_data2(3, 2) - arrow_data2(2, 2), 2));
        new_length1 = sqrt(power(merged(1, 1) - merged(2, 1), 2) + ...
            power(merged(1, 2) - merged(2, 2), 2));
        new_length2 = sqrt(power(merged(3, 1) - merged(2, 1), 2) + ...
            power(merged(3, 2) - merged(2, 2), 2));
        
        % scaling factor
        sf11 = new_length1 / length11;
        sf12 = new_length2 / length12;
        sf21 = new_length1 / length21;
        sf22 = new_length2 / length22;
        
        % translation
        new_source_data1(:, 1) = source_data1(:, 1) + shift1(1);
        new_source_data1(:, 2) = source_data1(:, 2) + shift1(2);
        new_source_data1(:, 3) = source_data1(:, 3);
        
        new_source_data2(:, 1) = source_data2(:, 1) + shift2(1);
        new_source_data2(:, 2) = source_data2(:, 2) + shift2(2);
        new_source_data2(:, 3) = source_data2(:, 3);
        
        new_arrow_data1(:, 1) = arrow_data1(:, 1) + shift1(1);
        new_arrow_data1(:, 2) = arrow_data1(:, 2) + shift1(2);
        new_arrow_data2(:, 1) = arrow_data2(:, 1) + shift2(1);
        new_arrow_data2(:, 2) = arrow_data2(:, 2) + shift2(2);
        
        %
        numOfPnts1 = size(new_source_data1, 1) / 2;
        left1 = new_source_data1(1 : numOfPnts1, :);
        right1 = new_source_data1(numOfPnts1 + 1 : end, :);
        
        numOfPnts2 = size(new_source_data2, 1) / 2;
        left2 = new_source_data2(1 : numOfPnts2, :);
        right2 = new_source_data2(numOfPnts2 + 1 : end, :);
        
        mid1 = size(find(left1(:, 1) >= merged(2, 1)), 1);
        mid2 = size(find(left2(:, 1) >= merged(2, 1)), 1);
        
        %% for test
        left1_t = new_source_data1(1 : numOfPnts1, :);
        right1_t = new_source_data1(numOfPnts1 + 1 : end, :);
        left2_t = new_source_data2(1 : numOfPnts2, :);
        right2_t = new_source_data2(numOfPnts2 + 1 : end, :);
        %% end test
        
        % left1 first half
%         left1(1 : mid1 - 1, 1) = left1(mid1, 1) + ...
%             sf11 * (left1(1 : mid1 - 1, 1) - left1(mid1, 1));
        
        line.x = left1(1 : mid1 - 1, 1) - left1(mid1, 1);
        line.y = left1(1 : mid1 - 1, 2) - left1(mid1, 2);
        outline = rotateLine(line, -theta11);
        left1(1 : mid1 - 1, 1) = outline.x + left1(mid1, 1);
        left1(1 : mid1 - 1, 2) = outline.y + left1(mid1, 2);
        
        %% for test
        line.x = left1_t(1 : mid1 - 1, 1) - left1_t(mid1, 1);
        line.y = left1_t(1 : mid1 - 1, 2) - left1_t(mid1, 2);
        outline = rotateLine(line, -theta11_t);
        left1_t(1 : mid1 - 1, 1) = outline.x + left1_t(mid1, 1);
        left1_t(1 : mid1 - 1, 2) = outline.y + left1_t(mid1, 2);
        %% end test
        
        % left1 second half
%         left1(mid1 + 1 : end, 1) = left1(mid1, 1) + ...
%             sf12 * (left1(mid1 + 1 : end, 1) - left1(mid1, 1));
        
        line.x = left1(mid1 + 1 : end, 1) - left1(mid1, 1);
        line.y = left1(mid1 + 1 : end, 2) - left1(mid1, 2);
        outline = rotateLine(line, -theta12);
        left1(mid1 + 1 : end, 1) = outline.x + left1(mid1, 1);
        left1(mid1 + 1 : end, 2) = outline.y + left1(mid1, 2);
        
        %% for test
        line.x = left1_t(mid1 + 1 : end, 1) - left1_t(mid1, 1);
        line.y = left1_t(mid1 + 1 : end, 2) - left1_t(mid1, 2);
        outline = rotateLine(line, -theta12_t);
        left1_t(mid1 + 1 : end, 1) = outline.x + left1_t(mid1, 1);
        left1_t(mid1 + 1 : end, 2) = outline.y + left1_t(mid1, 2);
        %%
        
        
        % right1 first half
%         right1(1 : mid1 - 1, 1) = right1(mid1, 1) + ...
%             sf11 * (right1(1 : mid1 - 1, 1) - right1(mid1, 1));
        
        line.x = right1(1 : mid1 - 1, 1) - right1(mid1, 1);
        line.y = right1(1 : mid1 - 1, 2) - right1(mid1, 2);
        outline = rotateLine(line, -theta11);
        right1(1 : mid1 - 1, 1) = outline.x + right1(mid1, 1);
        right1(1 : mid1 - 1, 2) = outline.y + right1(mid1, 2);
        
        %% for test
        line.x = right1_t(1 : mid1 - 1, 1) - right1_t(mid1, 1);
        line.y = right1_t(1 : mid1 - 1, 2) - right1_t(mid1, 2);
        outline = rotateLine(line, -theta11_t);
        right1_t(1 : mid1 - 1, 1) = outline.x + right1_t(mid1, 1);
        right1_t(1 : mid1 - 1, 2) = outline.y + right1_t(mid1, 2);
        %%
        
        % right1 second half
%         right1(mid1 + 1 : end, 1) = right1(mid1, 1) + ...
%             sf12 * (right1(mid1 + 1 : end, 1) - right1(mid1, 1));
        
        line.x = right1(mid1 + 1 : end, 1) - right1(mid1, 1);
        line.y = right1(mid1 + 1 : end, 2) - right1(mid1, 2);
        outline = rotateLine(line, -theta12);
        right1(mid1 + 1 : end, 1) = outline.x + right1(mid1, 1);
        right1(mid1 + 1 : end, 2) = outline.y + right1(mid1, 2);
        
        %% for test
        line.x = right1_t(mid1 + 1 : end, 1) - right1_t(mid1, 1);
        line.y = right1_t(mid1 + 1 : end, 2) - right1_t(mid1, 2);
        outline = rotateLine(line, -theta12_t);
        right1_t(mid1 + 1 : end, 1) = outline.x + right1_t(mid1, 1);
        right1_t(mid1 + 1 : end, 2) = outline.y + right1_t(mid1, 2);
        %%
        
        % left2 first half
%         left2(1 : mid2 - 1, 1) = left2(mid2, 1) + ...
%             sf21 * (left2(1 : mid2 - 1, 1) - left2(mid2, 1));
        
        line.x = left2(1 : mid2 - 1, 1) - left2(mid2, 1);
        line.y = left2(1 : mid2 - 1, 2) - left2(mid2, 2);
        outline = rotateLine(line, -theta21);
        left2(1 : mid2 - 1, 1) = outline.x + left2(mid2, 1);
        left2(1 : mid2 - 1, 2) = outline.y + left2(mid2, 2);
        
        %% for test
        line.x = left2_t(1 : mid2 - 1, 1) - left2_t(mid2, 1);
        line.y = left2_t(1 : mid2 - 1, 2) - left2_t(mid2, 2);
        outline = rotateLine(line, -theta21_t);
        left2_t(1 : mid2 - 1, 1) = outline.x + left2_t(mid2, 1);
        left2_t(1 : mid2 - 1, 2) = outline.y + left2_t(mid2, 2);
        %%
        
        % left2 second half
%         left2(mid2 + 1 : end, 1) = left2(mid2, 1) + ...
%             sf22 * (left2(mid2 + 1 : end, 1) - left2(mid2, 1));
        
        line.x = left2(mid2 + 1 : end, 1) - left2(mid2, 1);
        line.y = left2(mid2 + 1 : end, 2) - left2(mid2, 2);
        outline = rotateLine(line, -theta22);
        left2(mid2 + 1 : end, 1) = outline.x + left2(mid2, 1);
        left2(mid2 + 1 : end, 2) = outline.y + left2(mid2, 2);
        
        %% for test
        line.x = left2_t(mid2 + 1 : end, 1) - left2_t(mid2, 1);
        line.y = left2_t(mid2 + 1 : end, 2) - left2_t(mid2, 2);
        outline = rotateLine(line, -theta22_t);
        left2_t(mid2 + 1 : end, 1) = outline.x + left2_t(mid2, 1);
        left2_t(mid2 + 1 : end, 2) = outline.y + left2_t(mid2, 2);
        %%
        
        % right2 first half
%         right2(1 : mid2 - 1, 1) = right2(mid2, 1) + ...
%             sf21 * (right2(1 : mid2 - 1, 1) - right2(mid2, 1));
        
        line.x = right2(1 : mid2 - 1, 1) - right2(mid2, 1);
        line.y = right2(1 : mid2 - 1, 2) - right2(mid2, 2);
        outline = rotateLine(line, -theta21);
        right2(1 : mid2 - 1, 1) = outline.x + right2(mid2, 1);
        right2(1 : mid2 - 1, 2) = outline.y + right2(mid2, 2);
        
        %% for test
        line.x = right2_t(1 : mid2 - 1, 1) - right2_t(mid2, 1);
        line.y = right2_t(1 : mid2 - 1, 2) - right2_t(mid2, 2);
        outline = rotateLine(line, -theta21_t);
        right2_t(1 : mid2 - 1, 1) = outline.x + right2_t(mid2, 1);
        right2_t(1 : mid2 - 1, 2) = outline.y + right2_t(mid2, 2);
        %%
        
        % right2 second half
%         right2(mid2 + 1 : end, 1) = right2(mid2, 1) + ...
%             sf22 * (right2(mid2 + 1 : end, 1) - right2(mid2, 1));
        
        line.x = right2(mid2 + 1 : end, 1) - right2(mid2, 1);
        line.y = right2(mid2 + 1 : end, 2) - right2(mid2, 2);
        outline = rotateLine(line, -theta22);
        right2(mid2 + 1 : end, 1) = outline.x + right2(mid2, 1);
        right2(mid2 + 1 : end, 2) = outline.y + right2(mid2, 2);
        
        %% for test
        line.x = right2_t(mid2 + 1 : end, 1) - right2_t(mid2, 1);
        line.y = right2_t(mid2 + 1 : end, 2) - right2_t(mid2, 2);
        outline = rotateLine(line, -theta22_t);
        right2_t(mid2 + 1 : end, 1) = outline.x + right2_t(mid2, 1);
        right2_t(mid2 + 1 : end, 2) = outline.y + right2_t(mid2, 2);
        
        %%
    case 5
        merged = 0.5 * (arrow_data1 + arrow_data2);
        
        % shift
        shift1 = mean(merged - arrow_data1);
        shift2 = mean(merged - arrow_data2);
        
        % angle
        angle11 = atan2(arrow_data1(1, 2) - arrow_data1(2, 2), ...
            arrow_data1(1, 1) - arrow_data1(2, 1) );
        angle12 = atan2(arrow_data1(3, 2) - arrow_data1(2, 2), ...
            arrow_data1(3, 1) - arrow_data1(2, 1) );
        angle21 = atan2(arrow_data2(1, 2) - arrow_data2(2, 2), ...
            arrow_data2(1, 1) - arrow_data2(2, 1) );
        angle22 = atan2(arrow_data2(3, 2) - arrow_data2(2, 2), ...
            arrow_data2(3, 1) - arrow_data2(2, 1) );
        new_angle1 = atan2(merged(1, 2) - merged(2, 2), ...
            merged(1, 1) - merged(2, 1) );
        new_angle2 = atan2(merged(3, 2) - merged(2, 2), ...
            merged(3, 1) - merged(2, 1) );
        
        % rotate angle
        theta11 = angle11 - new_angle1;
        theta12 = angle12 - new_angle2;
        theta21 = angle21 - new_angle1;
        theta22 = angle22 - new_angle2;
        
        % for test
        theta11_t = angle11 - new_angle1 + 0.1;
        theta12_t = angle12 - new_angle2 + 0.1;
        theta21_t = angle21 - new_angle1 + 0.1;
        theta22_t = angle22 - new_angle2 + 0.1;
        % end test
        
        % length
        length11 = sqrt(power(arrow_data1(1, 1) - arrow_data1(2, 1), 2) + ...
            power(arrow_data1(1, 2) - arrow_data1(2, 2), 2));
        length12 = sqrt(power(arrow_data1(3, 1) - arrow_data1(2, 1), 2) + ...
            power(arrow_data1(3, 2) - arrow_data1(2, 2), 2));
        length21 = sqrt(power(arrow_data2(1, 1) - arrow_data2(2, 1), 2) + ...
            power(arrow_data2(1, 2) - arrow_data2(2, 2), 2));
        length22 = sqrt(power(arrow_data2(3, 1) - arrow_data2(2, 1), 2) + ...
            power(arrow_data2(3, 2) - arrow_data2(2, 2), 2));
        new_length1 = sqrt(power(merged(1, 1) - merged(2, 1), 2) + ...
            power(merged(1, 2) - merged(2, 2), 2));
        new_length2 = sqrt(power(merged(3, 1) - merged(2, 1), 2) + ...
            power(merged(3, 2) - merged(2, 2), 2));
        
        % scaling factor
        sf11 = new_length1 / length11;
        sf12 = new_length2 / length12;
        sf21 = new_length1 / length21;
        sf22 = new_length2 / length22;
        
        % translation
        new_source_data1(:, 1) = source_data1(:, 1) + shift1(1);
        new_source_data1(:, 2) = source_data1(:, 2) + shift1(2);
        new_source_data1(:, 3) = source_data1(:, 3);
        
        new_source_data2(:, 1) = source_data2(:, 1) + shift2(1);
        new_source_data2(:, 2) = source_data2(:, 2) + shift2(2);
        new_source_data2(:, 3) = source_data2(:, 3);
        
        new_arrow_data1(:, 1) = arrow_data1(:, 1) + shift1(1);
        new_arrow_data1(:, 2) = arrow_data1(:, 2) + shift1(2);
        new_arrow_data2(:, 1) = arrow_data2(:, 1) + shift2(1);
        new_arrow_data2(:, 2) = arrow_data2(:, 2) + shift2(2);
        
        %
        numOfPnts1 = size(new_source_data1, 1) / 2;
        left1 = new_source_data1(1 : numOfPnts1, :);
        right1 = new_source_data1(numOfPnts1 + 1 : end, :);
        
        numOfPnts2 = size(new_source_data2, 1) / 2;
        left2 = new_source_data2(1 : numOfPnts2, :);
        right2 = new_source_data2(numOfPnts2 + 1 : end, :);
        
        mid1 = size(find(left1(:, 1) >= merged(2, 1)), 1);
        mid2 = size(find(left2(:, 1) >= merged(2, 1)), 1);
        
        % left1 first half
        left1(1 : mid1 - 1, 1) = left1(mid1, 1) + ...
            sf11 * (left1(1 : mid1 - 1, 1) - left1(mid1, 1));
        
        line.x = left1(1 : mid1 - 1, 1) - left1(mid1, 1);
        line.y = left1(1 : mid1 - 1, 2) - left1(mid1, 2);
        outline = rotateLine(line, -theta11);
        left1(1 : mid1 - 1, 1) = outline.x + left1(mid1, 1);
        left1(1 : mid1 - 1, 2) = outline.y + left1(mid1, 2);
        
        
        % left1 second half
        left1(mid1 + 1 : end, 1) = left1(mid1, 1) + ...
            sf12 * (left1(mid1 + 1 : end, 1) - left1(mid1, 1));
        
        line.x = left1(mid1 + 1 : end, 1) - left1(mid1, 1);
        line.y = left1(mid1 + 1 : end, 2) - left1(mid1, 2);
        outline = rotateLine(line, -theta12);
        left1(mid1 + 1 : end, 1) = outline.x + left1(mid1, 1);
        left1(mid1 + 1 : end, 2) = outline.y + left1(mid1, 2);
        
        % right1 first half
        right1(1 : mid1 - 1, 1) = right1(mid1, 1) + ...
            sf11 * (right1(1 : mid1 - 1, 1) - right1(mid1, 1));
        
        line.x = right1(1 : mid1 - 1, 1) - right1(mid1, 1);
        line.y = right1(1 : mid1 - 1, 2) - right1(mid1, 2);
        outline = rotateLine(line, -theta11);
        right1(1 : mid1 - 1, 1) = outline.x + right1(mid1, 1);
        right1(1 : mid1 - 1, 2) = outline.y + right1(mid1, 2);
        
        % right1 second half
        right1(mid1 + 1 : end, 1) = right1(mid1, 1) + ...
            sf12 * (right1(mid1 + 1 : end, 1) - right1(mid1, 1));
        
        line.x = right1(mid1 + 1 : end, 1) - right1(mid1, 1);
        line.y = right1(mid1 + 1 : end, 2) - right1(mid1, 2);
        outline = rotateLine(line, -theta12);
        right1(mid1 + 1 : end, 1) = outline.x + right1(mid1, 1);
        right1(mid1 + 1 : end, 2) = outline.y + right1(mid1, 2);
        
        % left2 first half
        left2(1 : mid2 - 1, 1) = left2(mid2, 1) + ...
            sf21 * (left2(1 : mid2 - 1, 1) - left2(mid2, 1));
        
        line.x = left2(1 : mid2 - 1, 1) - left2(mid2, 1);
        line.y = left2(1 : mid2 - 1, 2) - left2(mid2, 2);
        outline = rotateLine(line, -theta21);
        left2(1 : mid2 - 1, 1) = outline.x + left2(mid2, 1);
        left2(1 : mid2 - 1, 2) = outline.y + left2(mid2, 2);
        
        % left2 second half
        left2(mid2 + 1 : end, 1) = left2(mid2, 1) + ...
            sf22 * (left2(mid2 + 1 : end, 1) - left2(mid2, 1));
        
        line.x = left2(mid2 + 1 : end, 1) - left2(mid2, 1);
        line.y = left2(mid2 + 1 : end, 2) - left2(mid2, 2);
        outline = rotateLine(line, -theta22);
        left2(mid2 + 1 : end, 1) = outline.x + left2(mid2, 1);
        left2(mid2 + 1 : end, 2) = outline.y + left2(mid2, 2);
        
        % right2 first half
        right2(1 : mid2 - 1, 1) = right2(mid2, 1) + ...
            sf21 * (right2(1 : mid2 - 1, 1) - right2(mid2, 1));
        
        line.x = right2(1 : mid2 - 1, 1) - right2(mid2, 1);
        line.y = right2(1 : mid2 - 1, 2) - right2(mid2, 2);
        outline = rotateLine(line, -theta21);
        right2(1 : mid2 - 1, 1) = outline.x + right2(mid2, 1);
        right2(1 : mid2 - 1, 2) = outline.y + right2(mid2, 2);
        
        % right2 second half
        right2(mid2 + 1 : end, 1) = right2(mid2, 1) + ...
            sf22 * (right2(mid2 + 1 : end, 1) - right2(mid2, 1));
        
        line.x = right2(mid2 + 1 : end, 1) - right2(mid2, 1);
        line.y = right2(mid2 + 1 : end, 2) - right2(mid2, 2);
        outline = rotateLine(line, -theta22);
        right2(mid2 + 1 : end, 1) = outline.x + right2(mid2, 1);
        right2(mid2 + 1 : end, 2) = outline.y + right2(mid2, 2);
        
        %%
    case 3
        merged = 0.5 * (arrow_data1 + arrow_data2);
        
        % shift
        shift1 = mean(merged - arrow_data1);
        shift2 = mean(merged - arrow_data2);
        
        % angle
        angle11 = atan2(arrow_data1(1, 2) - arrow_data1(2, 2), ...
            arrow_data1(1, 1) - arrow_data1(2, 1) );
        angle12 = atan2(arrow_data1(3, 2) - arrow_data1(2, 2), ...
            arrow_data1(3, 1) - arrow_data1(2, 1) );
        angle21 = atan2(arrow_data2(1, 2) - arrow_data2(2, 2), ...
            arrow_data2(1, 1) - arrow_data2(2, 1) );
        angle22 = atan2(arrow_data2(3, 2) - arrow_data2(2, 2), ...
            arrow_data2(3, 1) - arrow_data2(2, 1) );
        new_angle1 = atan2(merged(1, 2) - merged(2, 2), ...
            merged(1, 1) - merged(2, 1) );
        new_angle2 = atan2(merged(3, 2) - merged(2, 2), ...
            merged(3, 1) - merged(2, 1) );
        
        % rotate angle
        theta11 = angle11 - new_angle1;
        theta12 = angle12 - new_angle2;
        theta21 = angle21 - new_angle1;
        theta22 = angle22 - new_angle2;
        
        % length
        length11 = sqrt(power(arrow_data1(1, 1) - arrow_data1(2, 1), 2) + ...
            power(arrow_data1(1, 2) - arrow_data1(2, 2), 2));
        length12 = sqrt(power(arrow_data1(3, 1) - arrow_data1(2, 1), 2) + ...
            power(arrow_data1(3, 2) - arrow_data1(2, 2), 2));
        length21 = sqrt(power(arrow_data2(1, 1) - arrow_data2(2, 1), 2) + ...
            power(arrow_data2(1, 2) - arrow_data2(2, 2), 2));
        length22 = sqrt(power(arrow_data2(3, 1) - arrow_data2(2, 1), 2) + ...
            power(arrow_data2(3, 2) - arrow_data2(2, 2), 2));
        new_length1 = sqrt(power(merged(1, 1) - merged(2, 1), 2) + ...
            power(merged(1, 2) - merged(2, 2), 2));
        new_length2 = sqrt(power(merged(3, 1) - merged(2, 1), 2) + ...
            power(merged(3, 2) - merged(2, 2), 2));
        
        % scaling factor
        sf11 = new_length1 / length11;
        sf12 = new_length2 / length12;
        sf21 = new_length1 / length21;
        sf22 = new_length2 / length22;
        
        % translation
        new_source_data1(:, 1) = source_data1(:, 1) + shift1(1);
        new_source_data1(:, 2) = source_data1(:, 2) + shift1(2);
        new_source_data1(:, 3) = source_data1(:, 3);
        
        new_source_data2(:, 1) = source_data2(:, 1) + shift2(1);
        new_source_data2(:, 2) = source_data2(:, 2) + shift2(2);
        new_source_data2(:, 3) = source_data2(:, 3);
        
        new_arrow_data1(:, 1) = arrow_data1(:, 1) + shift1(1);
        new_arrow_data1(:, 2) = arrow_data1(:, 2) + shift1(2);
        new_arrow_data2(:, 1) = arrow_data2(:, 1) + shift2(1);
        new_arrow_data2(:, 2) = arrow_data2(:, 2) + shift2(2);
        
        %
        numOfPnts1 = size(new_source_data1, 1) / 2;
        left1 = new_source_data1(1 : numOfPnts1, :);
        right1 = new_source_data1(numOfPnts1 + 1 : end, :);
        
        numOfPnts2 = size(new_source_data2, 1) / 2;
        left2 = new_source_data2(1 : numOfPnts2, :);
        right2 = new_source_data2(numOfPnts2 + 1 : end, :);
        
        mid1 = size(find(left1(:, 1) >= merged(2, 1)), 1);
        mid2 = size(find(left2(:, 1) >= merged(2, 1)), 1);
        
        % left1 first half
        line.x = left1(1 : mid1 - 1, 1) - left1(mid1, 1);
        line.y = left1(1 : mid1 - 1, 2) - left1(mid1, 2);
        outline = rotateLine(line, -theta11);
        left1(1 : mid1 - 1, 1) = outline.x + left1(mid1, 1);
        left1(1 : mid1 - 1, 2) = outline.y + left1(mid1, 2);
        
%         left1(1 : mid1 - 1, 1) = left1(mid1, 1) + ...
%             sf11 * (left1(1 : mid1 - 1, 1) - left1(mid1, 1));
        
        % left1 second half
        line.x = left1(mid1 + 1 : end, 1) - left1(mid1, 1);
        line.y = left1(mid1 + 1 : end, 2) - left1(mid1, 2);
        outline = rotateLine(line, -theta12);
        left1(mid1 + 1 : end, 1) = outline.x + left1(mid1, 1);
        left1(mid1 + 1 : end, 2) = outline.y + left1(mid1, 2);
        
%         left1(mid1 + 1 : end, 1) = left1(mid1, 1) + ...
%             sf12 * (left1(mid1 + 1 : end, 1) - left1(mid1, 1));
        
        % right1 first half
        line.x = right1(1 : mid1 - 1, 1) - right1(mid1, 1);
        line.y = right1(1 : mid1 - 1, 2) - right1(mid1, 2);
        outline = rotateLine(line, -theta11);
        right1(1 : mid1 - 1, 1) = outline.x + right1(mid1, 1);
        right1(1 : mid1 - 1, 2) = outline.y + right1(mid1, 2);
        
%         right1(1 : mid1 - 1, 1) = right1(mid1, 1) + ...
%             sf11 * (right1(1 : mid1 - 1, 1) - right1(mid1, 1));
        
        % right1 second half
        line.x = right1(mid1 + 1 : end, 1) - right1(mid1, 1);
        line.y = right1(mid1 + 1 : end, 2) - right1(mid1, 2);
        outline = rotateLine(line, -theta12);
        right1(mid1 + 1 : end, 1) = outline.x + right1(mid1, 1);
        right1(mid1 + 1 : end, 2) = outline.y + right1(mid1, 2);
        
%         right1(mid1 + 1 : end, 1) = right1(mid1, 1) + ...
%             sf12 * (right1(mid1 + 1 : end, 1) - right1(mid1, 1));

        % left2 first half
        line.x = left2(1 : mid2 - 1, 1) - left2(mid2, 1);
        line.y = left2(1 : mid2 - 1, 2) - left2(mid2, 2);
        outline = rotateLine(line, -theta21);
        left2(1 : mid2 - 1, 1) = outline.x + left2(mid2, 1);
        left2(1 : mid2 - 1, 2) = outline.y + left2(mid2, 2);
        
%         left2(1 : mid2 - 1, 1) = left2(mid2, 1) + ...
%             sf21 * (left2(1 : mid2 - 1, 1) - left2(mid2, 1));
        
        % left2 second half
        line.x = left2(mid2 + 1 : end, 1) - left2(mid2, 1);
        line.y = left2(mid2 + 1 : end, 2) - left2(mid2, 2);
        outline = rotateLine(line, -theta22);
        left2(mid2 + 1 : end, 1) = outline.x + left2(mid2, 1);
        left2(mid2 + 1 : end, 2) = outline.y + left2(mid2, 2);
        
%         left2(mid2 + 1 : end, 1) = left2(mid2, 1) + ...
%             sf22 * (left2(mid2 + 1 : end, 1) - left2(mid2, 1));
        
        % right2 first half
        line.x = right2(1 : mid2 - 1, 1) - right2(mid2, 1);
        line.y = right2(1 : mid2 - 1, 2) - right2(mid2, 2);
        outline = rotateLine(line, -theta21);
        right2(1 : mid2 - 1, 1) = outline.x + right2(mid2, 1);
        right2(1 : mid2 - 1, 2) = outline.y + right2(mid2, 2);
        
%         right2(1 : mid2 - 1, 1) = right2(mid2, 1) + ...
%             sf21 * (right2(1 : mid2 - 1, 1) - right2(mid2, 1));
        
        % right2 second half
        line.x = right2(mid2 + 1 : end, 1) - right2(mid2, 1);
        line.y = right2(mid2 + 1 : end, 2) - right2(mid2, 2);
        outline = rotateLine(line, -theta22);
        right2(mid2 + 1 : end, 1) = outline.x + right2(mid2, 1);
        right2(mid2 + 1 : end, 2) = outline.y + right2(mid2, 2);
        
%         right2(mid2 + 1 : end, 1) = right2(mid2, 1) + ...
%             sf22 * (right2(mid2 + 1 : end, 1) - right2(mid2, 1));
        
        %%
end

clf(figure(251))

if rows == 1
    plot(source_data1(source_data1(:, 3) > 0, 1), ...
        source_data1(source_data1(:, 3) > 0, 2), 'r.', ...
        source_data2(source_data2(:, 3) > 0, 1), ...
        source_data2(source_data2(:, 3) > 0, 2), 'b.', ...
        arrow_data1(:, 1), arrow_data1(:, 2), 'ro', ...
        arrow_data2(:, 1), arrow_data2(:, 2), 'bo', ...
        new_source_data1(new_source_data1(:, 3) > 0, 1), ...
        new_source_data1(new_source_data1(:, 3) > 0, 2) + 40, 'r.', ...
        new_source_data2(new_source_data2(:, 3) > 0, 1), ...
        new_source_data2(new_source_data2(:, 3) > 0, 2) + 40, 'b.', ...
        merged(:, 1), merged(:, 2) + 40, 'g*'); axis equal;
elseif rows == 2
    plot(source_data1(source_data1(:, 3) > 0, 1), ...
        source_data1(source_data1(:, 3) > 0, 2), 'r.', ...
        source_data2(source_data2(:, 3) > 0, 1), ...
        source_data2(source_data2(:, 3) > 0, 2), 'b.', ...
        arrow_data1(:, 1), arrow_data1(:, 2), 'ro', ...
        arrow_data2(:, 1), arrow_data2(:, 2), 'bo', ...
        new_source_data1(new_source_data1(:, 3) > 0, 1), ...
        new_source_data1(new_source_data1(:, 3) > 0, 2) + 40, 'r.', ...
        new_source_data2(new_source_data2(:, 3) > 0, 1), ...
        new_source_data2(new_source_data2(:, 3) > 0, 2) + 40, 'b.', ...
        new_arrow_data1(:, 1), new_arrow_data1(:, 2) + 40, 'ro', ...
        new_arrow_data2(:, 1), new_arrow_data2(:, 2) + 40, 'bo', ...
        merged(:, 1), merged(:, 2) + 40, 'g*', ...
        new_center(:, 1), new_center(:, 2) + 40, 'go', ...
        left1(left1(:, 3) > 0, 1), left1(left1(:, 3) > 0, 2) + 80, 'r.', ...
        left2(left2(:, 3) > 0, 1), left2(left2(:, 3) > 0, 2) + 80, 'b.', ...
        right1(right1(:, 3) > 0, 1), right1(right1(:, 3) > 0, 2) + 80, 'r.', ...
        right2(right2(:, 3) > 0, 1), right2(right2(:, 3) > 0, 2) + 80, 'b.', ...
        merged(:, 1), merged(:, 2) + 80, 'g*'); axis equal;
elseif rows == 3
    plot(source_data1(source_data1(:, 3) > 0, 1), ...
        source_data1(source_data1(:, 3) > 0, 2), 'r.', ...
        source_data2(source_data2(:, 3) > 0, 1), ...
        source_data2(source_data2(:, 3) > 0, 2), 'b.', ...
        arrow_data1(:, 1), arrow_data1(:, 2), 'ro', ...
        arrow_data2(:, 1), arrow_data2(:, 2), 'bo', ...
        new_source_data1(new_source_data1(:, 3) > 0, 1), ...
        new_source_data1(new_source_data1(:, 3) > 0, 2) + 40, 'r.', ...
        new_source_data2(new_source_data2(:, 3) > 0, 1), ...
        new_source_data2(new_source_data2(:, 3) > 0, 2) + 40, 'b.', ...
        merged(:, 1), merged(:, 2) + 40, 'g*', ...
        left1(left1(:, 3) > 0, 1), left1(left1(:, 3) > 0, 2) + 80, 'r.', ...
        right1(right1(:, 3) > 0, 1), right1(right1(:, 3) > 0, 2) + 80, 'r.', ...
        left2(left2(:, 3) > 0, 1), left2(left2(:, 3) > 0, 2) + 80, 'b.', ...
        right2(right2(:, 3) > 0, 1), right2(right2(:, 3) > 0, 2) + 80, 'b.', ...
        merged(:, 1), merged(:, 2) + 80, 'g*'); axis equal;
    
if 0  
    clf(figure(252))
    p1 = plot(source_data1(source_data1(:, 3) > 0, 1), ...
        source_data1(source_data1(:, 3) > 0, 2), 'r.', ...
        source_data2(source_data2(:, 3) > 0, 1), ...
        source_data2(source_data2(:, 3) > 0, 2), 'b.', ...
        arrow_data1(:, 1), arrow_data1(:, 2), 'ro', ...
        arrow_data2(:, 1), arrow_data2(:, 2), 'bo'); axis equal; hold on;
    p2 = plot(left1(left1(:, 3) > 0, 1), left1(left1(:, 3) > 0, 2) + 40, 'r.', ...
        right1(right1(:, 3) > 0, 1), right1(right1(:, 3) > 0, 2) + 40, 'r.', ...
        left2(left2(:, 3) > 0, 1), left2(left2(:, 3) > 0, 2) + 40, 'b.', ...
        right2(right2(:, 3) > 0, 1), right2(right2(:, 3) > 0, 2) + 40, 'b.', ...
        merged(:, 1), merged(:, 2) + 40, 'g*');
    p3 = plot(left1_t(left1_t(:, 3) > 0, 1), left1_t(left1_t(:, 3) > 0, 2) + 80, 'r.', ...
        right1_t(right1_t(:, 3) > 0, 1), right1_t(right1_t(:, 3) > 0, 2) + 80, 'r.', ...
        left2_t(left2_t(:, 3) > 0, 1), left2_t(left2_t(:, 3) > 0, 2) + 80, 'b.', ...
        right2_t(right2_t(:, 3) > 0, 1), right2_t(right2_t(:, 3) > 0, 2) + 80, 'b.', ...
        merged(:, 1), merged(:, 2) + 80, 'g*');
    
    h1 = legend(p1, {'new data 1', 'new data 2', 'landmark 1', 'landmark 2'});
    set(h1, 'Box', 'off', 'Position', [0.5, 0.2, 0.01, 0.01]);
    axesh1 = axes('position', get(gca, 'position'), ...
        'visible', 'off');
    h2 = legend(axesh1, p2, {'data 1 translation/rotation/scaling', ...
        'data 2 translation/rotation/scaling', 'aligned landmarks'});
    set(h2, 'Box', 'off', 'Position', [0.5, 0.55, 0.01, 0.01]);
    axesh2 = axes('position', get(gca, 'position'), ...
        'visible', 'off');
    h3 = legend(axesh2, p3, {'data 1 translation/rotation/scaling with rotation noise', ...
        'data 2 translation/rotation/scaling with rotation noise', 'aligned landmarks'});
    set(h3, 'Box', 'off', 'Position', [0.5, 0.85, 0.01, 0.01]);
    hold off;
 end
end