% TEST_3
%
%

load('common.mat');
load('sectionConfig.mat');
load('database0_1.mat');
load('2.mat');

newdata = matchReportData;
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
    % segment ID of new data
    newSegID = newdata{ns, 1};
    
    if isempty(database{newSegID, 1})
        database{newSegID, 1} = newSegID;
    end
    
    % merge new data with backgound database
    bdatabase(newSegID, :) = generateBDatabase(segconfig(newSegID, :), ...
                                    database(newSegID, :), ...
                                    newdata(ns, :));

    % foreground database
    fdatabase(newSegID, :) = generateFDatabase(bdatabase(newSegID, :));
    
end % end of segment iteration