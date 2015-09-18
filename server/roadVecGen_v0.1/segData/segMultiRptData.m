function [ sectionsDataOut ] = segMultiRptData( rptData,fullsectionArea,samplingInterval,extendScaleForOverlap)
%   For several video data ,match the section
%Input:
%       rptData : 1*N cell,N stands for number of video 
%                    contents of each column: [L_lon,L_lat,L_flag,R_lon,R_lat,R_flag]
%       fullsectionArea : nx9 matrix,n is the manual marked section number,
%                          9 is :OverlapLeftPoint.x、OverlapLeftPoint.y、BodyLeftPoint.x、BodyLeftPoint.y、BodyRightPoint.x、BodyRightPoint.y、
%                                  OverlapRightPoint.x、OverlapRightPoint.y、Section ID
%       samplingInterval: sample interval by rows
%       extendScaleForOverlap: the length we extend for section
%Output: 
%       sectionsDataOut: N*M cell,N is the whole section number,M = videoNum+1;
%                                   {N,1}: section number
%                                   {N,M}: the data located in Nth section of (M-1)th video:{{n*2}{n*2}},the first {n*2} is left-lane info, the second {n*2} is right-lane info
%                                   {n*2}:n is the video Nth section total number
%                                   {n:1}=1
%                                   {n:2}= Nth section data, n*4 matrix: x、y、isPaint、1
if isempty(fullsectionArea)
    disp('the Section Data is empty!; Please check it!');
    return;
end
if isempty(rptData)
    disp('the input Data to be segmented is empty!; Please check it!');
    return;
end

sectionsDataOut = cell(size(fullsectionArea,1),1);
for secNum = 1:size(sectionsDataOut)
    sectionsDataOut{secNum,1} = secNum;
end

for n=1:size(rptData,2)
    aVideoMatchData = {};
    singleRptData = rptData{1,n};
    [ aVideoMatchData ] = getSingleRptDataInfo(singleRptData,fullsectionArea,samplingInterval,extendScaleForOverlap );
    
    for i=1:size(aVideoMatchData,1)
        a = aVideoMatchData{i,1}(:,1);
        d =  cell2mat(a);
        b=unique(d);
        c=histc(d(:,1),b);
        maxReNum = max(c(:,1));
        middleSectionDataOut = cell(size(fullsectionArea,1),maxReNum);
        for j=1:size(aVideoMatchData{i,1},1)
            sectionID = aVideoMatchData{i,1}{j,1};
            sectionRows = size(aVideoMatchData{i,1}{j,2},1);
            realIndex = [];
            temp = cell(1,2);
            temp{1,1} = cell(1,2);
            temp{1,2} = cell(1,2);
            
            leftLane = zeros(sectionRows,4);
            leftLane(:,1:2) = aVideoMatchData{i,1}{j,2}(:,1:2);
            startRow = aVideoMatchData{i,1}{j,3};
            endRow = aVideoMatchData{i,1}{j,4};
            leftLane(:,3) = aVideoMatchData{i,1}{j,2}(:,3);
            leftLane(:,4) = 1;
            
            rightLane = zeros(sectionRows,4);
            rightLane(:,1:2) = aVideoMatchData{i,1}{j,2}(:,4:5);
            rightLane(:,3) = aVideoMatchData{i,1}{j,2}(:,6);
            rightLane(:,4) =1;
            
            if(aVideoMatchData{i,1}{j,5} == 1)
                tempLane = flipud(leftLane);
                leftLane = flipud(rightLane);
                rightLane = tempLane;
            end
            for rowIndex = 1 :size(leftLane,1)
                if((leftLane(rowIndex,3) ~= 2) && (rightLane(rowIndex,3) ~= 2))
                    realIndex = [realIndex;rowIndex];
                end
            end

            temp{1,1}{1,1} = 1;
            temp{1,1}{1,2} = leftLane(realIndex,:);
            
            temp{1,2}{1,1} = 1;
            temp{1,2}{1,2} = rightLane(realIndex,:);

            
            for index = 1 : maxReNum
                if( isempty(middleSectionDataOut{sectionID,index}) )
                    middleSectionDataOut{sectionID, index} = temp;
                    break;
                else
                    continue;
                end
            end
            
        end %end j
    end %end i
    sectionsDataOut = [sectionsDataOut,middleSectionDataOut];
end

end

