%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Continental Confidential
%                  Copyright (c) Continental, LLC. 2015
%
%      This software is furnished under license and may be used or
%      copied only in accordance with the terms of such license.
%
% Change Log:
%      Date                    Who                    What
%      2015/09/11              Ming Chen              Create
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% test for server merging process
clear variables
% close all
clc

addpath('..\data');
addpath('..\mergeData');
addpath('..\segData');
addpath('C:\Users\Ming.Chen\Desktop\results\09_04_1');

cfgname = '..\config\DE_Airport_manualSeg.txt';

global PLOT_ON
PLOT_ON = 1;

if PLOT_ON
    clf(figure(300));
    clf(figure(301));
    clf(figure(400));
    clf(figure(501));
    clf(figure(600));
    clf(figure(700));
end

% read section configuration file
[segCfg, segCfgList] = readSegCfgFile(cfgname);

% init background / foreground database
bdatabase = struct('segId', 0, 'laneData', []);
fdatabase = struct('segId', 0, 'lineData', []);
for kk = 1:segCfg.segNum
    bdatabase(kk).segId = segCfgList(kk).segId;
    fdatabase(kk).segId = segCfgList(kk).segId;
end

%
newData = struct('segId', 0, ...
                 'lineData', struct('x', 0.0, 'y', 0.0, 'paint', 0.0, 'count', 0));

for ii =  0:100
    ii
    for SegID = 1:21
        if SegID == 11
            continue;
        end
        newData.segId = SegID;
        formatSpec = 'fg_%d_sec_%d_group_0_lane_0.txt';
        str = sprintf(formatSpec, ii, SegID);
        if exist(str,'file')
            fileID = fopen(str,'r');
            formatSpec = '%f,%f,%f';
            A = fscanf(fileID, formatSpec);
            fclose(fileID);
            
            m = length(A);
            A = reshape(A, 3, m/3)';
            n = size(A, 1);
            
            % first line
            index = 1:(n / 2);
            newData.lineData(1).x = A(index, 1);
            newData.lineData(1).y = A(index, 2);
            newData.lineData(1).paint = A(index, 3);
            newData.lineData(1).count = 0;
            
            % second line
            index = (n / 2 + 1):n;
            newData.lineData(2).x = A(index, 1);
            newData.lineData(2).y = A(index, 2);
            newData.lineData(2).paint = A(index, 3);
            newData.lineData(2).count = 0;
            
            [theta, X] = calcRotAngleAndRange(segCfgList, SegID);
            DB = generateBDatabase(segCfgList(SegID), ...
                                   bdatabase(SegID), ...
                                   newData, ...
                                   theta, X);
            if ~isempty(DB)
                
                bdatabase(SegID).laneData = DB.laneData;
                
                FDB = generateFDatabase(DB, theta, X);
                fdatabase(SegID) = FDB;
                
                % joint adjacent section connection
                fdatabase = jointProcessing(fdatabase);
                
                figure(700)
                subplot(1, 2, 1); hold off;
                
                % for each segment
                for sec = 1: segCfg.segNum
                    % For drawing only.
                    FDB = fdatabase(sec);
                    if ~isempty(FDB.lineData)
                        numOfLines = size(FDB.lineData, 1);
                        
                        for ll = 1:numOfLines
                            line = FDB.lineData{ll};
                            
                            if ~isempty(line)
                                ind =  (line.paint / max(line.paint)) >= 0.5;
                                subplot(1, 2, 1)
                                plot(line.x(ind), line.y(ind), '.', ...
                                    line.x, line.y, '-');
                                hold on; axis equal; grid on
                                title(['FDB: Full loop = ' num2str(ii)]);
                            end
                        end
                    end
                end
                
                figure(700)
                subplot(1, 2, 2); hold off
                
                % for current section.
                FDB = fdatabase(SegID);
                if ~isempty(FDB.lineData)
                    numOfLines = size(FDB.lineData, 1);
                    for ll = 1:numOfLines
                        line = FDB.lineData{ll};
                        
                        if ~isempty(line)
                            ind =  (line.paint / max(line.paint)) >= 0.5;
                            plot(line.x(ind), line.y(ind), '.', ...
                                line.x, line.y, '-');
                            hold on; grid on
                            title(['FDB: SecID = ' num2str(SegID)]);
                        end
                    end
                    
                    subplot(1, 2, 2)
                    axis equal; hold off;
                end
            end
            pause(0.1);
        end
    end
end

