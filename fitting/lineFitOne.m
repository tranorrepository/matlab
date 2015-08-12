function [leftRefGPS rightRefGPS] = lineFitOne(leftRefGPS, rightRefGPS, index)

middleLeftRefGPS = [];
middleRightRefGPS = [];

% fitting method 1
leftNeedFitting = 1;
leftFittingTimes = 1;
while(leftNeedFitting)
    [fLeft sLeft] = polyfit(leftRefGPS(:,2), leftRefGPS(:,1), leftFittingTimes);
    
    if((sLeft.normr < 20) || (leftFittingTimes >= 10))
        leftNeedFitting = 0;
    end
    
    leftFittingTimes = leftFittingTimes+1;
end

rightNeedFitting = 1;
rightFittingTimes = 1;
while(rightNeedFitting)
    [fRight sRight] = polyfit(rightRefGPS(:,2), rightRefGPS(:,1), rightFittingTimes);
    
    if((sRight.normr < 20) || (rightFittingTimes >= 10))
        rightNeedFitting = 0;
    end
    
    rightFittingTimes = rightFittingTimes+1;
end

% % fitting method 2
% fittingTimes = 4;
% [fLeft sLeft] = polyfit(leftRefGPS(:,1), leftRefGPS(:,2), fittingTimes);
% [fRight sRight] = polyfit(rightRefGPS(:,1), rightRefGPS(:,2), fittingTimes);

if(index == 1)
    % test
    xIntervalMin = min(min(leftRefGPS(:,1)), min(rightRefGPS(:,1)));
    xIntervalMax = max(max(leftRefGPS(:,1)), max(rightRefGPS(:,1)));

    X = [xIntervalMin : 0.1 : xIntervalMax];

    leftPoints = polyval(fLeft, X);
    rightPoints = polyval(fRight, X);

    figure(index);
    hold on;

    plot(leftRefGPS(:,2), leftRefGPS(:,1), 'r.');
    plot(rightRefGPS(:,2), rightRefGPS(:,1), 'r.');

    plot(leftPoints, X, 'g-');
    plot(rightPoints, X, 'g-');

    hold off;
end

axis equal;

%exclude points
excludeThreshold = 0.5;

judgeLeft = 0;
judgeRight = 0;
judgePointsLeft = [];
judgePointsRight = [];

if(size(leftRefGPS,1) > 0)
    judgeLeft = leftRefGPS(1, 3);
end

if(size(rightRefGPS,1) > 0)
    judgeRight = rightRefGPS(1, 3);
end

i = 1;
while(i <= size(leftRefGPS,1))
    if(leftRefGPS(i, 3) == judgeLeft)
        judgePointsLeft = [judgePointsLeft;leftRefGPS(i, :)];
    else
        if(size(judgePointsLeft,1) > 0)
            xCenter = mean(judgePointsLeft(:,1));
            yCenter = mean(judgePointsLeft(:,2));
            
            xMin = min(judgePointsLeft(:,1));
            xMax = max(judgePointsLeft(:,1));
            
            distance = ((xCenter - xMin)^2 + (yCenter - polyval(fLeft, xMin))^2)^0.5;
            for x = xMin : 0.1 : xMax
                if(((xCenter - x)^2 + (yCenter - polyval(fLeft, x))^2)^0.5 < distance)
                    distance = ((xCenter - x)^2 + (yCenter - polyval(fLeft, x))^2)^0.5;
                end
            end
            
            if((distance > 5) || (distance < excludeThreshold))
                middleLeftRefGPS = [middleLeftRefGPS;judgePointsLeft];
            else
                distance
            end
        end
        
        judgePointsLeft = [];
        
        if(i < size(leftRefGPS,1))
            judgeLeft = leftRefGPS(i,3);
        end
        i = i-1;
    end
    
    if(i == size(leftRefGPS,1))
        if(size(judgePointsLeft,1) > 0)
            xCenter = mean(judgePointsLeft(:,1));
            yCenter = mean(judgePointsLeft(:,2));
            
            xMin = min(judgePointsLeft(:,1));
            xMax = max(judgePointsLeft(:,1));
            
            distance = ((xCenter - xMin)^2 + (yCenter - polyval(fLeft, xMin))^2)^0.5;
            for x = xMin : 0.1 : xMax
                if(((xCenter - x)^2 + (yCenter - polyval(fLeft, x))^2)^0.5 < distance)
                    distance = ((xCenter - x)^2 + (yCenter - polyval(fLeft, x))^2)^0.5;
                end
            end
            
            if((distance > 5) || (distance < excludeThreshold))
                middleLeftRefGPS = [middleLeftRefGPS;judgePointsLeft];
            else
                distance
            end
        end
        
        judgePointsLeft = [];
        
        if(i < size(leftRefGPS,1))
            judgeLeft = leftRefGPS(i,3);
        end
    end
    
    i = i+1;
