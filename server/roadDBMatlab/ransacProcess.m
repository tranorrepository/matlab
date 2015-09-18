function [RansacImg] = ransacProcess(Kapa, length, threshDist)
% RANSACPROCESS
%   Use ransac to polyfit line and eliminate noise line 
%   INPUT :
%   Kapa   -  kapa image
%   length -  block length
%   threshDist - delete the points that further than threshDist
%   
%
%   OUTPUT :
%   RansacImg  - result image ,             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Feiyang Luo, 2015 Sept 17. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[H,W] = size(Kapa);
Data = [];
unitH = length; % the hight for each block unit
num = ceil(1.0*H/unitH); % number of block
for i = 1:num
    unit = zeros(H,W);
    if i==num
        unit(((i-1)*unitH+1):H,1:W) = Kapa(((i-1)*unitH+1):H,1:W);
    else
        unit(((i-1)*unitH+1):i*unitH,1:W) = Kapa(((i-1)*unitH+1):i*unitH,1:W);        
    end    
    [h,w] = size(unit);
    leftPart = zeros(h,w);
    rightPart = zeros(h,w);
    leftPart(1:h,1:w/2) = Kapa(1:h,1:w/2);
    rightPart(1:h,w/2+1:w) = Kapa(1:h,w/2+1:w);
    [yl,xl] = find(leftPart>0);
    %% left
    dataL = [yl';xl'];
    [bestParameter1L,bestParameter2L] = ransac_demo(dataL,10,100,5,0);
    DL = abs((dataL(1,:)*bestParameter1L + bestParameter2L - dataL(2,:))...
        /sqrt(1+bestParameter1L^2));
    AL = DL<threshDist;
    indexL = find(AL == 0);
    dataL(:,indexL) = [];
    dataL(2,:) = floor(abs(dataL(1,:)*bestParameter1L + bestParameter2L));
    % figure;plot(dataL(1,:),dataL(2,:),'o');
    % axis equal
    %% right
    [yr,xr] = find(rightPart>0);
    dataR = [yr';xr'];
    [bestParameter1R,bestParameter2R] = ransac_demo(dataR,10,100,5,0);
    DR = abs((dataR(1,:)*bestParameter1R + bestParameter2R - dataR(2,:))...
        /sqrt(1+bestParameter1R^2));
    AR = DR<threshDist;
    indexR = find(AR == 0);
    dataR(2,:) = floor(abs(dataR(1,:)*bestParameter1R + bestParameter2R));
    dataR(:,indexR) = [];
    % figure;plot(dataR(1,:),dataR(2,:),'o');
    % axis equal
    Data = [Data,dataL,dataR];
end

num = size(Data,2);
Img = zeros(H,W);
for i=1:num
    x = Data(2,i);
    y = Data(1,i);
    Img(y,x) = 255;
end
RansacImg = Img;
end


function [bestParameter1,bestParameter2] = ransac_demo(data,num,iter,threshDist,inlierRatio)
 % data: a 2xn dataset with #n data points
 % num: the minimum number of points. For line fitting problem, num=2
 % iter: the number of iterations
 % threshDist: the threshold of the distances between points and the fitting line
 % inlierRatio: the threshold of the number of inliers 
 
%  num = 100;
%  iter = 1000;
%  threshDist = 10;
%  inlierRatio = 0;
 %% Plot the data points
 
%  figure;plot(data(1,:),data(2,:),'o');hold on;    
 number = size(data,2); % Total number of points
 bestInNum = 0; % Best fitting line with largest number of inliers
 bestParameter1=0;bestParameter2=0; % parameters for best fitting line
 for i=1:iter
 %% Randomly select 2 points
     idx = randperm(number,num); sample = data(:,idx);   
 %% Compute the distances between all points with the fitting line 
     kLine = sample(:,2)-sample(:,1);
     kLineNorm = kLine/norm(kLine);
     normVector = [-kLineNorm(2),kLineNorm(1)];
     distance = normVector*(data - repmat(sample(:,1),1,number));
 %% Compute the inliers with distances smaller than the threshold
     inlierIdx = find(abs(distance)<=threshDist);
     inlierNum = length(inlierIdx);
 %% Update the number of inliers and fitting model if better model is found     
     if inlierNum>=round(inlierRatio*number) && inlierNum>bestInNum
         bestInNum = inlierNum;
         parameter1 = (sample(2,2)-sample(2,1))/(sample(1,2)-sample(1,1));
         parameter2 = sample(2,1)-parameter1*sample(1,1);
         bestParameter1=parameter1; bestParameter2=parameter2;
     end
 end
 
 %% Plot the best fitting line
 xAxis = -number/2:number; 
 yAxis = bestParameter1*xAxis + bestParameter2;
%  plot(xAxis,yAxis,'r-','LineWidth',2);
%  axis equal    
end
