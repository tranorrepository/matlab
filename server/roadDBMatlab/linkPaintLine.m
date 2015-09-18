function [paintingLineLink] = linkPaintLine(lineLink)
% LINKPAINTLINE
%   Link all painting lines,based on diretion, length, distance. 
%   INPUT :
%   lineLink   -  lineLink image, which is linked closed lines 
%
%   OUTPUT :
%   paintingLineLink   -  image ,which is linked all painting lines,                               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Feiyang Luo, 2015 Sept 17. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clc;
% close all;
% lineLink = imread('closedLineLink.png');
[h,w] = size(lineLink);
line.up = zeros(1,2);
line.down = zeros(1,2);
line.centroid = 0;
line.angle = 0;

pairPoints.up = zeros(1,2);
pairPoints.down = zeros(1,2);
pairPoints.upId = 0;
pairPoints.downId = 0;

L = bwlabel(lineLink);
stats = regionprops(L,'Centroid','PixelList');
num = size(stats,1);
for i = 1:num
    pixelXY = stats(i).PixelList;
    x = pixelXY(:,1);
    y = pixelXY(:,2);
    ma = find(y == max(y));
    mi = find(y == min(y));
    line(i).up = pixelXY(mi(1),:);  %% up Piont;
    line(i).down = pixelXY(ma(1),:);  %% down point; 
    line(i).centroid = stats(i).Centroid;    
    %% switch x,y 
    p = polyfit(y,x,1);
    f = polyval(p,y);
    angle = 90 - abs(atan(p(1,1))*180/pi);
    line(i).angle = angle;   
end

index = 1;
n = 1;
for i = 1:num
   for j= 1:num
       disty = line(i).up(1,2) - line(j).down(1,2);
       distx = line(i).up(1,1) - line(j).down(1,1);
       angle = atan2(abs(disty),abs(distx))*180/pi;
       divAngleUp = abs(angle - line(i).angle);
       divAngleDown = abs(angle - line(j).angle);
       divAngleUpDown = abs(line(i).angle - line(j).angle);
       if abs(disty)>2000 || divAngleUpDown>2 || divAngleUp>3 || ...
               divAngleDown>3 || disty<0 || abs(distx)> w/3    
            continue;
       else
           pairPoints(index).up = line(i).up;
           pairPoints(index).down = line(j).down;
           pairPoints(index).upId = i;
           pairPoints(index).downId = j;  
           index = index +1;
       end       
   end    
end
%% if one up points link to more than one down points
[pairPoints] = process1(pairPoints);
%% if one down points link to more than one up points
[pairPoints] = process2(pairPoints);
%% link pairPoints 
num2 = size(pairPoints,2);

for i = 1:num2
    p1 = pairPoints(i).up;
    p2 = pairPoints(i).down;
    lineLink = insertShape(lineLink,'Line',[p1(1,1),p1(1,2),p2(1,1),p2(1,2)],'LineWidth',1,'Color','red');
end
% imwrite(lineLink,'1.png');
paintingLineLink = lineLink;

end
%% 
function [pairPoints] = process1(pairPoints)
r = size(pairPoints,2);
for i = 1:r
    upId(i,1) = pairPoints(i).upId;
end
maxValue = max(upId(:));
m = max(r,maxValue);
deleteId = [];
n = 1;
for i=1:maxValue
    id = find(i == upId);
    num = length(id);
    if num >1
        up = pairPoints(id(1)).up;
        down = pairPoints(id(1)).down;
        minDisty = abs(up(1,2) - down(1,2));
        index = 1;
        for j = 2:num
            down2 = pairPoints(id(j)).down;
            disty =  abs(up(1,2) - down2(1,2));
            if disty<minDisty
                minDisty = disty;
                deleteId(n,1) = id(index);
                index = j;
                n = n+1;
            else
                deleteId(n,1) = id(j);
                n = n+1;
            end
        end
    end    
end
pairPoints(deleteId) = [];    
end

%%
function [pairPoints] = process2(pairPoints)

r = size(pairPoints,2);
for i = 1:r
    downId(i,1) = pairPoints(i).downId;
end
maxValue = max(downId(:));
m = max(r,maxValue);
deleteId = [];
n = 1;
for i=1:maxValue
    id = find(i == downId);
    num = length(id);
    if num >1
        down = pairPoints(id(1)).down;
        up = pairPoints(id(1)).up;
        minDisty = abs(up(1,2) - down(1,2));
        index = 1;
        for j = 2:num
            down2 = pairPoints(id(j)).up;
            disty =  abs(up(1,2) - down2(1,2));
            if disty<minDisty
                minDisty = disty;
                deleteId(n,1) = id(index);
                index = j;
                n = n+1;
            else
                deleteId(n,1) = id(j);
                n = n+1;
            end
        end
    end    
end
pairPoints(deleteId) = [];
end
