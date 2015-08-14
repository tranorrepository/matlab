% TEST_3
%
%

% close all; close all; clc

load('common.mat');
load('sectionConfig.mat');
load('database0.mat');
% load('sectionsGroup.mat');

newdata = sectionsDataOut;
segconfig = stSection;

% number of new data sections
numOfNew = size(newdata, 1);

numOfSeg = size(segconfig, 1);
numOfDB  = size(database, 1);

% size of segment configuration should be equal to database
if numOfDB ~= numOfSeg
    error('Database and segment number not match!');
end

% size of new data segment should be less than segment configuration
if numOfNew > numOfSeg
    error('new data segment number exceeds database number!');
end

% init background database
bdatabase = database;

% init foreground database
fdatabase = cell(numOfSeg, 2);


for ns = 1:numOfNew
    if ~isempty(newdata{ns, 1})
        % segment ID of new data
        newSegID = newdata{ns, 1};
        
        if isempty(database{newSegID, 1})
            database{newSegID, 1} = newSegID;
        end
        
        temp = cell(1, 2);
        temp{1, 1} = newSegID;
        temp{1, 2} = cell(1, 2);
        
        numOfNewSets = size(newdata(ns, :), 2) - 1;
        
        for ii = 2:numOfNewSets+1
            if ~(isempty(newdata{ns, ii}))
                temp{1, 2}{1, 1} = newdata{ns, ii}{1, 1}{1, 2};
                temp{1, 2}{1, 2} = newdata{ns, ii}{1, 2}{1, 2};
                
                % merge new data with backgound database
                bdatabase(newSegID, :) = ...
                    generateBDatabase(segconfig(newSegID, :), ...
                                      bdatabase(newSegID, :), temp);

                
% foreground database
%     fdatabase(newSegID, :) = generateFDatabase(bdatabase(newSegID, :));
            end
        end
    end
end % end of segment iteration