function [dotBlkIndex, dotLineIndex] = dotLineBlockIndex(data)
% DOTLINEBLOCKINDEX
%   dotted line information from input data
%
%   INPUT:
%
%   data - organized GPS data, 19 columns(ford) or 6 columns(Honda)
%
%   OUTPUT:
%
%   dotBlkIndex - dotted line start/stop block index of GPS data
%   dotLineIndex - the column of paint dotted line
%

% assume the data is organized as expected
[paintIndex, ~] = getPaintIndex(data);
paint = sum(1 == data(:, paintIndex));

% dotted and solid line index
dotLineIndex   = paintIndex(min(paint) == paint);

% dotted and solid line start/stop index
% from which index to which the dotted/slid line starts and ends
items = size(data, 1);
dotBlkIndex = zeros(1, 2); % start, stop
blkIndex = 1;
bChanged = false;
for i = 1:items
    value = data(i, dotLineIndex);
    if (1.0 == value)
        if (false == bChanged)
            dotBlkIndex(blkIndex, 1) = i;   % start
        end
        bChanged = true;
    else
        if (true == bChanged)
            dotBlkIndex(blkIndex, 2) = i-1; % stop
            if 10 < (dotBlkIndex(blkIndex, 2) - dotBlkIndex(blkIndex, 1))
                blkIndex = blkIndex + 1;
            end
            bChanged = false;
        end
    end
end

if (true == bChanged) && (0 == dotBlkIndex(blkIndex, 2))
    dotBlkIndex(blkIndex, 2) = items;
end