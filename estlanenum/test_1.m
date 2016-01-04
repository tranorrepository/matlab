% 

clf(figure(220))
for ii = 0:90
    lane_format = sprintf('C:/Users/Ming.Chen/Desktop/results/11_13_1/fg_%d_source.txt', ii);
    side_lane_format = sprintf('C:/Users/Ming.Chen/Desktop/results/11_13_1/fgdatabase_merged_%d.txt', ii);
    if exist(lane_format, 'file') && exist(side_lane_format, 'file')
        lane_data = load(lane_format);
        side_lane_data = load(side_lane_format);
        line.x = lane_data(:, 1);
        line.y = lane_data(:, 2);
        line.p = lane_data(:, 3);
                
        plot(line.x(line.p > 0), line.y(line.p > 0), 'r.'); axis equal; hold on;
%         plot(line.x(line.p <= 0), line.y(line.p <= 0), 'k.'); hold off;

        if ~isempty(side_lane_data)
            side_line.x = side_lane_data(:, 1);
            side_line.y = side_lane_data(:, 2);
            side_line.p = side_lane_data(:, 3);

            plot(side_line.x(side_line.p > 0), ...
                side_line.y(side_line.p > 0), 'b.');
        end
        
        hold off; title(['data group ' num2str(ii)]);
        pause(0.1);
    end
end