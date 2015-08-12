% LANENUMBERDETCTION
%   Detect the lane number, currently, it is just for the Frankford demo.
%
%   INPUT:
%
%   section - one section data, 8 columns
%   minDist - minimal distance threshold
%   plot_on - enable plot or not.
%
%   OUTPUT:
%
%   leftV - value for left lane, the larger the value, the more possible to
%   be solid line
%   rightV- value for right lane, the larger the value, the more possible to
%   be solid line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Bingtao GAO, 2015 Aug 11. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% assume the data is organized as expected
function [leftV, rightV] = laneNumberDetection(section,minDist,plot_on)    
    % paint 
    ll = section(:,3);
    rr = section(:,7);
    % left lane marker
    x0 = section(:,1);
    y0 = section(:,2);
    % right lane marker
    x1 = section(:,5);
    y1 = section(:,6);
    
    validIndex0 = find(ll == 1);
    validIndex1 = find(rr == 1);
    
 if plot_on   
    figure(40)
    hold off
    plot(x0(validIndex0), y0(validIndex0),'b.');
    hold on
    plot(x1(validIndex1), y1(validIndex1),'r.');
    hold off    
    axis equal;
 end   
    
    ll(ll ==-1) = 0;
    rr(rr ==-1) = 0;
    %% calculate length of each dashed line
    [dotBlkIndex1] = dotLineBlockIndex2(ll);
    %% connect adjacent block
    [dotBlkIndex1] = blockCombine(dotBlkIndex1,minDist);
    lengthList = dotBlkIndex1(:,2) - dotBlkIndex1(:,1);
    meanV = round(mean(lengthList));
    stdV  = round(std(lengthList));  
    
 if plot_on      
    figure(1)
    edges = [0:5:300 ];
    h = hist(lengthList,edges,'Normalization','probability');
%     h = histogram(lengthList,edges,'Normalization','probability');
    title(['mean = ',num2str(meanV), ' std =',num2str(stdV)]);      
 end   
 
    leftV = meanV+stdV; 
    [dotBlkIndex2] = dotLineBlockIndex2(rr);
    [dotBlkIndex2] = blockCombine(dotBlkIndex2,minDist);
   
    lengthList = dotBlkIndex2(:,2) - dotBlkIndex2(:,1);
    meanV = round(mean(lengthList));
    stdV  = round(std(lengthList));
   
 if plot_on        
    figure(2)
    edges = [0:5:300 ];
    h = hist(lengthList,edges,'Normalization','probability');    
%     h = histogram(lengthList,edges,'Normalization','probability')    
    title(['mean = ',num2str(meanV), ' std =',num2str(stdV)]);    
 end    
    rightV = meanV+stdV;
end
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
end
%%
function [dotBlkIndex] = dotLineBlockIndex2(data)
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

items = size(data, 1);
dotBlkIndex = zeros(1, 2); % start, stop
blkIndex = 1;
bChanged = false;
for i = 1:items
    value = data(i);
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
end