% 入口图像为 BW，出口图像为f
%optimize from main_optimize, merely select 2 lines, one has positive
%slope,the other has negative slope
% clear all,close all
% BW=imread('hough.jpg');
BW = frame;
figure,imshow(BW);

BW=rgb2gray(BW);
%thresh=[0.01,0.17];
thresh=[0.01,0.10];
sigma=2;%定义高斯参数
f = edge(double(BW),'canny',thresh,sigma);
figure,subplot(121);
imshow(f,[]);
title('canny Edge Detect Result');

[H, theta, rho]= hough(f, 'RhoResolution', 0.1);%cos(theta)*x+sin(theta)*y=rho
%imshow(theta,rho,H,[],'notruesize'),axis on,axis normal
%xlabel('\theta'),ylabel('rho');

p=houghpeaks(H,10);
hold on


lines=houghlines(f,theta,rho,p);

subplot(122);
imshow(f,[]),title('Hough Transform Detect Result'),hold on
nlind=0;%new line index
st=1;
%%%%%%%%%求斜率%%%%%%%%%%%%
for k=1:length(lines)
    %xy=[lines(k).point1;lines(k).point2];
    xielv(k)=(lines(k).point2(1)-lines(k).point1(1))/(lines(k).point2(2)-lines(k).point1(2)+0.0001)
end

%%%%%%%%%将相同斜率的直线连起来%%%%%%%%%%%%
k=1;
while(k<=length(lines))
    if(k~=length(lines))
        k=k+1;
    end
    while(abs(xielv(k)-xielv(k-1))<0.0001)
        k=k+1;
        if(k>length(lines))
            break;
        end
    end

    if(abs(xielv(k-1))<0.05||abs(xielv(k-1))>=10)%eliminate horizontal and vertical lines,防治水平线和楼房
        st=k;
        if(k~=length(lines))
            continue;
        end
    end
    
    if(st==length(lines)&&k==st)
        if(abs(xielv(k))>0.05&&abs(xielv(k))<10)
            nlind=nlind+1;
            newlines(nlind)=lines(st);
            newlines(nlind).point2=lines(k).point2;
            newxy=[newlines(nlind).point1;newlines(nlind).point2];
            plot(newxy(:,2),newxy(:,1),'LineWidth',4,'Color',[.6 1.0 .8]);
        end
        break;
    end

    %end=k-1,start=st; draw line
    nlind=nlind+1;
    newlines(nlind)=lines(st);
    newlines(nlind).point2=lines(k-1).point2;
    newxy=[newlines(nlind).point1;newlines(nlind).point2];
    plot(newxy(:,2),newxy(:,1),'LineWidth',4,'Color',[.6 1.0 .8]);

    st=k;
end

fprintf('%d lines are detected in sum.\n',nlind);
