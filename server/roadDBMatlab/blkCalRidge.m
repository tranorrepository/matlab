function [Kapa] = blkCalRidge(longLane)
% BLKCALRIDGE
%   Detect the ridge of roadScan image(longLane) by using the method of block
%   INPUT :
%   longLane   -  roadScan image
%
%   OUTPUT :
%   Kapa       -  ridge image                             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Feiyang Luo, 2015 Sept 16. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[H,W] = size(longLane);
Kapa = zeros(H,W);
unitH = 1000; % the hight for each block unit
num = ceil(1.0*H/unitH); % number of block
for i = 1:num
    if i==num
        unit = longLane(((i-1)*unitH+1):H,1:W);
    else
        unit = longLane(((i-1)*unitH+1):i*unitH,1:W);        
    end
    %% judge shadow(contrast)
     [isShadow] = judgeShadow(unit);    
    %% process shadow(enhance contrast), if needed for block unit
    if isShadow == 1
        [unit] = shadowProcess(unit);
    end
%      imshow(unit);
    [h,w] = size(unit);
    unitlongLaneLeft = unit(1:h,1:w/2);
    unitlongLaneRight = unit(1:h,w/2+1:w);
    %% cal ridge Params 
    [unitRidgeLeftPar] = calRidgePar(unitlongLaneLeft);
    [unitRidgeRightPar] = calRidgePar(unitlongLaneRight);
    if (unitRidgeLeftPar<9)
        unitRidgeLeftPar=9;
    end
    if (unitRidgeRightPar<9)
        unitRidgeRightPar=9;
    end
    %% ridgeDetect for block unit
    [unitKapaLeft] = ridgeDetect(unitlongLaneLeft,unitRidgeLeftPar/2.5,unitRidgeLeftPar/2.5);
    [unitKapaRight] = ridgeDetect(unitlongLaneRight,unitRidgeRightPar/2.5,unitRidgeRightPar/2.5);
    unitKapa = zeros(h,w);
    unitKapa(1:h,1:w/2) = unitKapaLeft;
    unitKapa(1:h,w/2+1:w) = unitKapaRight; 
    %% eliminate nose based on the length, direction of line
    [binKapa] = noiseProcess(unitKapa);
%      figure(i),imshow(binKapa);
    if i==num
        Kapa(((i-1)*unitH+1):H,1:W) = binKapa*255;
    else
        Kapa(((i-1)*unitH+1):i*unitH,1:W) = binKapa*255;        
    end           
end
end
%% judge if use shaowProcess
function [isShadow] = judgeShadow(unit)
[r,c] = size(unit);
I = unit<=90;
num = length(find(I==1));
per = num/(r*c);
if per>50
    isShadow = 1;
else
    isShadow = 0;
end
end

%% shadowprocess if needed for block unit
function [unit] = shadowProcess(unit)
I = unit;
background = imopen(I,strel('disk',20));
I2 = I - background;
unit = imadjust(I2);
end

%% cal ridge sigma params
function [unitRidgePar] = calRidgePar(unit)
[h,w] = size(unit);
thresh = graythresh(unit);
unitImgBW = im2bw(unit,thresh);
% figure,imshow(unitImgBW,[]);
paintWidth = [];
minWidth = 4;
maxWidth = 30;
n=1;
for i = 1:10:h
    rowData = zeros(1,w);
    for j = 1:w
        if unitImgBW(i,j)>0
            rowData(1,j) = 255;
        else
            rowData(1,j) = 0;
        end
    end
    posStart = 0;
    posEnd = 0;
    count = 0;
    for j = 1:w
        nowValue = rowData(1,j);
        if (nowValue==255&&count == 0)
            posStart = j;
            count = 1;
        end
        if (nowValue==0&&count ==1)
            posEnd = j;
            count = 0;
            width = posEnd-posStart;
            if width>4&&width<30
               paintWidth(1,n) = width;
               n = n+1;
            end               
        end       
    end
end
A = sort(paintWidth(:)); 
pos =ceil(0.8*length(A));
if pos>1
    unitRidgePar = A(pos);
else
    unitRidgePar = 0;  
end
      
end


%% ridgeDetect for block unit
function [kapa] = ridgeDetect(unitlongLane,sigma1,sigma2)

