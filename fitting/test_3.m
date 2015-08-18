% TEST_3
%
%
% close all
clc
rng(12345);

load('common.mat');
% load('sectionConfig_0817.mat');
% %load('database0.mat');
% load('sectionsGroup_0817.mat');

load('sectionConfig.mat');
load('sectionsGroup_0815_1.mat');

if PLOT_ON
    clf(figure(100))
    clf(figure(201));
    clf(figure(301));
    clf(figure(401));
    clf(figure(402));
    clf(figure(403));
    
    clf(figure(10));
    clf(figure(11));
    clf(figure(12));
    clf(figure(13));
    clf(figure(20));
end

newdata = sectionsDataOut;
segconfig = stSection;

% number of new data sections
numOfNew = size(newdata, 1);

numOfSeg = size(segconfig, 1);

database = cell(numOfSeg,3);
numOfDB  = size(database, 1);

% % size of segment configuration should be equal to database
% if numOfDB ~= numOfSeg
%     error('Database and segment number not match!');
% end

% size of new data segment should be less than segment configuration
if numOfNew > numOfSeg
    error('new data segment number exceeds database number!');
end

% init background database
bdatabase = database;

% init foreground database
fdatabase = cell(numOfSeg, 2);

times = 1;
for kk = 1:10
    display(times)
    times = times + 1;
    clf(figure(13));
for ns = 1:21
    %ns = 13
   
    if ~isempty(newdata{ns, 1})
        % segment ID of new data
        newSegID = newdata{ns, 1}
       % if (12 == newSegID || 11 == newSegID || 8 == newSegID)
%        if (8 == newSegID)
%             continue;
%         end
        
        if isempty(bdatabase{newSegID, 1})
            bdatabase{newSegID, 1} = newSegID;
        end
        
        temp = cell(1, 2);
        temp{1, 1} = newSegID;
        temp{1, 2} = cell(1, 2);
        
        numOfNewSets = size(newdata(ns, :), 2) - 1;
        
        %% calculate theta and X for this section.
        [theta, X]= calcRotationAngle(segconfig,newSegID); 
        %theta = theta + pi/4;
        %%
        for jj = 1:3
            a = 2;
            b = numOfNewSets+1;
            ii = round((b-a).*rand(1,1) + a);
            
            if ~(isempty(newdata{ns, ii}))
                temp{1, 2}{1, 1} = newdata{ns, ii}{1, 1}{1, 2};
                temp{1, 2}{1, 2} = newdata{ns, ii}{1, 2}{1, 2};
                
                data1 = temp{1, 2}{1, 1};
                data2 = temp{1, 2}{1, 2};
                
                % merge new data with backgound database                 
                DB= generateBDatabase2(segconfig(newSegID, :), bdatabase(newSegID, :), temp,theta,X);
                bdatabase(newSegID, :) = DB;
            end
        end
        % foreground database
        % s
         
        backDB= generateFDatabase(bdatabase(newSegID, :),theta,X);
        fdatabase(newSegID, :) = backDB;
    end
end % end of segment iteration
end
 