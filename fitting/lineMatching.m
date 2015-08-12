function matchedLines = lineMatching(dbLines, newLines)
% LINEMATCHING
%   line match for merging process
%
%
%   INPUT:
%
%   dbLines  - lines in database
%   newLines - lines in new input data, suppose it's 2, left right
%
%   OUTPUT:
%
%   matchedLines - [D, index1, index2]
%                  |_________________overall shift distance for database
%                                    and new data
%                                    (x, y) - first one for database,
%                                    second one for new data
%                       |____________the left line of new data matched line
%                                    index index in db
%                                |___the right line of new data matched
%                                    line index in db
%                                    -1 is invalid, no lines in db, so just
%                                    need to add new lines
%
% ------------------------------------------------------------------------
%   Author: Ming Chen, Aug 12, 2015 created
% ------------------------------------------------------------------------
%

% lane information
laneNum = size(dbLines, 2) - 1;

MC = zeros(laneNum, 1);
dx = cell(laneNum, 1);
dy = cell(laneNum, 1);

% try each possible lane to find the best match lane
for ln = 1:laneNum
    [dx1, dy1, MC1] = lineMatchAlign(dbLines{1, ln  }, newLines{1, 1});
    [dx2, dy2, MC2] = lineMatchAlign(dbLines{1, ln+1}, newLines{1, 2});
    MC(ln) = MC1 * MC2;
    dx{ln} = 0.5 * dx1 + 0.5 * dx2;
    dy{ln} = 0.5 * dy1 + 0.5 * dy2;
end

% maximum lane index
[~, laneInd] = max(MC);

% output initialization
matchedLines = cell(1, 3);
matchedLines{1, 2} = laneInd;
matchedLines{1, 3} = laneInd + 1;

% shift distance
D = cell(1, 2);
D{1, 1} = [0, 0];
D{1, 2} = [0, 0];
matchedLines{1, 1} = D;

end % end of function lineMatching


%%
function [dx, dy, MC] = lineMatchAlign(dbline, newline)
%
%

load('common.mat');

% dash line block start/stop index
dbBlk  = dotLineBlockIndex(dbline);
newBlk = dotLineBlockIndex(newline);

% get (x, y) position for each dash line
a =  newline(newBlk(:), X);
x1{1} = reshape(a, length(a)/2, 2);

% get y position for each dash line
a =  newline(newBlk(:), Y);
y1{1} = reshape(a, length(a)/2, 2);

% get x position for each dash line
a =  dbline(dbBlk(:), X);
x1{2} = reshape(a, length(a)/2, 2);

% get y position for each dash line
a =  dbline(dbBlk(:), 2);
y1{2} = reshape(a, length(a)/2, 2);

% match on x axis and y axis.
[dx, MCx] = axisMatch(x1);
[dy, MCy] = axisMatch(y1);

% final Matching Coefficient on both directions.
MC = MCx*MCy;

end % end of lineMatchAlign


%%
function [delta, MC] = axisMatch(xy)
%
%

% find x/y range: [min max]
for ii = 1:2
    minxx(ii) = min(min(xy{ii}));
    maxxx(ii) = max(max(xy{ii}));
end
minx = min(minxx);
maxx = max(maxxx);

A = -1 * ones(round(maxx - minx) * 10 + 50, 2);
for ii = 1:2
    a = min(xy{ii}, [], 2);
    b = max(xy{ii}, [], 2);
    
    a = round((a - minx) * 10);
    b = round((b - minx) * 10);
    
    for jj = 1:length(a)
        range = 1 + (a(jj):b(jj));
        A(range,ii) = 1;
    end
end

[X, lags]= xcorr(A(:, 1), A(:, 2));

% for debug
% figure(80);
% plot(A),ylim([-2 2]);
% figure(90);
% plot(X,'-o')

[M, I] = max(X);
delta = lags(I);

% compute coefficient in x axis
n1 = norm(A(:, 1));
n2 = norm(A(:, 2));

MC = M/n1/n2;

end % end of axisMatch