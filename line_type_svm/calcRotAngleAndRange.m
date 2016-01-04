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

function [theta, Xlimit] = calcRotAngleAndRange(segCfgList, segId)
% CALCROTANGLEANDRANGE
%    calculate section rotation angle according to overlap points
%
%    INPUT:
%    segCfgList - all section configuration list
%    segId      - which section to calculate
%
%    OUTPUT:
%    theta   - section rotation angle
%    Xlimit  - section overlap points x range after rotation
%

x = segCfgList(segId).ports.x;
y = segCfgList(segId).ports.y;

theta = atan2((y(3) - y(4)), (x(3) - x(4)));

Xlimit = real((x + y * 1i) * exp(-theta * 1i));


end