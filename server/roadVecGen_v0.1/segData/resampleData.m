function [ SamplePoint ] = resampleData( aNonZerosVideoData,samplingInterval )
%Resample the input data, reserve the end value, set the nonzero data to the previous value
%Input:
%         aNonZerosVideoData: description: one nonzeros input data section of one video;
%                                      type: nx6 matrix ,n is the number of nonzero data section rows;
%                                       6 is: leftX¡¢leftY¡¢leftPaint¡¢rightX¡¢rightY¡¢rightPaint;    
%         samplingInterval: sample interval by rows
%Output: 
%        samplePoint : type: nx4 matrix ,n is SamplePoint number of aNonZerosVideoData;
%                       4 is : Sample Point leftX¡¢leftY ¡¢relative start row in aNonZerosVideoData¡¢section ID belongs to£¨this fuction is init to 0£©
if samplingInterval > size(aNonZerosVideoData,1)
    error('the SamplingInterval is biger than the size of SourceInData!; Please decrease it!');
end
DataSize = size(aNonZerosVideoData,1);
PointNum = floor(DataSize/samplingInterval) + 1;
SamplePoint = zeros(PointNum,4);
for i = 1 : (PointNum-1)
    relativeRow = 1 + (i-1)*samplingInterval;
    SamplePoint(i,1:2) =  aNonZerosVideoData(relativeRow,1:2);
    SamplePoint(i,3) = 1 + (i-1)*samplingInterval;
end
 SamplePoint(end,1:2) =  aNonZerosVideoData(end,1:2);
 SamplePoint(end,3) = DataSize;
 
 zerosIndex = find(SamplePoint(:,1) == 0);
 for i = 1 : size(zerosIndex,1)
     if zerosIndex(i) == 1
         SamplePoint(1,1) = SamplePoint(2,1);
         SamplePoint(1,2) = SamplePoint(2,2);
     else
         SamplePoint(zerosIndex(i),1) = SamplePoint(zerosIndex(i)-1,1);
         SamplePoint(zerosIndex(i),2) = SamplePoint(zerosIndex(i)-1,2);
     end
 end
 
end

