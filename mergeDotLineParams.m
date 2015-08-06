function [dotLineParams, moveVector] = mergeDotLineParams(dotLineParams0, dotLineParams1)
% MERGEDOTLINEPARAMS
%   merge two dotted line
%
%   INPUT:
%
%     dotLineParams0, dotLineParams1
%     formated data structure
%       (center x, center y, points count, length, width, theta)
%
%   OUTPUT:
%
%     dotLineParams - merged dotted line parameters, the same format as input
%     moveVector - center point move vector of input data
%
%   Just merge the closest center points
%

items0 = size(dotLineParams0, 1);
items1 = size(dotLineParams1, 1);

itemsMin = items0;
itemsMax = items1;
dotLineParamsMin = dotLineParams0;
dotLineParamsMax = dotLineParams1;
if (items0 > items1)
    itemsMin = items1;
    itemsMax = items0;
    dotLineParamsMin = dotLineParams1;
    dotLineParamsMax = dotLineParams0;
end

% find the match center point index
matchIndex  = zeros(itemsMin, 1);
tmpDistData = ones(itemsMax, 2);
for i = 1:itemsMin
    tmpDistData(:, :) = 1;
    tmpDistData(:, 1) = tmpDistData(:, 1) * dotLineParamsMin(i, 1);
    tmpDistData(:, 2) = tmpDistData(:, 2) * dotLineParamsMin(i, 2);
    distData = tmpDistData(:, 1:2) - dotLineParamsMax(:, 1:2);
    distData = distData .* distData;
    dist = distData(:, 1) + distData(:, 2);
    [~, minDistIndex] = min(dist);
    matchIndex(i) = minDistIndex;
end

% merge the center point
dotLineParams = zeros(itemsMin, 6);

% move vector - (1, 2): 0 -> C, (3, 4): 1 -> C
moveVector = zeros(itemsMin, 4);

for i = 1:itemsMin
    j = matchIndex(i);
    cnt0 = dotLineParamsMin(i, 3);
    cnt1 = dotLineParamsMax(j, 3);
    % center
    dotLineParams(i, 1:2) = (cnt0 * dotLineParamsMin(i, 1:2) + ...
                             cnt1 * dotLineParamsMax(j, 1:2)) / ...
                             (cnt0 + cnt1);


	% move vector
    if (items0 > items1)
        moveVector(i, 1:2) = dotLineParams(i, 1:2) - dotLineParamsMax(j, 1:2);
        moveVector(i, 3:4) = dotLineParams(i, 1:2) - dotLineParamsMin(i, 1:2);
    else
        moveVector(i, 1:2) = dotLineParams(i, 1:2) - dotLineParamsMin(i, 1:2);
        moveVector(i, 3:4) = dotLineParams(i, 1:2) - dotLineParamsMax(j, 1:2);
    end
    
	% plot matched center point
    plot([dotLineParamsMin(i, 2), dotLineParamsMax(j, 2)], ...
         [dotLineParamsMin(i, 1), dotLineParamsMax(j, 1)], 'k');
    hold on
    
    % count
    dotLineParams(i, 3) = cnt0 + cnt1;
    
    % length and width
    dotLineParams(i, 4:5) = (cnt0 * dotLineParamsMin(i, 4:5) + ...
                             cnt1 * dotLineParamsMax(j, 4:5)) / ...
                             (cnt0 + cnt1);

	% angle
    dotLineParams(i, 6) = angle(dotLineParamsMin(i, 4) * exp(1j*dotLineParamsMin(i, 6)) + ...
                                dotLineParamsMin(i, 4) * exp(1j*dotLineParamsMax(j, 6)));
end