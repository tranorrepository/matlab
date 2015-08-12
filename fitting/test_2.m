% TEST.M
%
%
%
load('common.mat');
load('sectionConfig.mat');

% load('2.mat');

figure(10)
% database = [];

load('database0.mat');
load('1.mat');

segconfig = stSection;
newdata = matchReportData;

% data base is empty
if isempty(database)
    % number of total segment
    numOfSeg = size(segconfig, 1);
    database = cell(numOfSeg, 2);
    
    % number of new data segment
    numOfNew = size(newdata, 1);
    
    % iterate each new data segment to create database
    for ns = 1:numOfNew
        % data fitting and remapping
        % curve fitting for new data and add to database;
        
        newSegID = newdata{ns, 1};
        
        % segment configuration for new segment
        % {ID, [full config], {line property}}
        %      [full config] 1x16
        %                     {{line property}} 1xM, M line
        %                      [1, 0], [0, 0], [0, 1]
        %
        segConf = segconfig(newSegID, :);
        
        % number of lanes in current segment
        numOfLanes = size(segConf{1, 3}, 2);
        
        % add segment ID to database
        database{newSegID, 1} = segConf{1, 1};
        
        % init database lane info
        database{newSegID, 2} = cell(1, numOfLanes + 1);
        
        % line type of new data lines
        ltype = getLineType(newdata{ns, 2}{1, 1});
        rtype = getLineType(newdata{ns, 2}{1, 2});
        
        if ltype == DASH_LINE
            l = 0;
        else
            l = 1;
        end
        if rtype == DASH_LINE
            r = 0;
        else
            r = 1;
        end
        
        lane = [l, r];
        
        % find matched lane
        matchedLane = 1;
        for ii = 1:numOfLanes
            if 2 == sum((segConf{1, 3}{1, ii} == lane))
                matchedLane = ii;
                break;
            end
        end
        
        
        % fitting for new data lines
        newlines = lineFitting(newdata{ns, 2});
        
        % add these new lines to database
        database{newSegID, 2}{1, matchedLane} = newlines{1, 1};
        database{newSegID, 2}{1, matchedLane + 1} = newlines{1, 2};
        
        ol1 = newdata{ns, 2}{1, 1};
        ol2 = newdata{ns, 2}{1, 2};
        
        plot(ol1(ol1(:, 3) == 1, X), ol1(ol1(:, 3) == 1, Y), 'k.', 'MarkerSize', 1); hold on;
        plot(ol2(ol2(:, 3) == 1, X), ol2(ol2(:, 3) == 1, Y), 'k.', 'MarkerSize', 1); hold on;
        axis equal
        
        nl1 = database{newSegID, 2}{1, matchedLane};
        nl2 = database{newSegID, 2}{1, matchedLane + 1};
        
        plot(nl1(nl1(:, 3) == 1, X), nl1(nl1(:, 3) == 1, Y), 'r.', 'MarkerSize', 1); hold on;
        plot(nl2(nl2(:, 3) == 1, X), nl2(nl2(:, 3) == 1, Y), 'r.', 'MarkerSize', 1); hold on;
        
        
    end
end

% save('database2.mat', 'database');

% database is not empty

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

