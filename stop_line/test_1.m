clear variables; clc;

clf(figure(801));
for ii = 20:40
    lm_format = sprintf('./data/landmarker_%d.txt', ii);
    pd_format = sprintf('./data/paintingData_%d.txt', ii);
    if exist(lm_format, 'file') && exist(pd_format, 'file')
        fid = fopen(lm_format, 'r');
        A = fscanf(fid, '%f %f %f %f');
        fclose(fid);
        
        m = length(A);
        eval(['lm_source' num2str(ii) ' = reshape(A, 5, m/5)'';']);
        eval(['lm_data' num2str(ii) '.x = lm_source' num2str(ii) '(:, 2);']);
        eval(['lm_data' num2str(ii) '.y = lm_source' num2str(ii) '(:, 1);']);
        eval(['lm_data' num2str(ii) '.g = lm_source' num2str(ii) '(:, 5);']);
        
        fid = fopen(pd_format, 'r');
        A = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
        fclose(fid);
        
        m = length(A);
        eval(['pd_source' num2str(ii) ' = reshape(A, 19, m/19)'';']);
        eval(['pd_data_left.x = pd_source' num2str(ii) '(:, 2);']);
        eval(['pd_data_left.y = pd_source' num2str(ii) '(:, 1);']);
        eval(['pd_data_left.p = pd_source' num2str(ii) '(:, 3);']);
        eval(['pd_data_right.x = pd_source' num2str(ii) '(:, 13);']);
        eval(['pd_data_right.y = pd_source' num2str(ii) '(:, 12);']);
        eval(['pd_data_right.p = pd_source' num2str(ii) '(:, 14);']);
        
        figure(801);
        eval(['plot(lm_data' num2str(ii) '.x, lm_data' num2str(ii) '.y, ''b.'')']); hold on; axis equal;
        plot(pd_data_left.x(pd_data_left.p > 0), pd_data_left.y(pd_data_left.p > 0), 'g.');
        plot(pd_data_right.x(pd_data_right.p > 0), pd_data_right.y(pd_data_right.p > 0), 'r.');
        hold off;
        title(['Source ' num2str(ii)]);
    end
    
    pause(0.1);
end