function roadPaintData = roadScanImageProc(lanePoints, gpsAndIntervalMiddle, configInfo, publicFunctions, centerWidth)

% calculte reference gps location of paint and line points
% input - lanePoints : paint and line points
%         gpsAndIntervalMiddle : gps now, gps next and interval
%         configInfo : config file
%         publicFunctions : handle of public functions
%         centerWidth : center of road scan image width
% output - roadPaintData : reference gps location
%      leftRefGPS - isPaintLeft - middleRefGPS - rightRefGPS - isPaintRight
%      paint - 1, line - 0, else - -1

% data struct of gps and interval
for index = 1 : size(gpsAndIntervalMiddle, 1)
    gpsAndInterval{index}.gpsNow = publicFunctions.coordinateChange([gpsAndIntervalMiddle(index,1) gpsAndIntervalMiddle(index,2)], configInfo.GPSref);
    gpsAndInterval{index}.gpsNext = publicFunctions.coordinateChange([gpsAndIntervalMiddle(index,3) gpsAndIntervalMiddle(index,4)], configInfo.GPSref);
    gpsAndInterval{index}.interval = gpsAndIntervalMiddle(index,5);
end

% calculate reference GPS location of paint and line points
startPoint = 1;

for index = 1 : length(gpsAndInterval)
    endPoint = startPoint + gpsAndInterval{index}.interval - 1;
    
    if (endPoint > length(lanePoints))
        error('calculate reference GPS location beyond size.');
    end
    
    for i = startPoint : endPoint
        roadPaintData{i} = calRefGPSLocation(gpsAndInterval{index}, lanePoints{i}, i - startPoint, configInfo, centerWidth);
    end
    
    startPoint = endPoint + 1;
end

end% function of roadScanImageProc

function roadPaintData = calRefGPSLocation(gpsAndInterval, lanePoints, yCoordinate, configInfo, centerWidth)

% calculate reference GPS location of paint and line points
% input - gpsAndInterval : gps now, gps next and interval
%         paintPoints : left point, right point and flag
%         yCoordinate : y coordinate of intercept image
%                       x coordinate is given by paintPoints
%         configInfo : config file
%         centerWidth : center of x coordinate
% output - roadPaintData : reference GPS location of left, middle and right
%                          points with flag

% left point
if (lanePoints.isPaintLeft ~= -1)
    % 0 - line, 1 - paint, line or paint
    pixelLeft = [lanePoints.leftPoint(1) - centerWidth yCoordinate];
    roadPaintData.leftRefGPS = calRefGPSLocEachPoint(gpsAndInterval, pixelLeft, configInfo);
else
    roadPaintData.leftRefGPS = [0 0];
end
roadPaintData.isPaintLeft = lanePoints.isPaintLeft;

% middle point
pixelMiddle = [0 yCoordinate];
roadPaintData.middleRefGPS = calRefGPSLocEachPoint(gpsAndInterval, pixelMiddle, configInfo);

% right point
if (lanePoints.isPaintRight ~= -1)
    % 0 - line, 1 - paint, line or paint
    pixelRight = [lanePoints.rightPoint(1) - centerWidth yCoordinate];
    roadPaintData.rightRefGPS = calRefGPSLocEachPoint(gpsAndInterval, pixelRight, configInfo);
else
    roadPaintData.rightRefGPS = [0 0];
end
roadPaintData.isPaintRight = lanePoints.isPaintRight;

end% function of calRefGPSLocation

function refGPS = calRefGPSLocEachPoint(gpsAndInterval, pixel, configInfo)

% calculate reference GPS of each point
% input - gpsAndInterval : gps now, gps next and interval
%         pixel : pixel location
%         configInfo : config file
% output - refGPS : reference GPS location of pixel

if (gpsAndInterval.interval < 1)
    error('scope of scan image empty.');
end

angle  = atan2(gpsAndInterval.gpsNext(2) - gpsAndInterval.gpsNow(2), gpsAndInterval.gpsNext(1) - gpsAndInterval.gpsNow(1));
t = 3.14159265359 * 1.5 + angle;

% coordinate system 2
x2 = -1.0 * pixel(1) * configInfo.distancePerPixel / 100;
y2 = pixel(2) * configInfo.distancePerPixel / 100;

% coordinate system 1
refGPS(1) = x2 * cos(t) - y2 * sin(t) + gpsAndInterval.gpsNow(1);
refGPS(2) = x2 * sin(t) + y2 * cos(t) + gpsAndInterval.gpsNow(2);

end% function of calRefGPSLocEachPoint