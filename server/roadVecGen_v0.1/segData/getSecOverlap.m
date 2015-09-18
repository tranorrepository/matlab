function [ sampleOverlapSection ] = getSecOverlap( sampleBodySection,aNonZerosVideoData,extendScaleForOverlap )
%   Expanding coarse Sample BodySection 50m to coarse Sample OverlapSection,because following comparition must use OverlapSection.
%Input:
%      sampleBodySection : nx4 matrix,n is the found section number in aNonZerosVideoData,
%                       3 is:relative start row of merged sample BodySection located in aNonZerosVideoData、relative end row of merged sample BodySection located in aNonZerosVideoData、located Section ID
%      aNonZerosVideoData: description: one nonzeros section of one video;
%                                   type: nx6 matrix ,n is the number of nonzero data section rows;
%                                    6 is: leftX、leftY、leftPaint、rightX、rightY、rightPaint;
%Output:
%      sampleOverlapSection: cell{nx5},n is the found section number in aNonZerosVideoData,
%                              cell{nx1}: located sample Section ID
%                              cell{nx2}: nx6 matrix,sample Overlap Section data:leftx、lefty、leftPaint、rightx、righty、rightPaint
%                              cell{nx3}: left boundry in aNonZerosVideoData
%                              cell{nx4}: right boundry in aNonZerosVideoData
%                              cell{nx5}: configInfo(reserved)
dataSectionNum = size(sampleBodySection,1);
sampleOverlapSection = cell(dataSectionNum,5);
% SampleOverlapSection = {0};
bodyLeft = [ ];
bodyRight = [ ];
overlapLeftRow = 0;
overlapRightRow = 0;
for i = 1 : dataSectionNum
    sampleOverlapSection{i,1} = sampleBodySection(i,3);
    bodyLeft = aNonZerosVideoData(sampleBodySection(i,1),:);
    bodyRight = aNonZerosVideoData(sampleBodySection(i,2),:);
    for leftIndex = sampleBodySection(i,1): -1 : 1
        leftDistance = sqrt((bodyLeft(1,1) - aNonZerosVideoData(leftIndex,1))^2 + (bodyLeft(1,2) - aNonZerosVideoData(leftIndex,2))^2);
        overlapLeftRow = 1;
        if (leftDistance >= extendScaleForOverlap)
            overlapLeftRow = leftIndex;
            break;
        end
    end
    for rightIndex = sampleBodySection(i,2) : size(aNonZerosVideoData,1)
        rightDistance = sqrt((bodyRight(1,1) - aNonZerosVideoData(rightIndex,1))^2 + (bodyRight(1,2) - aNonZerosVideoData(rightIndex,2))^2);
        overlapRightRow = size(aNonZerosVideoData,1);
        if (rightDistance >= extendScaleForOverlap)
            overlapRightRow = rightIndex;
            break;
        end
    end
    sampleOverlapSection{i,2} = aNonZerosVideoData(overlapLeftRow:overlapRightRow,:);
    sampleOverlapSection{i,3} = overlapLeftRow;
    sampleOverlapSection{i,4} = overlapRightRow;
    sampleOverlapSection{i,5} = 0;
end
end