end

i = 1;
while(i <= size(rightRefGPS,1))
    if(rightRefGPS(i, 3) == judgeRight)
        judgePointsRight = [judgePointsRight;rightRefGPS(i, :)];
    else
        if(size(judgePointsRight,1) > 0)
            xCenter = mean(judgePointsRight(:,1));
            yCenter = mean(judgePointsRight(:,2));
            
            xMin = min(judgePointsRight(:,1));
            xMax = max(judgePointsRight(:,1));
            
            distance = ((xCenter - xMin)^2 + (yCenter - polyval(fRight, xMin))^2)^0.5;
            for x = xMin : 0.1 : xMax
                if(((xCenter - x)^2 + (yCenter - polyval(fRight, x))^2)^0.5 < distance)
                    distance = ((xCenter - x)^2 + (yCenter - polyval(fRight, x))^2)^0.5;
                end
            end

            if((distance > 5) || (distance < excludeThreshold))
                middleRightRefGPS = [middleRightRefGPS;judgePointsRight];
            else
                distance
            end
        end
        
        judgePointsRight = [];
        
        if(i < size(rightRefGPS,1))
            judgeRight = rightRefGPS(i,3);
        end
        
        i = i-1;
    end
    
    if(i == size(rightRefGPS,1))
        if(size(judgePointsRight,1) > 0)
            xCenter = mean(judgePointsRight(:,1));
            yCenter = mean(judgePointsRight(:,2));
            
            xMin = min(judgePointsRight(:,1));
            xMax = max(judgePointsRight(:,1));
            
            distance = ((xCenter - xMin)^2 + (yCenter - polyval(fRight, xMin))^2)^0.5;
            for x = xMin : 0.1 : xMax
                if(((xCenter - x)^2 + (yCenter - polyval(fRight, x))^2)^0.5 < distance)
                    distance = ((xCenter - x)^2 + (yCenter - polyval(fRight, x))^2)^0.5;
                end
            end
            
            if((distance > 5) || (distance < excludeThreshold))
                middleRightRefGPS = [middleRightRefGPS;judgePointsRight];
            else
                distance
            end
        end
        
        judgePointsRight = [];
        
        if(i < size(rightRefGPS,1))
            judgeRight = rightRefGPS(i,3);
        end
    end
    i = i+1;
end

% test
xIntervalMin = min(min(middleLeftRefGPS(:,1)), min(middleRightRefGPS(:,1)));
xIntervalMax = max(max(middleLeftRefGPS(:,1)), max(middleRightRefGPS(:,1)));

X = [xIntervalMin : 0.1 : xIntervalMax];

leftPoints = polyval(fLeft, X);
rightPoints = polyval(fRight, X);

figure(index+1);
hold on;

plot(middleLeftRefGPS(:,2), middleLeftRefGPS(:,1), 'r.');
plot(middleRightRefGPS(:,2), middleRightRefGPS(:,1), 'r.');

plot(leftPoints, X, 'g-');
plot(rightPoints, X, 'g-');

hold off;

axis equal;

leftRefGPS = middleLeftRefGPS;
rightRefGPS = middleRightRefGPS;