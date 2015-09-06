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

% data format specification in MATLAB
% after segmentation, newData is the same format as database data
%
% sectionConfig
%
%   sectionID, body section, full section
%   N sections
%   cell(N, 2)
%      sectionID, cell(1, 16)
%                   body section (x, y), full section (x, y)
%
%                 5    1          2     6
%                 +----+----------+-----+
%                 |    |          |     |
%                 +----+----------+-----+
%                 7    3          4     8
%                       \________/
%                          body
%                  \___________________/
%                          full
%
%
% dataBase/newData
%
%    sectionID, lines
%                 line1,
%                     point - x, y, paintFlag, count
%                 line2,
%                  ....
%
%    N sections
%    cell(N, 2)
%       sectionID, cell(1, M) - M lines in this section
%                     (L, 4) - x, y, paintFlag, count
%
% landMark
%
%   current unknown
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
%     numOfDBLines  = size(dbLines);
%     numOfNewLines = size(newLines); % should be equal to 2
    
    % line match first
    % suppose it returns matched index, [left, right]
    % matchedLineIndex = lineMatching(dbLines, newLines);
    %
    matchedLineIndex = [1, 2];
    
    % use matched lines to merge
    dbLine1 = dbLines{1, matchedLineIndex(1)};
    dbLine2 = dbLines{1, matchedLineIndex(2)};
    
    newLine1 = newLines{1, 1};
    newLine2 = newLines{1, 2};
    
    dbLine1Type  = getLineType(dbLine1);
    dbLine2Type  = getLineType(dbLine2);
    newLine1Type = getLineType(newLine1);
    newLine2Type = getLineType(newLine2);
    
    % if line type not match, skip merge
    if (dbLine1Type ~= newLine1Type) || (dbLine2Type ~= newLine2Type)
        continue;
    end
        
    % merge lines according to line type
    mergedLine = mergeLines(dbLine1, newLine1, dbLine1Type, ...
                            dbLine2, newLine2, dbLine2Type);
    
    % plot data
    plot(dbLine1(:, 2), dbLine1(:, 1), ...
         '.', 'Color', [0.66, 0.66, 0.66], 'MarkerSize', 1); hold on;
    plot(dbLine2(:, 2), dbLine2(:, 1), ...
         '.', 'Color', [0.66, 0.66, 0.66], 'MarkerSize', 1); hold on;
    plot(newLine1(:, 2), newLine1(:, 1), ...
         '.', 'Color', [0.66, 0.66, 0.66], 'MarkerSize', 1); hold on;
    plot(newLine2(:, 2), newLine2(:, 1), ...
         '.', 'Color', [0.66, 0.66, 0.66], 'MarkerSize', 1); hold on;
    plot(mergedLine(:, 2), mergedLine(:, 1), ...
         'r.', 'MarkerSize', 2); hold on;
    
    
    newDataBase{ds, 2}{1, matchedLineIndex(1)} = mergedLine1;
    newDataBase{ds, 2}{1, matchedLineIndex(2)} = mergedLine2;
end


