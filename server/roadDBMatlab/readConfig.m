function config = readConfig(fconfig)

% load config file of each video
% input - fconfig : path of config file
% output - config : config struct

config.centerPoint = zeros(1,2);
config.lengthRate =0;
config.distanceOfSlantLeft = 0;
config.distanceOfSlantRight = 0;
config.distanceOfUpMove = 0;
config.distanceOfLeft = 0;
config.distanceOfRight = 0;
config.ridgeThreshold = 0;
config.stretchRate = 0;
config.downSampling = 0;
config.distancePerPixel = 0;
config.GPSref = zeros(1,2);
config.imageScaleHeight = 0;
config.imageScaleWidth = 0;
config.imageRows = 0;
config.imageCols = 0;
config.discardRoadDataAfterLaneChange = 0;

while ~feof(fconfig)
   str = fscanf(fconfig,'%s',1); 
   if strcmp(str , 'centerPoint:')
       config.centerPoint(1,1) = fscanf(fconfig,'%f',1);
       config.centerPoint(1,2) = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'lengthRate:')
       config.lengthRate = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'distanceOfSlantLeft:')
       config.distanceOfSlantLeft = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'distanceOfSlantRight:')
       config.distanceOfSlantRight = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'distanceOfUpMove:')
       config.distanceOfUpMove = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'distanceOfLeft:')
       config.distanceOfLeft = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'distanceOfRight:')
       config.distanceOfRight = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'ridgeThreshold:')
       config.ridgeThreshold = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'stretchRate:')
       config.stretchRate = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'downSampling:')
       config.downSampling = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'distancePerPixel:')
       config.distancePerPixel = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'GPSref:')
       config.GPSref(1,1) = fscanf(fconfig,'%f',1);
       config.GPSref(1,2) = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'imageScaleHeight:')
       config.imageScaleHeight = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'imageScaleWidth:')
       config.imageScaleWidth = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'imageRows:')
       config.imageRows = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'imageCols:')
       config.imageCols = fscanf(fconfig,'%f',1);
   elseif strcmp(str , 'discardRoadDataAfterLaneChange:')
       config.discardRoadDataAfterLaneChange = fscanf(fconfig,'%f',1);      
   end
end

end% function of readConfig