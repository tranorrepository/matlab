function dotBlkIndex = dotLineBlockIndex(lineData)
% DOTLINEBLOCKINDEX
%   dotted line information from input data
%
%   INPUT:
%
%   lineData - line data
%              (x, y, paint flag, merged count)
%
%   OUTPUT:
%
%   dotBlkIndex  - dotted line start/stop block index of GPS data
%

% dotted and solid line start/stop index
% from which index to which the dotted/slid line starts and ends
items = size(lineData, 1);
dotBlkIndex = zeros(1, 2); % start, stop
blkIndex = 1;
bChanged = false;
for i = 1:items
    value = lineData(i, PAINT_IND);
    if (PAINT_FLAG == value)
        if (false == bChanged)
            dotBlkIndex(blkIndex, 1) = i;   % start
        end
        bChanged = true;
    else
        if (true == bChanged)
            dotBlkIndex(blkIndex, 2) = i-1; % stop
            if DASH_CONT_POINTS_TH < ...
                    (dotBlkIndex(blkIndex, 2) - dotBlkIndex(blkIndex, 1))
                blkIndex = blkIndex + 1;
            end
            bChanged = false;
        end
    end
end

if (true == bChanged) && (0 == dotBlkIndex(blkIndex, 2))
    dotBlkIndex(blkIndex, 2) = items;
end