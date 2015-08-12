function value = laneNumberDetection(line, minDist, plot_on) 
% LANENUMBERDETCTION
%   Detect the lane number, currently, it is just for the Frankford demo.
%
%   INPUT:
%
%   line    - input line data, format is 
%             (x, y, paintFlag, merged count)
%   minDist - minimal distance threshold
%   plot_on - enable plot or not.
%
%   OUTPUT:
%
%   value - value for left lane, the larger the value, the more possible to
%           be solid line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Bingtao GAO, 2015 Aug 11. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('common.mat');

% assume the data is organized as expected   
% paint
inline = line;

% left lane marker
x0 = line(:, X);
y0 = line(:, Y);

validIndex0 = find(inline(:, PAINT_FLAG) == 1);

if plot_on
    figure(40)
    hold off
    plot(x0(validIndex0), y0(validIndex0), 'b.');
    hold off
    axis equal;
end

inline(inline == INVALID_FLAG) = 0;

% calculate length of each dashed line
[dotBlkIndex1] = dotLineBlockIndex(inline);

% connect adjacent block
[dotBlkIndex1] = blockCombine(dotBlkIndex1, minDist);
lengthList = dotBlkIndex1(:,2) - dotBlkIndex1(:,1);
meanV = round(mean(lengthList));
stdV  = round(std(lengthList));

if plot_on
    figure(1)
    edges = 0:5:300;
    h = histogram(lengthList,edges,'Normalization','probability');
    title(['mean = ',num2str(meanV), ' std =',num2str(stdV)]);
end

value = meanV + stdV;

end % end of laneNumberDetection



%% combine two close solid line whose distance is less than Dt (for example 10)
function [dotBlkIndex] = blockCombine(dotBlkIndex,minDist)
blockSize = size(dotBlkIndex,1);
for ii = 1: blockSize-1
    
    if ii < blockSize
        lastLine = dotBlkIndex(ii,:);
        nextLine = dotBlkIndex(ii+1,:);
        
        if (abs(nextLine(1) - lastLine(2))<minDist)
            dotBlkIndex(ii,2) = nextLine(2);
            for jj = ii+1 : (blockSize-1)
                dotBlkIndex(jj,:) = dotBlkIndex(jj+1,:);
            end
            dotBlkIndex(blockSize,:) = [];
            blockSize = blockSize - 1;
        end
    end
end

end % end of blockCombine