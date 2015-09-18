function [ aMatchNZData ] = rotAndCompare( sampleOverlapSection,fullsectionArea,startRow,singleRptData )
%Input:
%      sampleOverlapSection: cell{nx5},n is the found section number in aNonZerosVideoData,
%                               cell{n:1}: located sample Section ID
%                               cell{n:2}: nx6 matrix,sample Overlap Section data:leftx、lefty、leftPaint、rightx、righty、rightPaint
%                               cell{n:3}: left boundry in aNonZerosVideoData
%                               cell{n:4}: right boundry in aNonZerosVideoData
%                               cell{n:5}: configInfo(reserved)
%     fullsectionArea : nx9 matrix,n is the manual marked section number,
%                        9 is : OverlapLeftPoint.x、OverlapLeftPoint.y、BodyLeftPoint.x、BodyLeftPoint.y、BodyRightPoint.x、BodyRightPoint.y、
%                                 OverlapRightPoint.x、OverlapRightPoint.y、Section ID
%     startRow: the aNonZerosVideoData start location in the corresponding whole video,used to locate the matched data section in the corresponding source video which includs zeros
%     aWholeVideo: the source input whole video including zeros
%Output:
%      aMatchNZData: cell{nx5},n is the found section number in aNonZerosVideoData,
%                  cell{n:1}: located sample Section ID
%                  cell{n:2}: nx6 matrix,sample Section source data by maping back: leftx、lefty、leftPaint、rightx、righty、rightPaint
%                  cell{n:3}: left boundry in whole video
%                  cell{n:4}: right boundry in whole video
%                  cell{n:5}: configInfo(reserved)
aMatchNZData = cell(size(sampleOverlapSection,1),5);
dataSectionNum = size(aMatchNZData,1);
for i = 1 : dataSectionNum
    tmpIndex = find(fullsectionArea(:,9) == sampleOverlapSection{i,1});
    if size(tmpIndex,1)>1
        tmpIndex(2:end,:) = [];
    end
    srcLeftX = fullsectionArea(tmpIndex,1);
    srcLeftY = fullsectionArea(tmpIndex,2);
    srcRightX = fullsectionArea(tmpIndex,7);
    srcRightY = fullsectionArea(tmpIndex,8);
    theta = -atan((srcRightY-srcLeftY)/(srcRightX-srcLeftX));
    [rotSrcLeftX,rotSrcLeftY] = rotPoint(srcLeftX,srcLeftY,theta);
    [rotSrcRightX,rotSrcRightY] = rotPoint(srcRightX,srcRightY,theta);
    
    compareSection = sampleOverlapSection{i,2};
    comparePointNum = size(compareSection,1);
    leftDistMat = zeros(comparePointNum,1);
    rightDistMat = zeros(comparePointNum,1);
    dataRowNewX = [];
    for j=1:comparePointNum
        [rotNewX,rotNewY] = rotPoint(compareSection(j,1),compareSection(j,2),theta);
        leftDistMat(j) = abs(rotNewX-rotSrcLeftX);
        rightDistMat(j) = abs(rotNewX-rotSrcRightX);
        dataRowNewX = [dataRowNewX;rotNewX];
    end
    leftIndex = find(leftDistMat == min(leftDistMat));
    rightIndex = find(rightDistMat == min(rightDistMat));
    if size(leftIndex,1)>1 
        leftIndex(2:end,:) = [];
    end
    if size(rightIndex,1)>1 
        rightIndex(2:end,:) = [];
    end
    
    leftRow = sampleOverlapSection{i,3}+leftIndex-1;
    rightRow = sampleOverlapSection{i,3}+rightIndex-1;
    
    if leftRow > rightRow
        tmpIndex = leftRow;
        leftRow = rightRow;
        rightRow = tmpIndex;
    end
    
    aMatchNZData{i,1} = sampleOverlapSection{i,1};
    aMatchNZData{i,3} = leftRow+startRow-1;
    aMatchNZData{i,4} = rightRow+startRow-1;
    aMatchNZData{i,2} = singleRptData(aMatchNZData{i,3}:aMatchNZData{i,4},:);
    if((dataRowNewX(1,1) - dataRowNewX(end,1)) * (rotSrcLeftX - rotSrcRightX) > 0)
           aMatchNZData{i,5} = 0;
    else
           aMatchNZData{i,5} = 1;
    end
   
end
end

function [outX,outY] = rotPoint(inX,inY,theta)
x = inX;
y = inY;
z = (x + y*1i).* exp(theta*1i);

outX = real(z);
outY = imag(z);  
end

