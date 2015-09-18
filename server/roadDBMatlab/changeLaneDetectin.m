function [isChange] = changeLaneDetectin(history)
% CHANGELANEDETECTION
%   Detect the car whether to change lanes
%   INPUT :
%   history   -  roadScan image
%
%   OUTPUT :
%   isChange  -  change lane flag,
%                1 - change lanes
%                -1 - not change lanes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Feiyang Luo, 2015 Sept. 17. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% history = imread('historyroi3.png');
startPos = 150;
endPos   = 450;
nosieArea = 500;

[h,w] = size(history);
Img = zeros(h,w);
%% img to bw
bwImg = gray2bw(history);
L = bwlabel(bwImg);
stats = regionprops(L,'Area','PixelList');
num = size(stats,1);
deleteId = [];
n=1;
for i=1:num
    if stats(i).Area < nosieArea
        deleteId(n,1) = i;
        n = n+1;
    end
end
stats(deleteId) = [];
num2 = size(stats,1);
for i=1:num2
    pixels = stats(i).PixelList;
    m = size(pixels,1);
    for j=1:m
        x = pixels(j,1);
        y = pixels(j,2);
        Img(y,x) = 1;
    end
end
imwrite(Img,'Img.png');
A = sum(Img);
for i=1:w
   if A(i)<20||A(i)>300
      A(i) = 0; 
   end
end
B = A>0;
per = sum(B(startPos:endPos))/(endPos-startPos);
if per>0.4
    isChange = 1;
else
    isChange = -1;
end
% plot(1:w,B);
end

%% img to bw
function [ bwImg ] = gray2bw(img)
% I   input grayscale image 
% Out output BW image
w = 55;
halfw = floor(w/2);
[r,c] = size(img);
k = ones(w);
I2 = filter2(k,img);
I2(halfw+1:r-halfw,halfw+1:c-halfw) = I2(halfw+1:r-halfw,halfw+1:c-halfw)./(w*w);
img = double(img);
I3 = img - I2;
I4 = I3>20;
I4 = I4*1;
bwImg = uint8(I4);
end