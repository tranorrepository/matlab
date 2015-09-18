function [ aVideoMatchData ] = getSingleRptDataInfo( singleRptData,fullsectionArea,samplingInterval,extendScaleForOverlap )
%   For a whole video data ,match the section
%Input:
%        singleRptData: nx6 matrix,the source section video data
%                         6 is: leftX、leftY、leftPaint、rightX、rightY、rightPaint;
%        fullsectionArea : nx9 matrix,n is the manual marked section number,
%                           9 is :OverlapLeftPoint.x、OverlapLeftPoint.y、BodyLeftPoint.x、BodyLeftPoint.y、
%                                   BodyRightPoint.x、 BodyRightPoint.y、OverlapRightPoint.x、OverlapRightPoint.y、Section ID
%       SamplingInterval:s ample aNonZerosVideoData interval by rows
%Output:
%     aVideoMatchData: cell{nx1}:n is the one video nonzeros Seg number
%                         cell{n:1}:cell{nx5}:n is the located section number of one nonzero video segment
%                                5 is: located section number
%                                        nx6 matrix��section source data by maping back:leftx、lefty、leftPaint、rightx、righty、rightPaint
%                                        left boundry in whole video
%                                        right boundry in whole video
%                                        configInfo(direction of rptData)
if isempty(singleRptData)
    error('getSingleRptDataInfo:the singleRptData is empty!; Please check it!');
end
if (size(fullsectionArea,1)==0)
    error('getSingleRptDataInfo : the Section Data is empty!; Please check it!');
end
aVideoMatchData = {};
startRow =1;
endRow = size(singleRptData,1);
aNonZerosVideoData = singleRptData;
sampleOverlapSection = {};
aMatchNZData = {};
[ samplePoint ] = resampleData( aNonZerosVideoData,samplingInterval );
[ samplePoint,flagClosedLoop ] = findSamplePointSecID( samplePoint,fullsectionArea );
[ sampleBodySection ] = getSecBodyInfo( samplePoint,flagClosedLoop,size(fullsectionArea,1));
if isempty(sampleBodySection)
    disp('the video section is too short.It has not a matched data out');
end
[ sampleOverlapSection ] = getSecOverlap( sampleBodySection,aNonZerosVideoData,extendScaleForOverlap );
[ aMatchNZData ] = rotAndCompare( sampleOverlapSection,fullsectionArea,startRow,singleRptData );
if ~isempty(aMatchNZData)
    if  isempty(aVideoMatchData)
        aVideoMatchData{1,1} = aMatchNZData;
    else
        aVideoMatchData{end+1,1} = aMatchNZData;
    end
end
end