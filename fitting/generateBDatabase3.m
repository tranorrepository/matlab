function bdatabase = generateBDatabase3(segconfig, database, newdata, theta, Xrange)
% GENERATEBDATABASEE
%   generate background database
%   merge reported new data with correspding lane in background database
%
%   INPUT:
%
%   segconfig - section configuration, including section ID, confige, and
%               lane information
%   databasse - background database
%               {1, 2}                  section ID, lanes
%                   ^
%                   |____ {1, M}        M lanes
%                             ^
%                             |__ [1x2] lines
%   newdata   - reported new data
%               {1, 2}                  section ID, lines
%                   ^
%                   |____________ [1x2] lines
%
%
%   bdatabase - new background database after mering new lane data
%
%  version : v1.0.0818

load('common.mat');

segID = segconfig{1,1};
fitFlag = (8 == segID)|(segID == 9)|(segID == 10)|(segID == 11) |(segID == 12)|(20 == segID)|(21 == segID)|(1 == segID);

if Xrange(3) < Xrange(4)
    xlist = Xrange(3):0.05:Xrange(4);
else
    xlist = Xrange(3):-0.05:Xrange(4);
end

bdatabase = database;
% Number of lanes in current segment
numOfLanes = size(segconfig{1, 3}, 2);
%% Step One : Lane number identificaiton.
% Input: newdata
% Ouput: Lane number
matchedLane = laneNumberEst(newdata,segconfig);

%% Step Two : Process new data before merging.       
newlines1 = dataPreProc(newdata{1,2},xlist,theta,fitFlag);     
  
%% Step Three: Process new data before merging.
if isempty(bdatabase{1, 2})
    bdatabase{1, 2} = cell(1, numOfLanes);
    bdatabase{1, 2}{1, matchedLane} = newlines1;
elseif isempty(bdatabase{1, 2}{1, matchedLane})
    bdatabase{1, 2}{1, matchedLane} = newlines1;
else
    dblines = bdatabase{1, 2}{1, matchedLane};
   % dblines1 = dataPreProc(dblines,xlist,theta,fitFlag); 
    newlines1 = dataMerging(newlines1,dblines);
    bdatabase{1, 2}{1, matchedLane} = newlines1;
end

figure(400)
subplot(3,1,matchedLane);
hold off
plot (newlines1{1,1}(:,1),newlines1{1,1}(:,2),'-r.');
hold on;
plot (newlines1{1,2}(:,1),newlines1{1,2}(:,2),'-b.')
grid on
axis equal
title('BG data')


