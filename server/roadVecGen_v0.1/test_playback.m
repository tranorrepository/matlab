%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Continental Confidential
%                  Copyright (c) Continental, LLC. 2015
%
%      This software is furnished under license and may be used or
%      copied only in accordance with the terms of such license.
%
% Change Log:
%      Date                    Who                    What
%      2015/09/16              Ming Chen              Create
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% test for server merging process
% clear variables
% close all
clc

% addpath('.\data');
% addpath('.\mergeData');
% addpath('.\segData');

cfgname  = '.\config\DE_Airport_manualSeg.txt';
pathname = '.\config\pathlist.txt';

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
newData = struct('x', 0.0, 'y', 0.0, 'paint', 0.0, 'count', 0);

% read each GPS file to automatically segment data
fid = fopen(pathname, 'r');
if -1 == fid
    error('Failed to open file %s for reading!', pathname);
end

segCnt = zeros(segCfg.segNum, 1);

while ~feof(fid)
    fn = fgetl(fid);
    data = load(fn);
    if ~isempty(data)
        newData(1).x = data(:, 2);
        newData(1).y = data(:, 1);
        newData(1).paint = data(:, 3);
        newData(1).count = 0;
        newData(2).x = data(:, 13);
        newData(2).y = data(:, 12);
        newData(2).paint = data(:, 14);
        newData(2).count = 0;
        
        segData = segmentRptData(newData, segCfgList);
        numOfSegs = size(segData, 2);
        
        for ii = 1:numOfSegs
            SegID = segData(ii).segId;
            numOfLines = size(segData(ii).lineData, 2);
            for kk = 1:2:numOfLines
                rptData.segId = SegID;
                rptData.lineData = segData(ii).lineData(kk : kk + 1);
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
                
                pause(0.001);
            end % end of section lane iteration
        end % end of section iteration
        
    end % end of source data not empty
end

