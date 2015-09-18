function [H, invertH] = calculateHAndInvertH(configInfo)

% calculate H and invert H for generate birds view from original image
% input - configInfo : config file
% output - H : from original image to birds view
%          invertH :  from birds view to original image

% projection transform
w = configInfo.imageCols * configInfo.imageScaleWidth;
h = configInfo.imageRows * configInfo.imageScaleHeight;

A = [1 h];
B = [w h];

imgPts = [(configInfo.centerPoint(1)+A(1))/2-configInfo.distanceOfSlantLeft  (configInfo.centerPoint(2)+A(2))/2;
          (configInfo.centerPoint(1)+B(1))/2+configInfo.distanceOfSlantRight (configInfo.centerPoint(2)+B(2))/2;
          A(1)                                                               A(2);
          B(1)                                                               B(2)];

scale = 1;
xoff = 2*w/10;
hh = scale*(A(2) -imgPts(1,2))/2;
      
objPts = [6*scale*A(1)/10+xoff-configInfo.distanceOfLeft   A(2)*scale+configInfo.distanceOfUpMove;
          6*scale*B(1)/10+xoff+configInfo.distanceOfRight  A(2)*scale+configInfo.distanceOfUpMove;
          6*scale*A(1)/10+xoff-configInfo.distanceOfLeft   scale*A(2)+hh*(configInfo.lengthRate+1)+configInfo.distanceOfUpMove;
          6*scale*B(1)/10+xoff+configInfo.distanceOfRight  scale*B(2)+hh*(configInfo.lengthRate+1)+configInfo.distanceOfUpMove];

H = cp2tform(imgPts, objPts, 'projective');
invertH = cp2tform(objPts, imgPts, 'projective');

end% calculateHAndInvertH