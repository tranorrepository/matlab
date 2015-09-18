function [paintLocation] = findPaintLoc(paintingImg)
% FINDPAINTLOC
%   Find painting points coordinates(x,y) in image.
%   INPUT :
%   paintingImg   -  painting line image, 
%
%   OUTPUT :
%   paintLocation   -  painting points coordinates(x,y),
%                      left   right
%                      [x,y      x,y]
%                      if there is no painting, x =-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Feiyang Luo, 2015 Sept. 17. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[h,w] = size(paintingImg);
paintLocation = ones(h,4)*-1;
paintLocation(:,2) = [1:h]';
paintLocation(:,4) = [1:h]';
[y,x] = find(paintingImg == 1);
paintLocation2 = [x,y];
a = sortrows(paintLocation2,2);
for i = 1:h
    start = w/2;
    id = find(a(:,2)==i);
    num = size(id,1);
    if num==0
        continue;
    end
    maxLeft = -1;
    minRight = w+1;
    for j=1:num
        if a(id(j),1)<=start
            if a(id(j),1)>maxLeft
                maxLeft = a(id(j),1);
                paintLocation(i,1) = maxLeft;
            end            
        end
        if a(id(j),1)>start
            if a(id(j),1)<minRight
                minRight = a(id(j),1);
                paintLocation(i,3) = minRight; 
            end
        end                
    end   
end
end

