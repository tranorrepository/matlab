function [rptData,inputNewDataAfterseg]= VideoDataSeg(videoListFile,maxIntervalForVideoSeg)
%Input:
%         videoListFile
%         maxIntervalForVideoSeg: maxinum of continuous 0(Gps)
%Output:
%         rptData : 1*N cell,N stands for number of video
%                                  contents of each column: [L_lon,L_lat,L_flag,R_lon,R_lat,R_flag]
%        inputNewDataAfterseg: 
%                                               M*N cell, M represents segment number  of each video   
  [rptData] = readData(videoListFile);
  
  inputNewDataAfterseg = cell(1,1);
for index = 1 : size(rptData,2)
    reportData = rptData{1,index};
    subReportDatas = splitChangeLaneData(reportData,maxIntervalForVideoSeg);
    inputNewDataAfterseg{1,index} = subReportDatas;
end

