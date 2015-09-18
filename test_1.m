%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Continental Confidential
%                  Copyright (c) Continental, LLC. 2015
%
%      This software is furnished under license and may be used or
%      copied only in accordance with the terms of such license.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% videoFReader   = vision.VideoFileReader('C:\Projects\datavideo\airport2\cam_20150811111511.mp4');
% depVideoPlayer = vision.DeployableVideoPlayer;
% 
% cont = ~isDone(videoFReader);
% while cont
%     frame = step(videoFReader);
%     step(depVideoPlayer, frame);
%     cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
% end

% videoFReader = vision.VideoFileReader('C:\Projects\datavideo\airport2\cam_20150811111511.mp4');
% videoPlayer = vision.VideoPlayer;
% while ~isDone(videoFReader)
%   videoFrame = step(videoFReader);
%   step(videoPlayer, videoFrame);
% end
% release(videoPlayer);
% release(videoFReader);


% xyloObj = VideoReader('C:\Projects\datavideo\airport2\cam_20150811111511.mp4');
% vidWidth = xyloObj.Width;
% vidHeight = xyloObj.Height;

% mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
%     'colormap',[]);
% 
% k = 1;
% while hasFrame(xyloObj)
%     mov(k).cdata = readFrame(xyloObj);
%     k = k+1;
%     
%     if k > 1000
%         break;
%     end
% end
% 
% 
% hf = figure;
% set(hf,'position',[150 150 vidWidth vidHeight]);
% 
% movie(hf,mov,1,xyloObj.FrameRate);


xyloObj = VideoReader('C:\Projects\datavideo\airport2\cam_20150811111511.mp4');
vidWidth = xyloObj.Width;
vidHeight = xyloObj.Height;

pnts = [100, 330; 480, 330; 1, 360; 640, 360];

% while hasFrame(xyloObj)
%     frame = readFrame(xyloObj);
%     scaleframe = imresize(frame, 0.5);
%     bwframe = im2bw(scaleframe, 0.5);
%     hist = sum(bwframe, 2);
%     shist = hist(2:end) - hist(1:end-1);
%     [~, row] = max(shist);
%     scaleframe(row + 1, :, 1) = 255;
%     scaleframe(row + 1, :, 2) = 0;
%     scaleframe(row + 1, :, 3) = 0;
%     scaleframe(index, :, 1) = 0;
%     scaleframe(index, :, 2) = 255;
%     scaleframe(index, :, 3) = 0;
%     
%     imshow(scaleframe);
    
%     frame = readFrame(xyloObj);
%     scaleframe = imresize(frame, 0.5);
%     scaleframe(318:320, 300, 1) = 255;
%     scaleframe(318:320, 300, 2) = 0;
%     scaleframe(318:320, 300, 3) = 0;
%     
%     figure(2); imshow(scaleframe);
% end

configInfo.imageRows = 720;
configInfo.imageCols = 1280;
configInfo.centerPoint = [319, 100];
configInfo.imageScaleWidth = 0.5;
configInfo.imageScaleHeight = 0.5;
configInfo.distanceOfSlantLeft = 60;
configInfo.distanceOfSlantRight = 0;
configInfo.lengthRate = 27.1804;
configInfo.distanceOfUpMove = 0;
configInfo.distanceOfLeft = 0;
configInfo.distanceOfRight = 0;

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

% 
% tfm = fitgeotrans(imgPts, objPts, 'projective');
% wfm = imwarp(grayframe, tfm);
tfm = cp2tform(imgPts, objPts, 'projective');
wfm = imtransform(grayframe, tfm, 'XData', [1 640], 'YData', [1, 1080]);

figure(1); imshow(wfm);