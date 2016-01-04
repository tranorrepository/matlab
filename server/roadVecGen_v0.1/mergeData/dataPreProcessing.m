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

function [laneOut, laneNumber] = dataPreProcessing(laneIn, ...
                                                   xfulllist, xbodylist, ...
                                                   theta, segCfg)
% DATAPREPROCESSING
%    pre precoss input new data, to estimate lane number and output lane
%    data after rotating and resample
%
%    INPUT:
%    laneIn    - new input lane data, two lines, (x, y, paint, cnt)
%    xfulllist - x section full list of resampling with specified space
%    xbodylist - x section body list of resampling with specified space
%    theta     - section rotation angle
%    segCfg    - current section configuration parameters
%
%    OUTPUT:
%    laneOut    - output lane data after preprocessing
%    laneNumber - estimated lane number of input lane
%

global PLOT_ON

fitOrder = 6;

segID = segCfg.segId;
step = xfulllist(2) - xfulllist(1);

nl1 = laneIn(1);
nl2 = laneIn(2);

% plot new lane data
if PLOT_ON
    clf(figure(300))
    subplot(2,2,4)
    hold off
    plot(nl1.x(nl1.paint > 0), nl1.y(nl1.paint > 0), 'r.', ...
         nl2.x(nl2.paint > 0), nl2.y(nl2.paint > 0), 'b.');
    axis equal; grid on;
    title(['New data: SecID = ' num2str(segID)]);
end 


% Fitting for new data lines
% Rotate the newLines.
lineOut0 = rotateLine(nl1, -theta);
lineOut1 = rotateLine(nl2, -theta);

% find the both end of the line.
dotBlkIndex1 = dotLineBlockIndex(nl1);
dotBlkIndex2 = dotLineBlockIndex(nl2);

% map to x value on the xlist.
xx1 = lineOut0.x(dotBlkIndex1(:), 1);
xx2 = lineOut1.x(dotBlkIndex2(:), 1);

xx1 = reshape(xx1, length(xx1) / 2, 2);
xx2 = reshape(xx2, length(xx2) / 2, 2);

% get x index in the Xlist.
n = length(xfulllist);
ii1 = round((xx1 - xfulllist(1)) / step) + 1;
ii2 = round((xx2 - xfulllist(1)) / step) + 1;

% get the line within the section body
laneNumber = laneNumberEst(ii1, ii2, xbodylist, segCfg);

if isempty(laneNumber)
    laneOut = [];
