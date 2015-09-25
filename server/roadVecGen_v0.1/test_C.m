clear variables
%close all
clc

% addpath('.\data');
% addpath('.\mergeData');

cfgname  = '.\config\US_Detroit_manualSeg.txt';

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
rptData = struct('segId', 0, ...
                 'lineData', struct('x', 0.0, 'y', 0.0, 'paint', 0.0, 'count', 0.0));

segCnt = zeros(segCfg.segNum, 1);

for ii = 0:27
    ii
    for SegID = 25:27 % 1:41
        formatSpec = 'fg_%d_sec_%d_group_0_lane_0.txt';
        str = sprintf(formatSpec,ii,SegID);
        if exist(str,'file')
            fileID = fopen(str,'r');
            formatSpec = '%f,%f,%f';
            A = fscanf(fileID,formatSpec);
            fclose(fileID);
            
            m = length(A);
            data = reshape(A,3,m/3)';
            n = size(data, 1);
            rptData.segId = SegID;
            rptData.lineData(1).x = data(1:n/2, 1);
            rptData.lineData(1).y = data(1:n/2, 2);
            rptData.lineData(1).paint = data(1:n/2, 3);
            rptData.lineData(1).count = 0;
            rptData.lineData(2).x = data(n/2 + 1:n, 1);
            rptData.lineData(2).y = data(n/2 + 1:n, 2);
            rptData.lineData(2).paint = data(n/2 + 1:n, 3);
            rptData.lineData(2).count = 0;
            
            [theta, X] = calcRotAngleAndRange(segCfgList, SegID);
            DB = generateBDatabase(segCfgList(SegID), ...
                bdatabase(SegID), ...
                rptData, ...
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
                end % end of section iteration plot
                
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
                        end % end of non-empty line
                    end % end of fdb line iteration
                    
                    subplot(1, 2, 2)
                    axis equal; hold off;
                end % end of fdb line data not empty plot
            end % end of merged bdb not emtpy
            pause(0.1);
        end
    end
end