[h,w] = size(unitlongLane);
image = (unitlongLane);
% figure,imshow(image);
%% Step1: Gaussian filter
sigma = sigma1;
ksize = floor(((sigma - 0.8)/0.3 +1)*2 + 1); 
gussKernel = fspecial('gaussian',ksize,sigma);
image2 = double(imfilter(image,gussKernel,'replicate','same','conv'));
% figure,imshow(image2);
%% Step2: Compute the Gradient Vector Field
kernelX = [-0.5,0,0.5];
kernelY = ([-0.1,0,0.1])';
fx = (imfilter(image2,kernelX,'replicate','same','conv'));
% figure,imshow(uint8(fx),[]);
fy = (imfilter(image2,kernelY,'replicate','same','conv'));
% figure,imshow(fy,[]);

%% Step3: 
fx = double(fx);
fy = double(fy);
xx = fx.*fx/255;
yy = fy.*fy/255;
xy = fx.*fy/255;
%% Step4: Gaussian filter
sigma = sigma2;
ksize = floor(((sigma - 0.8)/0.3 +1)*2 +1);
gussKennelx = fspecial('gaussian',ksize,sigma);
xx = imfilter(xx,gussKennelx,'replicate','same','conv');
xy = imfilter(xy,gussKennelx,'replicate','same','conv');
yy = imfilter(yy,gussKennelx,'replicate','same','conv');
%% Step5:eigen value and eigen vector
a = xx;
b = xy;
c = b;
d = yy;

T = a+d;
D = a.*d - c.*b;
L1 = T/2.0 + sqrt(T.*T/4.0 - D);
ex = L1 - d;
ey = c;
norm = sqrt(ex.*ex + ey.*ey);
ex = (L1.*ex)./norm;
ey = (L1.*ey)./norm;

M = ex.*fx + ey.*fy;
M1 = M>0;
M2 = -1*(M<=0);
M3 = M1 + M2;
u = M3.*ex;
v = M3.*ey;

fu = imfilter(u,kernelX,'replicate','same','conv');
fv = imfilter(v,kernelY,'replicate','same','conv');
kapa = fu + fv;
kapa = (kapa.*(-1));
thresh = graythresh(abs(kapa));
if thresh==0
    thresh = 0.001;
end
kapa = 1.0*im2bw(kapa,thresh);
% figure,imshow(kapa);

end
%% eliminate nose based on the length, direction of line
function [binKapa] = noiseProcess(unitKapa)
% figure,imshow(unitKapa);
%% find contours
L = bwlabel(unitKapa);
stats = regionprops(L,'Area','Centroid','PixelList');
num = size(stats,1);
deleteId = []; %% save the noise id;
id = 1;
for i = 1:num
    if stats(i).Area>50        
        pixelXY = stats(i).PixelList;
        centroid = stats(i).Centroid;
        p = fittype('poly1');
        f = fit(pixelXY(:,2),pixelXY(:,1),p);
%         figure,
%         plot(f,pixelXY(:,2),pixelXY(:,1));
%         axis ij
%         axis equal               
        angle = abs(atan(f.p1)*180/pi);
        %% cal direction angle, if <85,delete
        if angle<15
            %% cal std and length of line, if length<100&&std>2,delete
            x = pixelXY(:,1);
            y = pixelXY(:,2);
            ma = find(y == max(y));
            mi = find(y == min(y));
            up = pixelXY(mi(1),:);  %% up Piont;
            down = pixelXY(ma(1),:);  %% down point;
            dst = sqrt(abs(y - f.p1*x - f.p2)/(1+f.p1^2));
            std0 = std(dst);
            length = norm(down - up);
            if length >70
                if std0>3&&length<100
                    deleteId(id) = i;
                    id = id+1;
                end
            else
                deleteId(id) = i;
                id = id+1;
            end
        else
            deleteId(id) = i;
            id = id+1;
        end
    else
        deleteId(id) = i;
        id = id+1;
    end
end 
img = zeros(size(unitKapa));
num1 = size(deleteId(:),1);
for i = 1:num1
    id = deleteId(i);
    pixelList = stats(id).PixelList;
    num2 = size(pixelList,1);
    for j = 1:num2
       img(pixelList(j,2),pixelList(j,1)) = 1; 
    end   
end
binKapa = unitKapa - img;
end
