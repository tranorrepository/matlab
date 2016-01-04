
figure(101)
for ii = 0:40
    formatSpec = 'C:/Users/Ming.Chen/Desktop/results/10_27_0/fg_%d_source_handled.txt';
    str = sprintf(formatSpec, ii);
    if exist(str,'file')
        fileID = fopen(str, 'r');
        formatSpec = '%f,%f,%f,%f';
        A = fscanf(fileID, formatSpec);
        fclose(fileID);
        
        m = length(A);
        eval(['source' num2str(ii) ' = reshape(A, 4, m/4)'';']);
        eval(['data = source' num2str(ii) ';']);
        
        pnts = m / 4;
        % plot(data(data(:, 3) > 0, 1), data(data(:, 3) > 0, 2) + 80 * ii, '.'); hold on; axis equal;
        plot(data((end - pnts / 3 + 1):end, 1), data((end - pnts / 3 + 1):end, 2) + 80 * ii, '.');
        hold on; axis equal;
        plot(data(:, 1), data(:, 2) + 80 * ii, 'k.');
        plot(data(data(:, 3) > 0, 1), data(data(:, 3) > 0, 2) + 80 * ii, '.');
%         
%         plot(sec12(:, 1:2:3), sec12(:, 2:2:4) + 75 * ii, 'r*', 'MarkerSize', 5);
%         plot(sec12(:, 5:2:7), sec12(:, 6:2:8) + 75 * ii, 'go', 'MarkerSize', 5);
        
        title(['Source ' num2str(ii)]);
    end
    
    pause(1);
end

hold off;