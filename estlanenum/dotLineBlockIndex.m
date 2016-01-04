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

function dotBlkIndex = dotLineBlockIndex(lineData)
% DOTLINEBLOCKINDEX
%   dotted line information from input data
%
%   INPUT:
%   lineData - line data
%              (x, y, paint, count)
%
%   OUTPUT:
%   dotBlkIndex - dotted line start/stop block index of GPS data
%

dataSize = size(lineData.x, 1);

dx = abs(lineData.x(2:end) - lineData.x(1:end - 1));
dy = abs(lineData.y(2:end) - lineData.y(1:end - 1));
dd = dx + dy;

lineData.paint(lineData.paint < 0) = 0;

dp = lineData.paint(2:end) - lineData.paint(1:end - 1);
index0 = find(dp ~= 0);

if isempty(index0)
    blkIndex = 1;
    dotBlkIndex(blkIndex, 1) = 1;
    dotBlkIndex(blkIndex, 2) = dataSize;
else
    blkIndex = 1;
    dotBlkIndex(blkIndex, 1) = -1;
    dotBlkIndex(blkIndex, 2) = -1;
    for ii = 1: size(index0, 1)
        p0 = dp(index0(ii));
        if (p0 == 1)    % start
            dotBlkIndex(blkIndex, 1) = index0(ii) + 1;
            if (ii == size(index0, 1))
                dotBlkIndex(blkIndex, 2) = dataSize;
                blkIndex = blkIndex + 1;
            end
        else            % end
            dotBlkIndex(blkIndex, 2) = index0(ii);
            if (dotBlkIndex(blkIndex, 1) == -1)
                dotBlkIndex(blkIndex, 1) = 1;
            end
            blkIndex = blkIndex + 1;
        end
    end

    % add two adjacent points distance exceeds limits
    blkIndex = blkIndex - 1;
    index1 = find(dd > 2.5);
    for jj = 1: size(index1)
        ind = index1(jj) + 1;
        loop = blkIndex;
        for ii = 1:loop
            if (dotBlkIndex(ii, 1) < ind) && (dotBlkIndex(ii, 2) >= ind)
                for kk = (loop + 1):-1:(ii + 1)
                    dotBlkIndex(kk, 1) = dotBlkIndex(kk - 1, 1);
                    dotBlkIndex(kk, 2) = dotBlkIndex(kk - 1, 2);
                end
                dotBlkIndex(ii, 2) = ind -1;
                dotBlkIndex(ii + 1, 1) = ind;
                blkIndex = blkIndex + 1;
                break;
            end
        end
    end
end


end