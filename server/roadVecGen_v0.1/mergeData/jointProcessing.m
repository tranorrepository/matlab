%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Continental Confidential
%                  Copyright (c) Continental, LLC. 2015
%
%      This software is furnished under license and may be used or
%      copied only in accordance with the terms of such license.
%
% Change Log:
%      Date                    Who                    What
%      2015/09/11              Ming Chen              Create
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nfdatabase = jointProcessing(fdatabase)
% JOINTPROCESSING
%    joint adjacent section connection part
%
%    INPUT:
%    fdatabase - all sections foreground database
%
%    OUTPUT:
%    nfdatabase - updated foreground database with adjacent connention part
%                 merged
%

nfdatabase = fdatabase;

% number of sections
numOfSegs = size(fdatabase, 2);

for curr = 1:numOfSegs
    if 1 == curr
        prev = numOfSegs;
    else
        prev = curr - 1;
    end
    
    if isempty(fdatabase(curr).lineData) || ...
       isempty(fdatabase(prev).lineData)
        continue
    end
    
    numOfCurrLines = size(fdatabase(curr).lineData, 1);
    numOfPrevLines = size(fdatabase(prev).lineData, 1);
    
    matchedInd = 1:numOfCurrLines;
    ind = 1;
    stPnts = struct('x', 0.0, 'y', 0.0, 'paint', 0.0, 'count', 0.0);
    edPnts = struct('x', 0.0, 'y', 0.0, 'paint', 0.0, 'count', 0.0);
    
    % find matched current start point and previous end point
    for ii = 1:numOfCurrLines
        if ii > numOfPrevLines
            matchedInd(ii) = -1;
        else
            if ~isempty(fdatabase(curr).lineData{ii}) && ...
                    ~isempty(fdatabase(prev).lineData{ii})
                % start point
                stPnts(ind).x = fdatabase(curr).lineData{ii}.x(1);
                stPnts(ind).y = fdatabase(curr).lineData{ii}.y(1);
                stPnts(ind).paint = fdatabase(curr).lineData{ii}.paint(1);
                stPnts(ind).count = fdatabase(curr).lineData{ii}.count(1);
                
                % end point
                edPnts(ind).x = fdatabase(prev).lineData{ii}.x(end);
                edPnts(ind).y = fdatabase(prev).lineData{ii}.y(end);
                edPnts(ind).paint = fdatabase(prev).lineData{ii}.paint(end);
                edPnts(ind).count = fdatabase(prev).lineData{ii}.count(end);
                
                ind = ind + 1;
            else
                matchedInd(ii) = -1;
            end
        end
    end
    
    if ~isempty(stPnts) && ~isempty(edPnts)
        matchedCnt = size(stPnts, 2);
        index = 1;
        for jj = 1:numOfCurrLines
            if isempty(fdatabase(curr).lineData{jj})
                continue;
            end
            
            if matchedInd(jj) == -1
                if jj < matchedCnt
                    ind = 1;
                else
                    ind = matchedCnt;
                end
                dx = edPnts(ind).x - stPnts(ind).x;
                dy = edPnts(ind).y - stPnts(ind).y;
            else
                dx = edPnts(index).x - stPnts(index).x;
                dy = edPnts(index).y - stPnts(index).y;
                index = index + 1;
            end
            
            numOfHalPnts = size(fdatabase(curr).lineData{jj}.x, 1);
            ddx = (linspace(dx, 0, numOfHalPnts))';
            ddy = (linspace(dy, 0, numOfHalPnts))';
            
            nfdatabase(curr).lineData{jj}.x(1:numOfHalPnts) = fdatabase(curr).lineData{jj}.x(1:numOfHalPnts) + ddx;
            nfdatabase(curr).lineData{jj}.y(1:numOfHalPnts) = fdatabase(curr).lineData{jj}.y(1:numOfHalPnts) + ddy;
        end
    end
    
end