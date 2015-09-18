clc;
clear all;close all;
clc;

for fileIndex = [0]
    fid = fopen(['referenceGPSLocation_' num2str(fileIndex) '.txt'], 'r');
    row = 0;
    while ~feof(fid)
        row = row+sum(fread(fid,10000,'*char')==char(10));
    end
    fclose(fid);

    %get data
    fid = fopen(['referenceGPSLocation_' num2str(fileIndex) '.txt'], 'r');
    Data = zeros(8, row);
    lineIdx = 1;
    while ~feof(fid)
        fileLine = fscanf(fid, '%f %f %d %f %f %f %f %d', 8);
        if ~isempty(fileLine)
            Data(:, lineIdx) = fileLine;
            lineIdx = lineIdx + 1;
        else
            break;
        end
    end
    fclose(fid);
    
    eval(['xLeft' num2str(fileIndex) ' = Data(1,:);']);
    eval(['yLeft' num2str(fileIndex) ' = Data(2,:);']);
    
    eval(['xMiddle' num2str(fileIndex) ' = Data(4,:);']);
    eval(['yMiddle' num2str(fileIndex) ' = Data(5,:);']);
    
    eval(['xRight' num2str(fileIndex) ' = Data(6,:);']);
    eval(['yRight' num2str(fileIndex) ' = Data(7,:);']);
    
    eval(['leftMark' num2str(fileIndex) ' = Data(3, :);']);
    eval(['rightMark' num2str(fileIndex) ' = Data(8, :);']);
end

figure(1);
hold on;

plot(xLeft0(leftMark0 == 1), yLeft0(leftMark0 == 1), 'r.');
plot(xRight0(rightMark0 == 1), yRight0(rightMark0 == 1), 'g.');

hold off;

axis equal;