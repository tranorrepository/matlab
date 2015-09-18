function [curveFittingImg] = curveFitting(Kapa, n)
% CURVEFITTING
%   curve fitting the Kapa image to eliminate noise
%   INPUT :
%   Kapa   -  kapa image
%   n -  fitting numbers
%   
%   OUTPUT :
%   curveFittingImg  - curve fitting result ,             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Feiyang Luo, 2015 Sept 17. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I = imread('roadscan.png');
% Img2(:,:,1) = I;
% Img2(:,:,2) = I;
% Img2(:,:,3) = I;

[h,w] = size(Kapa);
leftPart = zeros(h,w);
rightPart = zeros(h,w);
leftPart(1:h,1:w/2) = Kapa(1:h,1:w/2);
rightPart(1:h,w/2+1:w) = Kapa(1:h,w/2+1:w);
[yl,xl] = find(leftPart>0);
%% left
dataL = [yl';xl'];
pl = polyfit(dataL(1,:),dataL(2,:),n);
fl = floor(polyval(pl,dataL(1,:)));
% figure;plot(dataL(1,:),fl,'o');
% axis equal
DL = abs(dataL(2,:) - fl);
AL = DL<50;
indexL = find(AL == 0);
dataL(:,indexL) = [];
pl2 = polyfit(dataL(1,:),dataL(2,:),n);
fl2 = floor(polyval(pl2,dataL(1,:)));
dataL = [dataL(1,:);fl2];
%% right
[yr,xr] = find(rightPart>0);
dataR = [yr';xr'];
pr = polyfit(dataR(1,:),dataR(2,:),n);
fr = floor(polyval(pr,dataR(1,:)));
% figure;plot(dataR(1,:),fr,'o');
% axis equal
DR = abs(dataR(2,:)-fr);
AR = DR<50;
indexR = find(AR == 0);
dataR(:,indexR) = [];
pr2 = polyfit(dataR(1,:),dataR(2,:),n);
fr2 = floor(polyval(pr2,dataR(1,:)));
dataR = [dataR(1,:);fr2];
% figure;plot(dataR(1,:),dataR(2,:),'o');
% axis equal
Data = [dataL,dataR];
% figure;plot(Data(1,:),Data(2,:),'o');
% axis equal
num = size(Data,2);
Img = zeros(h,w);
for i=1:num
    x = Data(2,i);
    y = Data(1,i);
    Img(y,x,1) = 255;
%     Img2(y,x,1) = 255;
%     Img2(y,x,2) = 0;
%     Img2(y,x,3) = 0;
end
curveFittingImg = Img;
% imwrite(Img2,'Img2.png');
end

