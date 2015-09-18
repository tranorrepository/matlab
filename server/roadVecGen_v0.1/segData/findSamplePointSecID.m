function [ samplePoint,flagClosedLoop ] = findSamplePointSecID( samplePoint,fullsectionArea )
%  Determinate every sample point falls into which section .
%Input:
%       fullsectionArea : nx9 matrix,n is the manual marked section number,
%                     9 is :OverlapLeftPoint.x、OverlapLeftPoint.y、BodyLeftPoint.x、BodyLeftPoint.y、BodyRightPoint.x、BodyRightPoint.y、
%                             OverlapRightPoint.x、OverlapRightPoint.y、Section ID
%Input & Output:
%        SamplePoint : nx4 matrix ,n is SamplePoint number of a NonZero input Data section
%                       4 is : sample Point leftX、leftY 、relative start row in aNonZerosVideoData、located section ID (calculated in this fuction)
%Output:
%        flagClosedLoop: the manual sections are closed loop or not

[ bodySectionPoint,flagClosedLoop ] = getAllBodySectionPoint( fullsectionArea );
for i=1:size(samplePoint,1)
    samplePointRow = samplePoint(i,:);
    [ sampleSectionID ] = getSampleSectionID( samplePointRow, bodySectionPoint);
    samplePoint(i,4) = sampleSectionID;
end
end

function [ bodySectionPoint,flagClosedLoop ] = getAllBodySectionPoint( fullsectionArea )
%  Extract BodySectionPoint info from fullsectionArea,because determine the coarse
%  section of input data using body section point only
%Input:
%       fullsectionArea: nx9 matrix,n is the manual marked section number,
%                         9 is :OverlapLeftPoint.x、OverlapLeftPoint.y、BodyLeftPoint.x、BodyLeftPoint.y、BodyRightPoint.x、BodyRightPoint.y、
%                                 OverlapRightPoint.x、OverlapRightPoint.y、Section ID
%Output:
%      bodySectionPoint: nx3 matrix,n is the manual marked section number,
%                             3 is :BodySectionPoint.x、BodySectionPoint.y、BodySectionPoint ID
%      flagClosedLoop: the manual sections are closed loop or not
if fullsectionArea(1,3) == fullsectionArea(end,5) && fullsectionArea(1,4) == fullsectionArea(end,6)
    flagClosedLoop = 1;
    BodySectionPointNum = size(fullsectionArea,1);
    bodySectionPoint = zeros(BodySectionPointNum,3);
    for i = 1 : BodySectionPointNum
        bodySectionPoint(i,1:2) = fullsectionArea(i,3:4);
        bodySectionPoint(i,3) = i;
    end
else
    flagClosedLoop = 0;
    BodySectionPointNum = size(fullsectionArea,1) + 1;
    bodySectionPoint = zeros(BodySectionPointNum,3);
    for i = 1 : BodySectionPointNum - 1
        bodySectionPoint(i,1:2) = fullsectionArea(i,3:4);
        bodySectionPoint(i,3) = i;
    end
    bodySectionPoint(end,1:2) = fullsectionArea(end,5:6);
    bodySectionPoint(end,3) = BodySectionPointNum;
end
end

function [ sampleSectionID ]= getSampleSectionID( samplePointRow, bodySectionPoint)
%   determing one sample point falls into which  manual marked section by minimum distance and angles.
%Input:
%       samplePointRow : one row of SamplePoint,is a 1x4 matrix;
%                              4 is :Sample Point leftX、leftY 、relative start row in aNonZerosVideoData、located section ID (At present it is o)
%Output:
%       bodySectionPoint: nx3 matrix,n is the manual marked section number,
%                              3 is :BodySectionPoint.x、BodySectionPoint.y、BodySectionPoint ID
%       sampleSectionID: int number,the located SectionID of one SamplePoint
sampleSectionID = 0;
Distance = zeros(size(bodySectionPoint,1),1);
for i = 1 : size(Distance,1)
    Distance(i) = getLength(samplePointRow(1,1),samplePointRow(1,2),bodySectionPoint(i,1),bodySectionPoint(i,2));
end
minDist = min(Distance);
minDisSectionID = find(Distance == minDist);
if size(minDisSectionID,1) > 1
    minDisSectionID(2:end,:) = [];
end
PrevSectionID = minDisSectionID-1;
NextSectionID = minDisSectionID+1;
if minDisSectionID == 1
    PrevSectionID = size(bodySectionPoint,1);
else if minDisSectionID == size(bodySectionPoint,1)
        NextSectionID = 1;
    end
end
[cos_left cos_right] = getAngle(samplePointRow(1,1:2),bodySectionPoint(minDisSectionID,1:2),...
    bodySectionPoint(PrevSectionID,1:2),bodySectionPoint(NextSectionID,1:2));
if cos_left<0 && cos_right>0
    sampleSectionID = minDisSectionID;
else if cos_left>0 && cos_right<0
        sampleSectionID = PrevSectionID;
    else
        sampleSectionID = PrevSectionID;
    end
end
end

function [cos_left cos_right] = getAngle(samplepoint,sectionpoint,leftpoint,rightpoint)
%Input:
%       samplepoint: sample point from new data
%       sectionpoint :nearest point to samplepoint
%       leftpoint : the previous section point of sectionpoint
%       rightpoint:the next section point of sectionpoint
%Output:
%     leftangle : left inner cos value of sectionpoint
%     rightangle : right inner cos value of sectionpoint
      length_section_sample = getLength(sectionpoint(:,1), sectionpoint(:,2), samplepoint(:,1), samplepoint(:,2));
      length_section_left = getLength(sectionpoint(:,1), sectionpoint(:,2), leftpoint(:,1), leftpoint(:,2));
      length_sample_left = getLength(samplepoint(:,1), samplepoint(:,2),leftpoint(:,1), leftpoint(:,2));
      length_section_right =  getLength(sectionpoint(:,1), sectionpoint(:,2),rightpoint(:,1), rightpoint(:,2));
      length_sample_right =  getLength(samplepoint(:,1), samplepoint(:,2),rightpoint(:,1), rightpoint(:,2));
      cos_left = ( length_section_sample*length_section_sample+ length_section_left*length_section_left - ...
                          length_sample_left*length_sample_left) / (length_section_sample * length_section_left * 2);
      cos_right = ( length_section_sample*length_section_sample+ length_section_right*length_section_right -...
                            length_sample_right*length_sample_right) / (length_section_sample * length_section_right * 2);
end

function length = getLength(point1_x, point1_y, point2_x, point2_y)
     diff_x = abs(point2_x - point1_x);
     diff_y = abs(point2_y - point1_y);
     length = sqrt(diff_x* diff_x+ diff_y*diff_y);
end

