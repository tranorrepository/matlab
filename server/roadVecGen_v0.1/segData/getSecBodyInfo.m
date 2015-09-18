function [ sampleBodySection ] = getSecBodyInfo( samplePoint,flagClosedLoop,manualSectionNum )
%   determine the coarse section of aNonZerosVideoData by the section ID of each sample point
%Input:
%       samplePoint : nx4 matrix ,n is SamplePoint number of a NonZero input Data section
%                      4 is : Sample Point leftX、leftY 、relative start rowin aNonZerosVideoData、
%                               located section ID (calculated in this fuction)
%       flagClosedLoop: the manual sections are closed loop or not
%       manualSectionNum: the manual section number
%Output:
%       sampleBodySection : nx4 matrix,n is the found section amount in aNonZerosVideoData,
%                                   3 is : relative start row of merged sample BodySection located in aNonZerosVideoData、
%                                             relative end row of merged sample BodySection located in aNonZerosVideoData、
%                                             located Section ID   
if flagClosedLoop == 1
    sectionNum = manualSectionNum;
else 
    sectionNum = manualSectionNum+1;
end  
for i = 1 : (size(samplePoint,1)-1)
    if abs(samplePoint(i+1,4)-samplePoint(i,4)) > 1 && abs(samplePoint(i+1,4)-samplePoint(i,4)) < sectionNum-1
        error('the SamplingInterval is biger than the minimum Section distance!; Please decrease it!');
    end
end

sampleBodySectionNum = 0;
changeSectionSum = 0;

for i = 2 : size(samplePoint,1)
    addend = samplePoint(i,4)-samplePoint(i-1,4);
    if addend < 0
        addend = 1;
    end
    changeSectionSum = changeSectionSum+addend;
end
if changeSectionSum < 2
    disp('this video section is too short.It has not a matched data out!');
    sampleBodySection = [];
    return;
end

seekStartRow = 1;
count = size(samplePoint,1);
while count > 0
    [ aSampleBodySection,seekStartRow,flagSelectOver ] = getSection( samplePoint,seekStartRow,sectionNum,flagClosedLoop );
    if aSampleBodySection(1,1) ~= 0
        sampleBodySectionNum = sampleBodySectionNum+1;
        sampleBodySection(sampleBodySectionNum,:) = aSampleBodySection;
    end
    if flagSelectOver==1
        break;
    end
    count = count - 1;        
end
end
 
function [ aSampleBodySection,seekStartRow,flagSelectOver ] = getSection( samplePoint,seekStartRow,sectionNum,flagClosedLoop )
if seekStartRow==1
    seekStartRow = 2;
    aSampleBodySection = 0;
    flagSelectOver = 0;
    return;
else
    currtID = samplePoint(seekStartRow,4);
end

sectionStartRow = 0;
sectionEndRow = 0;
changePointNum = 0;
prevSectionID = 0;
nextSectionID = 0;
for i = seekStartRow-1 : (-1) : 1
    if samplePoint(i,4) ~= currtID
        sectionStartRow = samplePoint(i,3);
        changePointNum = changePointNum + 1;
        prevSectionID = samplePoint(i,4);
        break;
    end
end
for i = seekStartRow+1 : size(samplePoint,1)
    if samplePoint(i,4) ~= currtID
        sectionEndRow = samplePoint(i,3);
        seekStartRow = i;
        changePointNum = changePointNum + 1;
        nextSectionID = samplePoint(i,4);
        break;
    end
end

if i == size(samplePoint,1) 
    flagSelectOver = 1;
else 
    flagSelectOver = 0;
end
if changePointNum == 2 && prevSectionID ~= nextSectionID
    sectionID = currtID;
else 
    sectionID = 0;
    aSampleBodySection = [0,0,0];
    return;
end
if ((sectionID == sectionNum) && (flagClosedLoop == 0))
    aSampleBodySection = [0,0,0];
else
    aSampleBodySection = [sectionStartRow,sectionEndRow,sectionID];
end

end







