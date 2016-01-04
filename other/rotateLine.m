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

function lineOut = rotateLine(lineIn, theta)
% ROTATELINE
%    rotate input line with theta angle
%
%    INPUT:
%    lineIn - input line data, (x, y)
%    theta  - rotation angle
%
%    OUTPUT:
%    lineOut - output rotated line, (x, y)
%

x = lineIn.x;
y = lineIn.y;
z = (x + y * 1i) .* exp(theta * 1i);

lineOut.x = real(z);
lineOut.y = imag(z);


end