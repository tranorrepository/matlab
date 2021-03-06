function fdatabase = generateFDatabase(database,theta,Xrange)
% GENERATEFDATABASE
%
%   INPUT:
%
%   database -
%             {1, 2}         section info
%                 {1, M} M   lanes info
%                     [1, 2] lines info
%
%   OUTPUT:
%
%   fdatabase -
%               {1, 2}
%                   {1, 4} lines

load('common.mat');

color = cell(1, 3);
color{1, 1} = 'b.';
color{1, 2} = 'g.';
color{1, 3} = 'c.';

% foreground database
fdatabase = cell(1, 2);

% iterate each database segment
% segment ID of database
segID = database{1, 1};
fdatabase{1, 1} = segID;

% num of lanes in current segment
numOfLanes = size(database{1, 2}, 2);
if numOfLanes == 0
    return;
end
% remove the empty lane.
if (numOfLanes == 3)&&isempty(database{1, 2}{1,2})
    numOfLanes = 1;
end

% calcualte the valid lanes number, and record the number of start
% lane.
offset = 0;
validLaneIndex = 1:numOfLanes;
for lane = 1:numOfLanes
    if isempty(database{1, 2}{1,lane})
        numOfLanes = numOfLanes -1;
        validLaneIndex(lane) = -1;
    else
        if (offset==0)
            offset = lane;
        end
    end
end
% if 1, 3 lane valid, keep lane 1 and discard lane 3.
%size = size(database{1, 2}{1,2},2);
if (numOfLanes==2&isempty(database{1, 2}{1,2}))
    numOfLanes = 1;
    validLaneIndex(2) = -1;
end

% apply rotation
for lane = validLaneIndex(validLaneIndex>0)
    lane
    database
    lineIn.x = database{1, 2}{1,lane}{1,1}(:,1);
    lineIn.y = database{1, 2}{1,lane}{1,1}(:,2);
    lineOut = rotline(lineIn,-theta);
    database{1, 2}{1,lane}{1,1}(:,1) = lineOut.x;
    database{1, 2}{1,lane}{1,1}(:,2) = lineOut.y;
    
    lineIn.x = database{1, 2}{1,lane}{1,2}(:,1);
    lineIn.y = database{1, 2}{1,lane}{1,2}(:,2);
    lineOut = rotline(lineIn,-theta);
    database{1, 2}{1,lane}{1,2}(:,1) = lineOut.x;
    database{1, 2}{1,lane}{1,2}(:,2) = lineOut.y;
end

if PLOT_ON
    figure(20)
    % background database
    for ll = 1:numOfLanes
        if ~isempty(database{1, 2}{1, ll})
            ol1 = database{1, 2}{1, ll}{1, 1};
            ol2 = database{1, 2}{1, ll}{1, 2};
            plot(ol1(:, X), ...
                ol1(:, Y), color{ll}); hold on;
            plot(ol2(:, X), ...
                ol2(:, Y), color{ll}); hold on;
        end
    end
    axis equal
    grid on
    title('foreground data + data rotation');
end

%% data fitting
if Xrange(3) < Xrange(4)
    xlist = Xrange(3):0.05:Xrange(4);
else
    xlist = Xrange(3):-0.05:Xrange(4);
end


A = zeros(length(xlist),numOfLanes*2);
for lane = validLaneIndex(validLaneIndex>0)
    % first line
    x = database{1, 2}{1,lane}{1,1}(:,1);
    y = database{1, 2}{1,lane}{1,1}(:,2);
    index = intersect(find(x),find(y));
    [p, S, mu] = polyfit(x(index),y(index),8);
    [A(:,lane*2-1), ~] = polyval(p, xlist, S, mu);
    
    % second line
    x = database{1, 2}{1,lane}{1,2}(:,1);
    y = database{1, 2}{1,lane}{1,2}(:,2);
    [p, S, mu] = polyfit(x,y,8);
    [A(:,lane*2), ~] = polyval(p, xlist, S, mu);
end

if 0
    figure(11)
    plot(xlist,A,'-o');
    axis equal
    grid on;
end
%%
% merge lane common lines
middleLine = cell(1,numOfLanes-1);
for n = 1:numOfLanes-1
    % merge middle line
    middleLine{1,n} = (A(:,2*n) + A(:,2*n+1))/2;
end
if (numOfLanes == 1)
    return
elseif (numOfLanes == 1)
    B(:,1) = A(:,1);
    B(:,2) = A(:,2);
elseif  (numOfLanes == 2)
    d0 = middleLine{1,1} - A(:,2);
    d1 = middleLine{1,1} - A(:,3);
    B(:,1) = A(:,1)+ d0;
    B(:,2) = middleLine{1,1};
    B(:,3) = A(:,4)+ d1;
    
elseif (numOfLanes == 3)
    d0 = middleLine{1,1} - A(:,2);
    d1 = middleLine{1,1} - A(:,3);
    
    d2 = middleLine{1,2} - A(:,4);
    d3 = middleLine{1,2} - A(:,5);
    
    B(:,1) = A(:,1)+ d0+d2;
    B(:,2) = middleLine{1,1}+d2;
    B(:,3) = middleLine{1,2}+d1;
    B(:,4) = A(:,6)+ d1 + d3;
else
    warning('Do not support more than 3 lane yet.');
    return;
end
if 0
    figure(12)
    plot(xlist,B,'-o');
    axis equal
    grid on;
end
%% cut off the overlap part
if Xrange(1) < Xrange(2)
    index = find(xlist >=  Xrange(1) & xlist <=  Xrange(2));
else
    index = find(xlist <=  Xrange(1) & xlist >=  Xrange(2));
end

%
%% rotation back to original direction.
figure(13);
for lane = 1:numOfLanes+1
    lineIn.x = xlist(index)';
    lineIn.y = B(index,lane);
    lineOut = rotline(lineIn,theta);
    fdatabase{1, 2}{1,lane} = [lineOut.x lineOut.y];
    
    % fixme later!
    if lane == 1
        %   fdatabase{lane, 2}(:,3) = database{1,2}{1,1};
        %   fdatabase{lane, 2}(:,4) = lineOut.y;
    else
    end
    plot(lineOut.x,lineOut.y,'-.');
    hold on
    grid on
    axis equal;
end
end