function [center, length, theta, start, stop] = extractStopLine(lm_data)
% EXTRACTSTOPLINE
%    extract stop line feature, center point, length, angle
%
%    INPUT:
%    lm_data - landmark data, (x, y, g), x, y are position data, g is
%    group identifier.
%
%    OUTPUT:
%
%

% center
center.x = mean(lm_data.x);
center.y = mean(lm_data.y);
center.g = mean(lm_data.g);

sx = sortrows([lm_data.x, lm_data.y]);
sy = sortrows([lm_data.y, lm_data.x]);

% use linear polyfit to sample input data
[ppy, Sx, mux] = polyfit(sx(:, 1), sx(:, 2), 1);
py = polyval(ppy, sx(:, 1), Sx, mux);

[ppx, Sy, muy] = polyfit(sy(:, 1), sy(:, 2), 1);
px = polyval(ppx, sy(:, 1), Sy, muy);

mxy = mean(py - sx(:, 2));
myx = mean(px - sy(:, 2));
stdxy = std(py - sx(:, 2));
stdyx = std(px - sy(:, 2));

vxy = mxy + stdxy;
vyx = myx + stdyx;

if vxy <= vyx
    xresult = sx(:, 1);
    yresult = py;
    tag = 1;
else
    xresult = px;
    yresult = sy(:, 1);
    tag = -1;
end

% length
length = sqrt(power(xresult(end) - xresult(1), 2) + ...
    power(yresult(end) - yresult(1), 2));
 
% angle
theta = atan2(tag * (yresult(end) - yresult(1)), tag * (xresult(end) - xresult(1)));

% start and stop point
[start, stop] = calcEndPoints(center, length, theta);

% clf(figure(110))
% plot(lm_data.x, lm_data.y, '.', xresult, yresult, '.'); hold on; axis equal;
% plot(center.x, center.y, 'r*', 'MarkerSize', 5);
% plot([start.x, stop.x], [start.y, stop.y], 'g'); hold off;
% title(['group: ' num2str(center.g)]);

end


