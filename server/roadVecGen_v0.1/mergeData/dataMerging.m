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

function dblinesOut = dataMerging(newdata, dblinesIn)
% DATAMERGING
%    merge new data lines with database liens
%
%    INTPUT:
%    newdata   - new input line data
%    dblinesIn - input database line data
%
%    OUTPUT:
%    dblinesOut - database line data after merging
%

global PLOT_ON

% line merging
y1 = newdata(1).y;
b1 = dblinesIn(1).y;

pn1 = newdata(1).paint;
pd1 = dblinesIn(1).paint;

y2 = newdata(2).y;
b2 = dblinesIn(2).y;

pn2 = newdata(2).paint;
pd2 = dblinesIn(2).paint;

m1 = (y1 + 3 * b1) / 4;
m2 = (y2 + 3 * b2) / 4;
p1 = (pn1 + pd1);
p2 = (pn2 + pd2);

xlist = newdata(1).x;

% left line
dblinesOut(1).x = xlist;
dblinesOut(1).y = m1;
dblinesOut(1).paint = p1;
dblinesOut(1).count = dblinesIn(1).count + 1;

% right line
dblinesOut(2).x = xlist;
dblinesOut(2).y = m2;
dblinesOut(2).paint = p2;
dblinesOut(2).count = dblinesIn(2).count + 1;

% plot data
if PLOT_ON
    figure(600)
    subplot(3, 1, 1);
    ind1 = (p1 / max(p1)) >= 0.5;
    ind2 = (p2 / max(p2)) >= 0.5;
    
    plot(xlist(ind1), m1(ind1), 'r.', xlist(ind2), m2(ind2), 'b.');
    
    subplot(3, 1, 2);
    plot(xlist, p1, '-r.');
    grid on;
    subplot(3,1,3);
    plot(xlist, p2, '-b.');
    grid on;
end


end