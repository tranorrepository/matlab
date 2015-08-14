function bdatabase = generateBDatabase(segconfig, database, newdata)
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
%

load('common.mat');

color = cell(1, 3);
color{1} = 'b';
color{2} = 'g';
color{3} = 'r';

axislimit = [2000, 2200, 370, 500];

% number of new data sections
numOfNew = size(newdata, 1);

numOfSeg = size(segconfig, 1);
numOfDB  = size(database, 1);

% number of new data, segment configuration and database should be 1
if (1 ~= numOfNew) || (1 ~= numOfSeg) || (1 ~= numOfDB)
    error('input data segment is not correct!');
end

% check segment ID
if newdata{1, 1} ~= segconfig{1, 1} || newdata{1, 1} ~= database{1, 1} || ...
   segconfig{1, 1} ~= database{1, 1}
    error('segment ID not match!');
end

bdatabase = database;

% data base is empty
if isempty(database{1, 2})
    
    % data fitting and remapping
    % curve fitting for new data and add to database;
    
    % segment configuration for new segment
    % {ID, [full config], {line property}}
    %      [full config] 1x16
    %                     {{line property}} 1xM, M line
    %                      [1, 0], [0, 0], [0, 1]
    %
    
    % number of lanes in current segment
    numOfLanes = size(segconfig{1, 3}, 2);
    
    % init database lane info
    % two lines for each lane
    database{1, 2} = cell(1, numOfLanes);
    
    % line type of new data lines
    ltype = getLineType(newdata{1, 2}{1, 1});
    rtype = getLineType(newdata{1, 2}{1, 2});
    
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
        if 2 == sum((segconfig{1, 3}{1, ii} == lane))
            matchedLane = ii;
            break;
        end
    end
    
    
    % fitting for new data lines
    newlines = lineFitting(newdata{1, 2});
    
    % add these new lines to database
    bdatabase{1, 2}{1, matchedLane} = newlines;
    
    if 1 ~= PLOT_ON
        figure(10)
        ol1 = newdata{1, 2}{1, 1};
        ol2 = newdata{1, 2}{1, 2};
        
        plot(ol1(ol1(:, 3) == 1, X), ol1(ol1(:, 3) == 1, Y), ...
            'k.', 'MarkerSize', 1); hold on;
        plot(ol2(ol2(:, 3) == 1, X), ol2(ol2(:, 3) == 1, Y), 'k.', ...
            'MarkerSize', 1); hold on;
        axis equal
        
        nl1 = bdatabase{1, 2}{1, matchedLane}{1, 1};
        nl2 = bdatabase{1, 2}{1, matchedLane}{1, 2};
        
        plot(nl1(nl1(:, 3) == 1, X), nl1(nl1(:, 3) == 1, Y), ...
            'r.', 'MarkerSize', 1); hold on;
        plot(nl2(nl2(:, 3) == 1, X), nl2(nl2(:, 3) == 1, Y), ...
            'r.', 'MarkerSize', 1); hold on;
    end
% database is not empty
else
    % number of lanes in current segment
    numOfLanes = size(segconfig{1, 3}, 2);
    
    % line type of new data lines
    ltype = getLineType(newdata{1, 2}{1, 1});
    rtype = getLineType(newdata{1, 2}{1, 2});
    
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
        if 2 == sum((segconfig{1, 3}{1, ii} == lane))
            matchedLane = ii;
            break;
        end
    end
    
    % % plot data
    if PLOT_ON
        if ~isempty(database{1, 2})
            for iii = 1:size(database{1, 2}, 2)
                figure(400 + iii)
                ol = database{1, 2}{1, iii};
                if ~isempty(ol)
                    plot(ol{1}(ol{1}(:, PAINT_IND) == 1, X), ...
                        ol{1}(ol{1}(:, PAINT_IND) == 1, Y), ...
                        color{iii}, 'MarkerSize', 1); hold on;
                    plot(ol{2}(ol{2}(:, PAINT_IND) == 1, X), ...
                        ol{2}(ol{2}(:, PAINT_IND) == 1, Y), ...
                        color{iii}, 'MarkerSize', 1); hold on;
                    axis equal;
                end
                st = sprintf('Lane %d, section %d', iii, segconfig{1, 1});
                title(st);
                axis(axislimit);
            end
        end
    end
    
    nl1 = newdata{1, 2}{1, 1};
    nl2 = newdata{1, 2}{1, 2};
    
    if PLOT_ON
        figure(400 + matchedLane)
        plot(nl1(nl1(:, PAINT_IND) == 1, X), ...
             nl1(nl1(:, PAINT_IND) == 1, Y), ...
            'k', 'MarkerSize', 1); hold on;
        plot(nl2(nl2(:, PAINT_IND) == 1, X), ...
             nl2(nl2(:, PAINT_IND) == 1, Y), ...
            'k', 'MarkerSize', 1); hold on;
        
        st = sprintf('Lane %d, section %d', matchedLane, segconfig{1, 1});
        title(st);
        axis(axislimit);
    end
    
    % fitting for new data lines
    newlines = lineFitting(newdata{1, 2});
    
    % check lane data in database
    % lane is not empty in database, add it directly
    if isempty(database{1, 2}{1, matchedLane})
        
        % add these new lines to database
        bdatabase{1, 2}{1, matchedLane}     = newlines;
        
    % lane is not empty, merge with new data
    else
        dblines = database{1, 2}{1, matchedLane};
        
        % line merging
        dblines{1, 1} = lineMerging(dblines{1, 1}, ...
            newlines{1, 1});
        dblines{1, 2} = lineMerging(dblines{1, 2}, ...
            newlines{1, 2});
        
        % update date base
        bdatabase{1, 2}{1, matchedLane} = dblines;
    end
    
    % merged lane
    if PLOT_ON
        figure(400 + matchedLane)
        ol = bdatabase{1, 2}{1, matchedLane};
        if ~isempty(ol)
            plot(ol{1}(ol{1}(:, PAINT_IND) == 1, X), ...
                ol{1}(ol{1}(:, PAINT_IND) == 1, Y), ...
                'c', 'MarkerSize', 1); hold on;
            plot(ol{2}(ol{2}(:, PAINT_IND) == 1, X), ...
                ol{2}(ol{2}(:, PAINT_IND) == 1, Y), ...
                'c', 'MarkerSize', 1); hold on;
            axis equal; hold off;
            st = sprintf('Lane %d, section %d', ...
                         matchedLane, segconfig{1, 1});
            title(st);
            axis(axislimit);
        end
    end
    
    pause(1)
end
