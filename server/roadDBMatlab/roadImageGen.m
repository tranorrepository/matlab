function [history, gpsAndInterval] = ...
    roadImageGen(video, gpsDataAbs, gpsDataNext, configInfo, H, history, gpsAndInterval, publicFunctions)

% get birds view of original image, interception birds view for road scan
% the input original image has been resized
% input - video : original image
%         gpsDataAbs : current frame gps
%         gpsDataNext :  next frame gps
%         configInfo : config file
%         H : for get birds view from video
%         history : road scan
%         gpsAndInterval : current gps, next gps, and intercept pixels
% output - history : road scan
%          gpsAndInterval : current gps, next gps, and intercept pixels

% median blur
video = uint8(filter2(fspecial('average',3), video));

% generate birds view
birdsView = generateBirdsView(video, H, configInfo);

GPSAbs = publicFunctions.coordinateChange(gpsDataAbs, configInfo.GPSref);
GPSNext = publicFunctions.coordinateChange(gpsDataNext, configInfo.GPSref);

d = ((GPSAbs(1) - GPSNext(1))^2 + (GPSAbs(2) - GPSNext(2))^2)^0.5;
interval =floor(d/(configInfo.distancePerPixel/100)+0.5);

startLocation = 710;    % change based on different video

if ((startLocation > size(birdsView,1)) || (startLocation-interval < 0))
    error('road scan : extend bird view rows.');
end

if interval > 0
    history = [birdsView(startLocation-interval+1 : startLocation, :);history];
    gpsAndInterval = [gpsAndInterval;gpsDataAbs(1) gpsDataAbs(2) gpsDataNext(1) gpsDataNext(2) interval];
end

end% roadImageGen

function birdsView = generateBirdsView(video, H, configInfo)

% generate birds view from original image
% input - video : original image
%         H : projection transform
%         configInfo : config file
% output - birdsView : birds view of original image

birdsView = imtransform(video, H, 'XData',[1 size(video,2)], 'YData',[1 size(video,1)*configInfo.stretchRate]);

figure(1);
subplot(224);
imshow(birdsView);
title('birds view');

end% generateBirdsView