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

function [segCfg, segCfgList] = readSegCfgFile(filename)
% READSEGCFGFILE
%    read road section configuration file for lane and segment data.
%
%    INPUT:
%
%    filename - section configuration file
%               file format is TXT and data is organized as
%               total number of sections
%               section limitation parameters
%               section Id, number of lanes in current section
%               4 points description of full and body range
%               ...
%
%    OUTPUT:
%    segCfg     - contains number of section, and section limitation params
%    segCfgList - each section configuration data
%

if isempty(filename)
    error('Invalid filename!');
end

fid = fopen(filename, 'r');
if -1 == fid
    error('Failed to open file %s for reading!', filename);
end

% read configuration data
segCfg = struct('segNum', 0, 'width', 0, 'overlap', 0, ...
                'minLength', 0, 'maxLength', 0, ...
                'stepSize', 0, 'paintVal', 0);

% total number of sections
fline = fgetl(fid);
segCfg.segNum = sscanf(fline, '%d');

% overall configuration
fline = fgetl(fid);
cfg = sscanf(fline, 'width=%f,overlap=%f,minLength=%f,maxLength=%f,stepSize=%f,paintV=%f');
segCfg.width = cfg(1);
segCfg.overlap = cfg(2);
segCfg.minLength = cfg(3);
segCfg.maxLength = cfg(4);
segCfg.stepSize = cfg(5);
segCfg.paintVal = cfg(6);

segCfgList = struct('segId', 0, 'laneNum', 0, ...
                    'ports', struct('x', zeros(4, 1), 'y', zeros(4, 1)), ...
                    'laneType', []);

% number of section configuration points
SEG_CFG_PNT_NUM = 4;

% iterate each section config
for ii = 1:segCfg.segNum
    % segId and lane number
    fline = fgetl(fid);
    lane = sscanf(fline, '%d,%d');
    segCfgList(ii).segId = lane(1);
    segCfgList(ii).laneNum = lane(2);
    
    % section lane type
    switch (segCfgList(ii).laneNum)
        case 1
            segCfgList(ii).laneType = {'11'};
        case 2
            segCfgList(ii).laneType = {'10'; '01'};
        case 3
            segCfgList(ii).laneType = {'10'; '00'; '01'};
    end
    
    % config points
    fline = fgetl(fid);
    points = sscanf(fline, '%f,%f,%f,%f,%f,%f,%f,%f');
    segCfgList(ii).ports.x = zeros(SEG_CFG_PNT_NUM, 1);
    segCfgList(ii).ports.y = zeros(SEG_CFG_PNT_NUM, 1);
    for jj = 1:SEG_CFG_PNT_NUM
        segCfgList(ii).ports.x(jj) = points(2*jj - 1);
        segCfgList(ii).ports.y(jj) = points(2*jj);
    end
end

fclose(fid);


end