else
    % get the paint within the whole section (overlap + body)
    paint1 = zeros(size(xfulllist));
    paint2 = zeros(size(xfulllist));
    
    for k = 1:size(ii1, 1)
        a1 = ii1(k, 1);
        b1 = ii1(k, 2);
        
        if (a1 >= 1) && (b1 <= n)
            paint1(a1:b1) = 1;
        elseif (a1 < 1) && (b1 > 1) && (b1 <= n)
            paint1(1:b1) = 1;
        elseif (a1 < 1) && (b1 > n)
            paint1(1:n) = 1;
        elseif (a1 >= 1)&& (b1 > n)
            paint1(a1:n) = 1;
        end
    end
    
    for k = 1:size(ii2, 1)
        a1 = ii2(k, 1);
        b1 = ii2(k, 2);
        if (a1 >= 1) && (b1 <= n)
            paint2(a1:b1) = 1;
        elseif (a1 < 1) && (b1 > 1) && (b1 <= n)
            paint2(1:b1) = 1;
        elseif (a1 < 1) && (b1 > n)
            paint2(1:n) = 1;
        elseif (a1 >= 1) && (b1 > n)
            paint2(a1:n) = 1;
        end
    end
    
    % data fitting
    ind0 = find(nl1.paint > 0);
    ind1 = find(nl2.paint > 0);
    
    lineOut0.x = lineOut0.x(ind0);
    lineOut0.y = lineOut0.y(ind0);
    
    lineOut1.x = lineOut1.x(ind1);
    lineOut1.y = lineOut1.y(ind1);
    
    index0 = intersect(find(lineOut0.x), find(lineOut0.y));
    index1 = intersect(find(lineOut1.x), find(lineOut1.y));
    
    % first line
    % interpolation sample
    xin = lineOut0.x(index0);
    yin = lineOut0.y(index0);
    [y01] = interpolateSample(xfulllist, xin, yin);
    
    xin = lineOut1.x(index1);
    yin = lineOut1.y(index1);
    [y02] = interpolateSample(xfulllist, xin, yin);
    
    % polynomial fitting
    [p, S, mu] = polyfit(lineOut0.x(index0), lineOut0.y(index0), fitOrder);
    [y11, ~] = polyval(p, xfulllist, S, mu);
    
    % second line
    [p, S, mu] = polyfit(lineOut1.x(index1), lineOut1.y(index1), fitOrder);
    [y12, ~] = polyval(p, xfulllist, S, mu);
    
    dy0 = y01(:) - y02(:);
    meanY0 = mean(dy0);
    stdY0 = std(dy0);
    
    dy1 = y11(:) - y12(:);
    meanY1 = mean(dy1);
    stdY1 = std(dy1);
    
    cond00 = 3 < abs(meanY0) && abs(meanY0) < 6;
    cond01 = stdY0 < 3;
    
    cond10 = 3 < abs(meanY1) && abs(meanY1) < 6;
    cond11 = stdY1 < 3;
    
    if (cond00 && cond01 && cond10 && cond11)
        if (cond01 < cond11)
            y1 = y01;
            y2 = y02;
        else
            y1 = y11;
            y2 = y12;
        end
    elseif cond00 && cond01
        y1 = y01;
        y2 = y02;
    elseif cond10 && cond11
        y1 = y11;
        y2 = y12;
    else
        y1 = [];
        y2 = [];
    end
    if ~isempty(y1)
        laneOut(1).x = xfulllist;
        laneOut(1).y = y1;
        laneOut(1).paint = paint1;
        laneOut(1).count = 0;
        
        laneOut(2).x = xfulllist;
        laneOut(2).y = y2;
        laneOut(2).paint = paint2;
        laneOut(2).count = 0;
        
        % plot
        if PLOT_ON
            figure(300)
            subplot(2, 2, laneNumber)
            plot(xfulllist(paint1 > 0), y1(paint1 > 0), 'r.', ...
                 xfulllist(paint2 > 0), y2(paint2 > 0), 'b.');
            axis equal; grid on; hold off
            title(['Lane number =' num2str(laneNumber) ', SecID = ' num2str(segID)]);
            
            clf(figure(301))
            subplot(3, 1, 1)
            plot(xfulllist, y1, 'r.', xfulllist, y2, 'b.');
            axis equal; grid on; hold off
            title(['Lane number = ' num2str(laneNumber) ', SecID = ' num2str(segID)]);
            
            
            sp = floor(n / 100);
            mp = mod(n, 100);
            pp = floor((mp - 1) / 2);
            id = 1 + pp:sp:100*sp + pp;
            subplot(3, 1, 2)
            plot(xfulllist, 10 * paint1, '-r.'); hold on;
            plot(xfulllist(id), 10 * paint1(id), '-g.');
            axis equal; grid on; hold off
            title(['Paint Lane number = ' num2str(laneNumber) ', SecID = ' num2str(segID)]);
            if step < 0.0
                axis([xfulllist(end) xfulllist(1) -5 15]);
            else
                axis([xfulllist(1) xfulllist(end) -5 15]);
            end
            
            subplot(3, 1, 3)
            plot(xfulllist, 10 * paint2, '-b.'); hold on;
            plot(xfulllist(id), 10 * paint2(id), '-g.');
            axis equal; grid on; hold off
            title(['Paint Lane number = ' num2str(laneNumber) ', SecID = ' num2str(segID)]);
            if step < 0.0
                axis([xfulllist(end) xfulllist(1) -5 15]);
            else
                axis([xfulllist(1) xfulllist(end) -5 15]);
            end
        end
    else
        laneOut = [];
    end
end


end
