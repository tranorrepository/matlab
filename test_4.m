clc,close  
% BW=imread('hough.jpg');
BW = frame(580:end, :, :);
figure(1),imshow(BW);
  
BW=rgb2gray(BW);  
thresh=[0.05,0.15];  
sigma=3;%定义高斯参数  
f = edge(double(BW),'canny',thresh,sigma);  
figure(2),imshow(f,[]);  
title('canny edge detection');  
  
[H, theta, rho]= hough(f,'RhoResolution', 0.75);  
%imshow(theta,rho,H,[],'notruesize'),axis on,axis normal  
%xlabel('\theta'),ylabel('rho');  
  
peak=houghpeaks(H,10);  
hold on  
  
lines=houghlines(f,theta,rho,peak);  
figure(3);imshow(f,[]),title('Hough Transform Detect Result'),hold on  
for k=1:length(lines)  
    xy=[lines(k).point1;lines(k).point2];  
    plot(xy(:,1),xy(:,2),'LineWidth',4,'Color',[.6 .6 .6]);  
end