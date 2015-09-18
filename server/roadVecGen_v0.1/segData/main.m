clear all;close all;clc;
addpath('.\');

videoListFile = '.\config\list.txt';
kmlFileName = '.\config\path.kml';
extendScaleForOverlap = 50; % m
maxIntervalForVideoSeg = 20; %row
samplingInterval = 20; 
refCoff = [11.758086000000000,48.354789000000000];

disp('Reading & Converting Data...');
%  [rptData] = readData(videoListFile);
disp('Read & Convert Data Completed!');

[sectionPointsAfterOverlap,stSection] = caculateConfig(kmlFileName,extendScaleForOverlap,refCoff);

disp('Starting Section Data...');
% [ sectionsDataOut ] = segMultiRptData( rptData,sectionPointsAfterOverlap,samplingInterval,extendScaleForOverlap);
disp('Section Data Completed!');
