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
segCfg = struct('segNum', 0);

segCfgList = struct('segId', 0, 'laneNum', 0, ...
                    'ports', struct('x', zeros(4, 1), 'y', zeros(4, 1)), ...
                    'laneType', [], 'connInfo', []);

% number of section configuration points
SEG_CFG_PNT_NUM = 4;

% get lines of file
rows = 0;
while ~feof(fid)
    rows = rows + sum(fread(fid, 10000, '*char') == char(10));
end
frewind(fid);

segCfg.segNum = rows / 4;

% iterate each section config
for ii = 1:segCfg.segNum
    % segId and lane number
    fline = fgetl(fid);
    lane = sscanf(fline, 'segId: %d,laneNum: %d');
    segCfgList(ii).segId = lane(1);
    segCfgList(ii).laneNum = lane(2);
    
    fline = fgetl(fid);
    % section lane type
    switch (segCfgList(ii).laneNum)
        case 1
            lt = sscanf(fline, 'lineType: %d,%d');
            str = strcat(num2str(lt(1)), num2str(lt(2)));
            segCfgList(ii).laneType = {str};
            
            fline = fgetl(fid);
            lt = sscanf(fline, 'connectInfo: %d');
            segCfgList(ii).connInfo = lt;
        case 2
            lt = sscanf(fline, 'lineType: %d,%d,%d');
            str1 = strcat(num2str(lt(1)), num2str(lt(2)));
            str2 = strcat(num2str(lt(2)), num2str(lt(3)));
            segCfgList(ii).laneType = {str1; str2};
            
            fline = fgetl(fid);
            lt = sscanf(fline, 'connectInfo: %d,%d');
            segCfgList(ii).connInfo = lt;
        case 3
            lt = sscanf(fline, 'lineType: %d,%d,%d,%d');
            str1 = strcat(num2str(lt(1)), num2str(lt(2)));
            str2 = strcat(num2str(lt(2)), num2str(lt(3)));
            str3 = strcat(num2str(lt(3)), num2str(lt(4)));
            segCfgList(ii).laneType = {str1; str2; str3};
            
            fline = fgetl(fid);
            lt = sscanf(fline, 'connectInfo: %d,%d,%d');
            segCfgList(ii).connInfo = lt;
        case 4
            lt = sscanf(fline, 'lineType: %d,%d,%d,%d,%d');
            str1 = strcat(num2str(lt(1)), num2str(lt(2)));
            str2 = strcat(num2str(lt(2)), num2str(lt(3)));
            str3 = strcat(num2str(lt(3)), num2str(lt(4)));
            str4 = strcat(num2str(lt(4)), num2str(lt(5)));
            segCfgList(ii).laneType = {str1; str2; str3; str4};
            
            fline = fgetl(fid);
            lt = sscanf(fline, 'connectInfo: %d,%d,%d,%d');
            segCfgList(ii).connInfo = lt;
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