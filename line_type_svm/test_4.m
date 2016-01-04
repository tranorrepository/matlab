

for ii = 0:10
    for segId = 1:11
        formatSpec = 'C:/Projects/source/newco_demo/Demo/Ford/server/server/fg_%d_sec_%d_group_0_lane_0.txt';
        str = sprintf(formatSpec, ii, segId);
        % formatSpec = 'C:/Projects/source/newco_demo/Demo/Ford/server/server/fgroup_%d.txt';
        % formatSpec = 'C:/Projects/source/newco_demo/Demo/Ford/server/server/fg_%d_section_4_merged.txt';
        % str = sprintf(formatSpec, ii);
        if exist(str,'file')
            fileID = fopen(str, 'r');
            formatSpec = '%f,%f,%f';
            A = fscanf(fileID, formatSpec);
            fclose(fileID);
            
            m = length(A);
            data = reshape(A, 3, m/3)';
            
            figure(100)
            plot(data(data(:, 3) > 0, 1), data(data(:, 3) > 0, 2), 'r.');
            hold on;
            % plot(data(data(:, 3) == 0, 1), data(data(:, 3) == 0, 2), 'g.');
            axis equal;
            title(num2str(ii));
            
            pause(1);
        end
    end
    hold off;
end