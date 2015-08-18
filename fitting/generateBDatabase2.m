function bdatabase = generateBDatabase2(segconfig, database, newdata, theta, Xrange)
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

fitOrder = 6;

segID = segconfig{1,1};

segFlag = (8 == segID)|(segID == 9)|(segID == 10)|(segID == 11) |(segID == 12)|(20 == segID)|(21 == segID)|(1 == segID);

color = cell(1, 3);
color{1} = 'b';
color{2} = 'g';
color{3} = 'r';

% axislimit = [2000, 2200, 370, 500];
if Xrange(3) < Xrange(4)
    xlist = Xrange(3):0.05:Xrange(4);
else
    xlist = Xrange(3):-0.05:Xrange(4);
end
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
    % if 1
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
    bdatabase{1, 2} = cell(1, numOfLanes);
    
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
    %% fitting for new data lines
    nl1 = newdata{1, 2}{1, 1};
    nl2 = newdata{1, 2}{1, 2};
    % rotate the newLines.
    lineIn.x = nl1(nl1(:, PAINT_IND) >= 0,1);
    lineIn.y = nl1(nl1(:, PAINT_IND) >= 0,2);
    lineOut0 = rotline(lineIn,-theta);
    
    lineIn.x = nl2(nl2(:, PAINT_IND) >= 0,1);
    lineIn.y = nl2(nl2(:, PAINT_IND) >= 0,2);
    lineOut1 = rotline(lineIn,-theta);
    
    %% data fitting
    % first line
    if segFlag
        index = intersect(find(lineOut0.x),find(lineOut0.y));
        v = lineOut0.x(index);
        w = lineOut0.y(index);
        [y1] = myResample(xlist,w,v);
        % plot
        figure(100)
        subplot(2,1,1);
        plot(xlist,y1,'-b*');
        hold on
        plot(v,w,'-ro');
        grid on
        axis equal;
        title('Resample');
        
        index = intersect(find(lineOut1.x),find(lineOut1.y));
        v = lineOut1.x(index);
        w = lineOut1.y(index);
        [y2] = myResample(xlist,w,v);
        
        subplot(2,1,2);
        plot(xlist,y2,'-b*');
        hold on
        plot(v,w,'-ro');
        grid on
        axis equal;
        title('Resample');
        
    else
        index = intersect(find(lineOut0.x),find(lineOut0.y));
        [p, S, mu] = polyfit(lineOut0.x(index),lineOut0.y(index),fitOrder);
        [y1, ~] = polyval(p, xlist, S, mu);
        
        % second line
        index = intersect(find(lineOut1.x),find(lineOut1.y));
        [p, S, mu] = polyfit(lineOut1.x(index),lineOut1.y(index),fitOrder);
        [y2, ~] = polyval(p, xlist, S, mu);
    end
    
    
    line1.x = xlist;
    line1.y = y1;
    line2.x = xlist;
    line2.y = y2;
    
    lineOut1 = rotline(line1,theta);
    lineOut2 = rotline(line2,theta);
    newlines = { [lineOut1.x' lineOut1.y'] ,[lineOut2.x' lineOut2.y'] };
    % add these new lines to database
    bdatabase{1, 2}{1, matchedLane}     = newlines;
    
    if 1 == PLOT_ON
        figure(10)
        ol1 = newdata{1, 2}{1, 1};
        ol2 = newdata{1, 2}{1, 2};
        
        plot(ol1(ol1(:, 3) == 1, X), ol1(ol1(:, 3) == 1, Y), ...
            'k.', 'MarkerSize', 1); hold on;
        plot(ol2(ol2(:, 3) == 1, X), ol2(ol2(:, 3) == 1, Y), 'k.', ...
            'MarkerSize', 1); hold on;
        axis equal
        
        nl1 = newlines{1,1};
        nl2 = newlines{1,2};
        
        plot(nl1(:, X), nl1(:, Y), ...
            'r.', 'MarkerSize', 1); hold on;
        plot(nl2(:, X), nl2(:, Y), ...
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
    if PLOT_ON == 0
        if ~isempty(database{1, 2})
            for iii = 1:size(database{1, 2}, 2)
                figure(400 + iii)
                ol = database{1, 2}{1, iii};
                if ~isempty(ol)
                    plot(ol{1}(ol{1}(:, PAINT_IND) > 0, X), ...
                        ol{1}(ol{1}(:, PAINT_IND) > 0, Y), ...
                        color{iii}, 'MarkerSize', 3); hold on;
                    plot(ol{2}(ol{2}(:, PAINT_IND) > 0, X), ...
                        ol{2}(ol{2}(:, PAINT_IND) > 0, Y), ...
                        color{iii}, 'MarkerSize', 3); hold on;
                    axis equal;
                else
                    clf(figure(400 + iii));
                end
                st = sprintf('Lane %d, section %d', iii, segconfig{1, 1});
                title(st);
                %                 axis(axislimit);
            end
        end
    end
    
    nl1 = newdata{1, 2}{1, 1};
    nl2 = newdata{1, 2}{1, 2};
    
    if PLOT_ON == 1
        figure(400 + matchedLane)
        plot(nl1(nl1(:, PAINT_IND) == 1, X), ...
            nl1(nl1(:, PAINT_IND) == 1, Y), ...
            'k.', 'MarkerSize', 1); hold on;
        plot(nl2(nl2(:, PAINT_IND) == 1, X), ...
            nl2(nl2(:, PAINT_IND) == 1, Y), ...
            'k.', 'MarkerSize', 1); hold on;
        axis equal;
        
        st = sprintf('Lane %d, section %d', matchedLane, segconfig{1, 1});
        title(st);
        %         axis(axislimit);
    end
    
    %% fitting for new data lines
    % rotate the newLines.
    lineIn.x = nl1(nl1(:, PAINT_IND) >= 0,1);
    lineIn.y = nl1(nl1(:, PAINT_IND) >= 0,2);
    lineOut0 = rotline(lineIn,-theta);
    
    lineIn.x = nl2(nl2(:, PAINT_IND) >= 0,1);
    lineIn.y = nl2(nl2(:, PAINT_IND) >= 0,2);
    lineOut1 = rotline(lineIn,-theta);
    
    %% data fitting
    % first line
     if segFlag
        index = intersect(find(lineOut0.x),find(lineOut0.y));
        v = lineOut0.x(index);
        w = lineOut0.y(index);
        [y1] = myResample(xlist,w,v);
        
        index = intersect(find(lineOut1.x),find(lineOut1.y));
        v = lineOut1.x(index);
        w = lineOut1.y(index);
        [y2] = myResample(xlist,w,v);
    else
        
        index = intersect(find(lineOut0.x),find(lineOut0.y));
        [p, S, mu] = polyfit(lineOut0.x(index),lineOut0.y(index),fitOrder);
        [y1, ~] = polyval(p, xlist, S, mu);
        % second line
        index = intersect(find(lineOut1.x),find(lineOut1.y));
        [p, S, mu] = polyfit(lineOut1.x(index),lineOut1.y(index),fitOrder);
        [y2, ~] = polyval(p, xlist, S, mu);
    end
    
    % check lane data in database
    % lane is not empty in database, add it directly
    if isempty(database{1, 2}{1, matchedLane})
        %if 1
        line1.x = xlist;
        line1.y = y1;
        line2.x = xlist;
        line2.y = y2;
        
        lineOut1 = rotline(line1,theta);
        lineOut2 = rotline(line2,theta);
        newlines = { [lineOut1.x' lineOut1.y'] ,[lineOut2.x' lineOut2.y'] }
        % add these new lines to database
        bdatabase{1, 2}{1, matchedLane}     = newlines;
        
        % lane is not empty, merge with new data
    else
        dblines = database{1, 2}{1, matchedLane};
        
        % rotate BG database
        bg1 = dblines{1, 1};
        bg2 = dblines{1, 2};
        
        lineIn.x = bg1(:,1);
        lineIn.y = bg1(:,2);
        bgOut1 = rotline(lineIn,-theta);
        
        lineIn.x = bg2(:,1);
        lineIn.y = bg2(:,2);
        bgOut2 = rotline(lineIn,-theta);
        
        %% data fitting
         if segFlag
            index = intersect(find(bgOut1.x),find(bgOut1.y));
            v = bgOut1.x(index);
            w = bgOut1.y(index);
            [b1] = myResample(xlist,w,v);
            
            index = intersect(find(bgOut2.x),find(bgOut2.y));
            v = bgOut2.x(index);
            w = bgOut2.y(index);
            [b2] = myResample(xlist,w,v);
        else
            % first line
            index = intersect(find(bgOut1.x),find(bgOut1.y));
            [p, S, mu] = polyfit(bgOut1.x(index),bgOut1.y(index),fitOrder);
            [b1, ~] = polyval(p, xlist, S, mu);
            
            % second line
            index = intersect(find(bgOut2.x),find(bgOut2.y));
            [p, S, mu] = polyfit(bgOut2.x(index),bgOut2.y(index),fitOrder);
            [b2, ~] = polyval(p, xlist, S, mu);
        end
        
        %% line merging
        % line merging
        m1 = (y1 + b1)/2;
        m2 = (y2 + b2)/2;
        
        line1.x = xlist;
        line1.y = m1;
        line2.x = xlist;
        line2.y = m2;
        
        lineOut1 = rotline(line1,theta);
        lineOut2 = rotline(line2,theta);
        dblines = { [lineOut1.x' lineOut1.y'] ,[lineOut2.x' lineOut2.y'] };
        
        % update date base
        bdatabase{1, 2}{1, matchedLane} = dblines;
    end
    
    % merged lane
    if PLOT_ON == 1
        figure(400 + matchedLane)
        ol = bdatabase{1, 2}{1, matchedLane};
        if ~isempty(ol)
            plot(ol{1}(:, X), ...
                ol{1}(:, Y), ...
                color{matchedLane}, 'MarkerSize', 3); hold on;
            plot(ol{2}(:, X), ...
                ol{2}(:, Y), ...
                color{matchedLane}, 'MarkerSize', 3); hold on;
            axis equal; grid on;hold off;
            st = sprintf('Lane %d, section %d', ...
                matchedLane, segconfig{1, 1});
            title(st);
            %             axis(axislimit);
        end
        
        hold off;
    end
    
    pause(1)
end
end


function [yy] = myResample(xlist,w,v)

X1 = xlist(1);
X2 = xlist(end);

ind0 = 1;
yy = zeros(1,length(xlist));
for kk = 1: length(xlist)
    %find X1 X2
    xx = xlist(kk);
    if (X1 < X2)
        x1 = v(ind0);
        y1 = w(ind0);
        while xx > x1
            ind0 = ind0 + 1;
            if ind0 < length(v)
                x1 = v(ind0);
                y1 = w(ind0);
            else
                ind0 = ind0 -1;
                x1 = v(ind0);
                y1 = w(ind0);
                break;
            end
        end
        if (ind0 >1)
            x0 = v(ind0-1);
            y0 = w(ind0-1);
        else
            x0 = v(1);
            y0 = w(1);
        end
        if (x0 == x1)
            yy(kk) = y0;
        else
            yy(kk) =  (x0-xx)/(x0-x1)*y1 + (xx-x1)/(x0-x1)*y0;
        end
    else
        x1 = v(ind0);
        y1 = w(ind0);
        while xx < x1
            ind0 = ind0 + 1;
            if ind0 < length(v)
                x1 = v(ind0);
                y1 = w(ind0);
            else
                ind0 = ind0 -1;
                x1 = v(ind0);
                y1 = w(ind0);
                break;
            end
        end
        if (ind0 >1)
            x0 = v(ind0-1);
            y0 = w(ind0-1);
        else
            x0 = v(1);
            y0 = w(1);
        end
        if (x0 == x1)
            yy(kk) = y0;
        else
            yy(kk) =  (x0-xx)/(x0-x1)*y1 + (xx-x1)/(x0-x1)*y0;
        end
    end
end
end