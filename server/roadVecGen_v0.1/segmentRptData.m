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

function segData = segmentRptData(rptData, segCfgData)
% SEGMENTRPTDATA
%    segment reported data into sections based on section configuration.
%    This is a wrapper for segmentation functions as the data format is not
%    aligned external and internal.
%
%    INPUT:
%    rptData    - new reported lane data, two line, (x, y, paint)
%    segCfgData - sections configuration data
%                 struct('segId', 0, 'laneNum', 0, ...
%                   'ports', struct('x', zeros(4, 1), 'y', zeros(4, 1)), ...
%                   'laneType', []);
%
%    OUTPUT:
%    segData    - segmented data
%                 struct('segId', 0, ...
%                        'lineData', struct('x', 0.0, ...
%                                           'y', 0.0, ...
%                                           'paint', 0.0, ...
%                                           'count', 0));
%

% addpath('.\segData');

orgData{1, 1} = [rptData(1).x, rptData(1).y, rptData(1).paint, ...
                 rptData(2).x, rptData(2).y, rptData(2).paint];

celData{1, 1} = [1, size(rptData(1).x, 1)];
celData{1, 2} = orgData{1, 1};
nasData{1, 1} = celData;

% section points
SEG_CFG_PNT_NUM = 4;

numOfSegs = size(segCfgData, 2);
segPorts = zeros(numOfSegs, 2 * SEG_CFG_PNT_NUM + 1);
for ii = 1:numOfSegs
    segPorts(ii, 1) = segCfgData(ii).ports.x(3);
    segPorts(ii, 2) = segCfgData(ii).ports.y(3);
    segPorts(ii, 3) = segCfgData(ii).ports.x(1);
    segPorts(ii, 4) = segCfgData(ii).ports.y(1);
    segPorts(ii, 5) = segCfgData(ii).ports.x(2);
    segPorts(ii, 6) = segCfgData(ii).ports.y(2);
    segPorts(ii, 7) = segCfgData(ii).ports.x(4);
    segPorts(ii, 8) = segCfgData(ii).ports.y(4);
	segPorts(ii, 9) = segCfgData(ii).segId;
end

[ sectionsDataOut ] = segMultiRptData(orgData, segPorts, 20, 50);

% initialize output data 
segData = struct('segId', 0, ...
                 'lineData', struct('x', 0.0, 'y', 0.0, 'paint', 0.0, 'count', 0.0));

numOfOut = size(sectionsDataOut, 1);
segInd = 1;

for ii = 1:numOfOut
    lineInd = 1;
    numOfLanes = size(sectionsDataOut, 2) - 1;
    for jj = 1:numOfLanes
        if ~isempty(sectionsDataOut{ii, jj + 1})
            segData(segInd).segId = ii;
            segData(segInd).lineData(lineInd).x = sectionsDataOut{ii, jj + 1}{1, 1}{1, 2}(:, 1);
            segData(segInd).lineData(lineInd).y = sectionsDataOut{ii, jj + 1}{1, 1}{1, 2}(:, 2);
            segData(segInd).lineData(lineInd).paint = sectionsDataOut{ii, jj + 1}{1, 1}{1, 2}(:, 3);
            segData(segInd).lineData(lineInd).count = 0;
            lineInd = lineInd + 1;
            
            segData(segInd).lineData(lineInd).x = sectionsDataOut{ii, jj + 1}{1, 2}{1, 2}(:, 1);
            segData(segInd).lineData(lineInd).y = sectionsDataOut{ii, jj + 1}{1, 2}{1, 2}(:, 2);
            segData(segInd).lineData(lineInd).paint = sectionsDataOut{ii, jj + 1}{1, 2}{1, 2}(:, 3);
            segData(segInd).lineData(lineInd).count = 0;
            lineInd = lineInd + 1;
        end
    end
    segInd = segInd + 1;
end


end