% iterate for each segment of new data
for ns = 1:numOfNew
    % segment ID of new data
    newSegID = newdata{ns, 1};
    
    % get segment configuration
    segConf = segconfig(newSegID, :);
        
    % number of lanes in current segment
    numOfLanes = size(segConf{1, 3}, 2);
    
    % line type of new data lines
    ltype = getLineType(newdata{ns, 2}{1, 1});
    rtype = getLineType(newdata{ns, 2}{1, 2});
    
    if ltype == DASH_LINE
        l = 0;
    else
        l = 1;
    end
    if rtype == DASH_LINE
        r = 0;
    else
        r = 1;
    end
    
    lane = [l, r];
    
    % find matched lane
    matchedLane = 1;
    for ii = 1:numOfLanes
        if 2 == sum((segConf{1, 3}{1, ii} == lane))
            matchedLane = ii;
            break;
        end
    end
    
    % % plot data
    if ~isempty(database{newSegID, 2})
        for iii = 1:size(database{newSegID, 2}, 2)
            ol = database{newSegID, 2}{1, iii};
            if ~isempty(ol)
                plot(ol(ol(:, PAINT_IND) == 1, X), ...
                    ol(ol(:, PAINT_IND) == 1, Y), ...
                    'k.', 'MarkerSize', 1); hold on;
            end
        end
    end
    axis equal;
    
    nl1 = newdata{ns, 2}{1, 1};
    nl2 = newdata{ns, 2}{1, 2};
    plot(nl1(nl1(:, PAINT_IND) == 1, X), nl1(nl1(:, PAINT_IND) == 1, Y), ...
         'b.', 'MarkerSize', 1); hold on;
    plot(nl2(nl2(:, PAINT_IND) == 1, X), nl2(nl2(:, PAINT_IND) == 1, Y), ...
         'b.', 'MarkerSize', 1); hold on;
    
    % fitting for new data lines
    newlines = lineFitting(newdata{ns, 2});

    % check lane data in database
    % both lines of the lane is not in database
    if (isempty(database{newSegID, 2}) || ...
       (isempty(database{newSegID, 2}{1, matchedLane}) && ...
        isempty(database{newSegID, 2}{1, matchedLane + 1})))
    
        % add these new lines to database
        database{newSegID, 2} = cell(1, numOfLanes);
        database{newSegID, 2}{1, matchedLane}     = newlines{1, 1};
        database{newSegID, 2}{1, matchedLane + 1} = newlines{1, 2};
        
        
    % left is not empty, right is empty
    elseif (~isempty(database{newSegID, 2}{1, matchedLane}) && ...
            isempty(database{newSegID, 2}{1, matchedLane + 1}))
        
        dblines = database{newSegID, 2};
        
        % line match to get shift
        [dx, dy, MC] = lineMatching(dblines{1, matchedLane}, newlines{1, 2});
        
        % shift data according to matched distance
        avgCnt = round(mean(dblines{1, matchedLane}(:, 4)));
        R = reliability(avgCnt);
        vector = [0, 0]; %[dx, dy];
        dblinesShift = shiftData(dblines, (1 - R) * vector);
        newlinesShift = shiftData(newlines, R * vector);
        
        % line merging
        dblinesShift{1, matchedLane} = lineMerging(dblinesShift{1, matchedLane}, ...
                                                   newlinesShift{1, 1});
        dblinesShift{1, matchedLane + 1} = newlinesShift{1, 2};
        
        % update date base
        database{newSegID, 2} = dblinesShift;
        
    % left is empty, right is not empty
    elseif (isempty(database{newSegID, 2}{1, matchedLane}) && ...
            ~isempty(database{newSegID, 2}{1, matchedLane + 1}))
        
        dblines = database{newSegID, 2};
        
        % line match to get shift
        [dx, dy, MC] = lineMatching(dblines{1, matchedLane + 1}, newlines{1, 2});
        
        % shift data according to matched distance
        avgCnt = round(mean(dblines{1, matchedLane + 1}(:, 4)));
        R = reliability(avgCnt);
        vector = [0, 0]; % [dx, dy];
        dblinesShift = shiftData(dblines, (1 - R) * vector);
        newlinesShift = shiftData(newlines, R * vector);
        
        % line merging
        dblinesShift{1, matchedLane + 1} = lineMerging(dblinesShift{1, matchedLane + 1}, ...
                                                   newlinesShift{1, 2});
        dblinesShift{1, matchedLane} = newlinesShift{1, 1};
        
        % update date base
        database{newSegID, 2} = dblinesShift;
        
    % both are not empty
    else
        dblines = database{newSegID, 2};
        
        % line match to get shift
        if 1 == lane(1) && 0 == lane(2)
            [dx, dy, MC] = lineMatching(dblines{1, matchedLane + 1}, newlines{1, 2});
        elseif 0 == lane(1) && 1 == lane(2)
            [dx, dy, MC] = lineMatching(dblines{1, matchedLane}, newlines{1, 1});
        elseif 0 == lane(1) && 0 == lane(2)
            [dx1, dy1, MC1] = lineMatching(dblines{1, matchedLane}, newlines{1, 1});
            [dx2, dy2, MC2] = lineMatching(dblines{1, matchedLane + 1}, newlines{1, 2});
            dx = 0.5 * dx1 + 0.5 * dx2;
            dy = 0.5 * dy1 + 0.5 * dy2;
            MC = 0.5 * MC1 + 0.5 * MC2;
        else
        end
        
        % shift data according to matched distance
        avgCnt = round(sum(dblines{1, matchedLane}(:, 4)));
        R = reliability(avgCnt);
        vector = [0, 0]; % [dx, dy];
        dblinesShift = shiftData(dblines, (1 - R) * vector);
        newlinesShift = shiftData(newlines, R * vector);
        
        % line merging
        dblinesShift{1, matchedLane} = lineMerging(dblinesShift{1, matchedLane}, ...
                                                   newlinesShift{1, 1});
        dblinesShift{1, matchedLane + 1} = newlinesShift{1, 2};
        
        % update date base
        database{newSegID, 2} = dblinesShift;
    end
    
    % plot database data
    for iii = 1:size(database{newSegID, 2}, 2)
        ol = database{newSegID, 2}{1, iii};
        if ~isempty(ol)
            plot(ol(ol(:, PAINT_IND) == 1, X), ...
                ol(ol(:, PAINT_IND) == 1, Y), ...
                'ro', 'MarkerSize', 1); hold on;
        end
    end
    
end