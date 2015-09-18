  function [sectionPointsAfterOverlap,stSection] = caculateConfig(kmlFileName,extendScaleForOverlap,refCoff)
%Input:
%           kmlfileName: the path we choose
%           extendScaleForOverlap: the length we extend for section
%           refCoff
%Output:                  
%         sectionPointsAfterOverlap : 
%                                                H*9 matrix,H represents number of section
%                                                contents: [overlapleftx,overlaplefty,bodyleftx,bodylefty,...
%                                                                 bodyrightx,bodyrighty,overlaprightx,overlaprightx,SecID]
%        stSection : H *4 cell: 
%                                        stSection{i,1}    sectionID                 
%                                        stSection{i,2}    points
%                                        stSection{i,3}    flag of lane
%                                        stSection{i,4}    lane number

  %%Step1: get the longitude and latitude of segmented points from kml file
  sectionBoundary = read_kml(kmlFileName);%%% x longitude , y latitude
  
  %%Step2: convert absolute coordinates to relative coordinates
  relativeCon = coordinateConvert(sectionBoundary,refCoff); 
  
  %%Step3: caculate overlap
  sectionPointsAfterOverlap = caculateOverlap(relativeCon,extendScaleForOverlap);
  
  %%Step4: caculate config file
   num = size(sectionPointsAfterOverlap,1);
  stSection = sectionStruct(num,sectionPointsAfterOverlap);
end




