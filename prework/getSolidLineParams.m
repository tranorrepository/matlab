function solidLineParams = getSolidLineParams(data, solidBlkIndex)
% SOLIDLINEPARAMS
%


items = size(solidBlkIndex, 1);

% center
solidLineC = zeros(items, 3); % x, y, count
solidLineC(:, 3) = (solidBlkIndex(:, 2) - solidBlkIndex(:, 1) + 1);

lengthData = zeros(items, 2);
widthData  = zeros(items, 2);
for i = 1:items
    % center
    solidLineC(i, 1:2) = sum(data(solidBlkIndex(i, 1):solidBlkIndex(i, 2), 1:2)) / solidLineC(i, 3);
    
    % for length calculation
    lengthData(i, :) = data(solidBlkIndex(i, 2), 1:2) - ...
        data(solidBlkIndex(i, 1), 1:2);
    % width
    %     widthData(i, 1) = sum(data(dotBlkIndex(i, 2):dotBlkIndex(i, 2), dotLineIndex + 3) - ...
    %                           data(dotBlkIndex(i, 2):dotBlkIndex(i, 2), dotLineIndex + 1));
    %     widthData(i, 2) = sum(data(dotBlkIndex(i, 2):dotBlkIndex(i, 2), dotLineIndex + 4) - ...
    %                           data(dotBlkIndex(i, 2):dotBlkIndex(i, 2), dotLineIndex + 2));
end

% angle
theta = angle(lengthData(:, 1) + lengthData(:, 2)*1j);

% length
length = zeros(items, 1);
lengthData = lengthData .* lengthData;
length(:) = sqrt(lengthData(:, 1) + lengthData(:, 2));

% width
width = zeros(items, 1);
widthData = widthData .* widthData;
width(:) = sqrt(widthData(:, 1) + widthData(:, 2));

solidLineParams = [solidLineC, length, width, theta];

