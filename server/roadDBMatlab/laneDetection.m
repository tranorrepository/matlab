clc;
clear variables;close all;
clc;

warning off all;

figure(1);

%% load config file
% US_Detroit - DE_Airport2
path = 'Airport2';
fconfig = fopen(['config/DE_' path '.txt'],'r');
configInfo = readConfig(fconfig);
fclose(fconfig);

%% calculate H and invert H for birds view
[H, invertH] = calculateHAndInvertH(configInfo);

%% video file list and gps file list
fVideo = fopen([path '/videolist.txt'], 'r');
videoList = textscan(fVideo, '%[^\r\n]');
fclose(fVideo);
fGps = fopen([path '/gpslist.txt'], 'r');
gpsList = textscan(fGps, '%[^\r\n]');
fclose(fGps);

%% load public functions
publicFunctions = loadPublicFunctions();

%% load test functions
testFunctions = loadTestFunctions();

%% load each image, get birds view of it
% generate roadScan image
[row, c] = size(videoList{1, 1});
for videoIndex = 1 : row
    videoPath = videoList{1,1}{videoIndex, 1};
    gpsPath = gpsList{1,1}{videoIndex, 1};
    
    % load each gps location
    fid = fopen(gpsPath);   
    lineIdx = 1;
    gpsData = zeros(0);
    
    while ~feof(fid)
        fileLine = fscanf(fid, '%f, %f ', 2);
        if ~isempty(fileLine)
            gpsData(:, lineIdx) = fileLine;
            lineIdx = lineIdx + 1;
        else
            break;
        end
    end

    % load each image
    videoObj = VideoReader(videoPath);
    numFrames = videoObj.NumberOfFrames;
    vidHeight = videoObj.Height;
    vidWidth = videoObj.Width;
    
    frames = 50;
    history = [];   % road scan image
    gpsAndInterval = [];    % for cal ref GPS of each point
    
    for n = 1 : 1
        if n*frames > numFrames
            break;
        end
        
        start = (n-1)*frames + 1;
        
        for index = start : (start + frames - 1)
            video =  read(videoObj, index);
            
            % if the original image is RGB, turn it to gray
            if numel(size(video)) > 2
                video2 = rgb2gray(video);
            else
                video2 = video;
            end
            
            video2 = imresize(video2, configInfo.imageScaleHeight);
            
            [history, gpsAndInterval] = ...
                roadImageGen(video2, gpsData(:,index), gpsData(:,index+1), configInfo, H, history, gpsAndInterval, publicFunctions);

            figure(1);
            subplot(221)
            imshow(video2);
            title('original image');
            
            figure(1);
            subplot(223)
            imshow(history);
            title('road scan');
            
            
            pause(0.00001);
            
        end% end of each road scan
        imwrite(history, 'roadScan.png');
        
        % change lane detection
        [isChange] = changeLaneDetectin(history);
        
        if isChange == -1
            % procedure of process road scan (history)
            % calculate paint and line points of road scan image
            lanePoints = calLanePointsRoadScan(history);
            roadPaintData = roadScanImageProc(lanePoints, gpsAndInterval, configInfo, publicFunctions, size(history, 2)*0.5);
        end
        
        %% test lane paints
        testFunctions.drawPointsRoadScan(history, lanePoints);
        %% end test
        
        % write reference GPS location of lane to txt file
        fid = fopen('referenceGPSLocation_0.txt', 'a');
        for index = 1 : length(roadPaintData)
            fprintf(fid, '%.10f %.10f %d %.10f %.10f %.10f %.10f %d\n',...
                roadPaintData{index}.leftRefGPS(1), roadPaintData{index}.leftRefGPS(2), roadPaintData{index}.isPaintLeft,...
                roadPaintData{index}.middleRefGPS(1), roadPaintData{index}.middleRefGPS(2),...
                roadPaintData{index}.rightRefGPS(1), roadPaintData{index}.rightRefGPS(2), roadPaintData{index}.isPaintRight);
        end% end write
        fclose(fid);
        
        % clear of road scan and gpsAndInterval
        history = [];
        gpsAndInterval = [];
    end

end% for