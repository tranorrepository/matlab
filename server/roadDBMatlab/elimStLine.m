function [Img] = elimStLine(paintingLineLink,T)
% ELIMSTLINE
%   Eliminate the length of lines less than threshold T, which are 
%   considered  noise
%   INPUT :
%   paintingLineLink   -  image, which is linked all the painting lines 
%   T                  -  length threshold.
%
%   OUTPUT :
%   Img   -  image after eliminating short lines(noise)                            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Feiyang Luo, 2015 Sept. 16. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paintingLineLink = rgb2gray(paintingLineLink);
Img = zeros(size(paintingLineLink));
L = bwlabel(paintingLineLink);
stats = regionprops(L,'PixelList');
num = size(stats,1);
deleteId = [];
index = 1;
for i=1:num
    pixelXY = stats(i).PixelList;
    x = pixelXY(:,1);
    y = pixelXY(:,2);
    ma = find(y == max(y));
    mi = find(y == min(y));
    up = pixelXY(mi(1),:);  %% up Piont;
    down = pixelXY(ma(1),:);  %% down point; 
    length = abs(down(1,2) - up(1,2));
    if length<T
        deleteId(index,1) = i;
        index = index+1;
    end
end
stats(deleteId) =[];
n = size(stats,1);
for i = 1:n
     pixelXY = stats(i).PixelList;
     m = size(pixelXY,1);
     for j = 1:m
         x = pixelXY(j,1);
         y = pixelXY(j,2);
         Img(y,x) = 255;
     end
end
end

