function [newDataBase, newBodyData, newLandMark] = DatabaseUpdate( ...
                                                     sectionConfig, ...
                                                     dataBase, ...
                                                     newData, ...
                                                     landMark)
% DATABASEUPDATE
%   update database data accordding to new data
%
%   INPUT
%
%   sectionConfig - section configuration for database
%   dataBase      - database segmentation information, containing overlap
%   newData       - segmented new data, section information is added
%   landMark      - land mark in database (new data?)
%
%
%   OUTPUT
%
%   newDataBase   - new database data after merging lines
%   newBodyData   - body data for each section, no overlap
%   newLandMark   - new land mark after merging
%
%


% input parameters validate
numOfSegConfig  = size(sectionConfig, 1);
numOfSegDBData  = size(dataBase, 1);
numOfSegNewData = size(newData, 1);

if numOfSegConfig ~= numOfSegDBData || numOfSegDBData ~= numOfSegNewData
    error('Invalid input data for database update');
end

numOfDataSet = numOfSegDBData;

% data structure definition
newDataBase = dataBase;
newBodyData = 0;
newLandMark = landMark;

% iterate for each data section to merge lines
for ds = 1:numOfDataSet
    % secConfig is used to get section body
    secConfig  = sectionConfig(ds, :);
    
    % database data and new data
    segDBData  = dataBase(ds, :);
    segNewData = newData(ds, :);
    
    % check section ID
    if (secConfig{1, 1}  ~= segDBData{1, 1}) || ...
       (segNewData{1, 1} ~= segDBData{1, 1})
        continue;
    end
    
    % number of lines in current database section
    dbLines  = segDBData{1, 2};
    newLines = segNewData{1, 2};
    
    % step 1 - data fitting and remapping
    % curve fitting for new data;
    newLinesAfterFit = lineFitting(newLines);
    
    % step 2 - data matching and alignment
    % suppose it returns matched index and line type information
    % [D, index1, index2]
    %  |_________________overall shift distance for database and new data
    %                    (x, y) - first one for database, second one for
    %                    new data
    %       |____________the left line of new data matched line index in db
    %                |___the right line of new data matched line index in
    %                db
%     matchedLines = lineMatching(dbLines, ...
%                                 newLinesAfterFitting);
    matchedLines = cell(1, 3);
%     matchedLines{1, 1} = cell(1, 2);
    matchedLines{1, 1}{1, 1} = [0, 0];
    matchedLines{1, 1}{1, 2} = [0, 0];
    matchedLines{1, 2} = 1;
    matchedLines{1, 3} = 2;
    
    % step 3 - data shift
    dbLinesAfterFit = dbLines;
    dbLinesAfterShift  = shiftData(dbLinesAfterFit,  matchedLines{1, 1}{:, 1});
    newLinesAfterShift = shiftData(newLinesAfterFit, matchedLines{1, 1}{:, 2});
    
    % step 4 - data merging point-by-point
    dbLinesAfterShift{matchedLines{2}} = lineMerging(dbLinesAfterShift{matchedLines{2}}, ...
                                                     newLinesAfterShift{1});
    dbLinesAfterShift{matchedLines{3}} = lineMerging(dbLinesAfterShift{matchedLines{3}}, ...
                                                     newLinesAfterShift{2});
    % step 5 - update database
    newDataBase{ds} = dbLinesAfterShift;
    
    % database data
    ol1 = dataBase{ds, 2}{1, 1};
    ol2 = dataBase{ds, 2}{1, 2};
    
    plot(ol1(ol1(:, 3) == 1, 1), ol1(ol1(:, 3) == 1, 2), 'ko', 'MarkerSize', 3); hold on;
    plot(ol2(ol2(:, 3) == 1, 1), ol2(ol2(:, 3) == 1, 2), 'ko', 'MarkerSize', 3); hold on;
    
    axis equal
    
    % new data
    ol1 = newData{ds, 2}{1, 1};
    ol2 = newData{ds, 2}{1, 2};
    
    plot(ol1(ol1(:, 3) == 1, 1), ol1(ol1(:, 3) == 1, 2), 'bo', 'MarkerSize', 3); hold on;
    plot(ol2(ol2(:, 3) == 1, 1), ol2(ol2(:, 3) == 1, 2), 'bo', 'MarkerSize', 3); hold on;
    
    nl1 = dbLinesAfterShift{matchedLines{2}};
    nl2 = dbLinesAfterShift{matchedLines{3}};
    
    plot(nl1(:, 1), nl1(:, 2), 'c-', 'MarkerSize', 1); hold on;
    plot(nl2(:, 1), nl2(:, 2), 'c-', 'MarkerSize', 1); hold on;
    
    plot(nl1(nl1(:, 3) == 1, 1), nl1(nl1(:, 3) == 1, 2), 'ro', 'MarkerSize', 3); hold on;
    plot(nl2(nl2(:, 3) == 1, 1), nl2(nl2(:, 3) == 1, 2), 'ro', 'MarkerSize', 3); hold on;
    
end