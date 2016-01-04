% data = data(7418:7617, :);
data = load('C:\Projects\source\newco_demo\Demo\Test\dbSectionProc\dbSectionProc\dbSectionProc\data\ford\dataStruct_1.txt');

%%% extract line data
left_line.x = data(:, 2);
left_line.y = data(:, 1);
left_line.p = data(:, 3);

right_line.x = data(:, 13);
right_line.y = data(:, 12);
right_line.p = data(:, 14);

middle_line.x = data(:, 10);
middle_line.y = data(:, 9);

%%% get painted points
pleft = find(left_line.p == 1.0);
pright = find(right_line.p == 1.0);

%%% mean distance to middle GPS of painted points
dleft = mean(sqrt((left_line.x(pleft) - middle_line.x(pleft)) .^ 2 + ...
                  (left_line.y(pleft) - middle_line.y(pleft)) .^2));
dright = mean(sqrt((right_line.x(pright) - middle_line.x(pright)) .^ 2 + ...
                   (right_line.y(pright) - middle_line.y(pright)) .^2));

%%% threshold value, if detected points is within this range compared to
%%% evaluated value
DIST = 0.5;

%%% distance of all points
ddleft = sqrt((left_line.x - middle_line.x) .^ 2 + (left_line.y - middle_line.y) .^2);
ddright = sqrt((right_line.x - middle_line.x) .^ 2 + (right_line.y - middle_line.y) .^2);

%%% find abnormal points
lindex = setdiff(find(abs(ddleft - dleft) > DIST), pleft);
rindex = setdiff(find(abs(ddright - dright) > DIST), pright);

numOfPnts = length(middle_line.x);
tmp_line.x = zeros(numOfPnts + 1, 1);
tmp_line.y = zeros(numOfPnts + 1, 1);

tmp_line.x(1:end-1) = middle_line.x;
tmp_line.y(1:end-1) = middle_line.y;
tmp_line.x(end) = 2 * middle_line.x(end) - middle_line.x(end-1);
tmp_line.y(end) = 2 * middle_line.y(end) - middle_line.y(end-1);

new_left_line = left_line;
new_right_line = right_line;

vl = zeros(length(lindex), 2);
nvl = vl;
orvl = vl;

for ii = 1:length(lindex)
    vl(ii, :) = [tmp_line.x(lindex(ii)+1) - tmp_line.x(lindex(ii)), ...
        tmp_line.y(lindex(ii)+1) - tmp_line.y(lindex(ii))];
    nvl(ii, :) = vl(ii, :) / norm(vl(ii, :));
    
    orvl(ii, :) = null(nvl(ii, :));
    
    new_left_line.x(lindex(ii)) = middle_line.x(lindex(ii)) + dleft * orvl(ii, 1);
    new_left_line.y(lindex(ii)) = middle_line.y(lindex(ii)) + dleft * orvl(ii, 2);
end

clf(figure(200));
% plot(left_line.x(pleft), left_line.y(pleft), 'r.'); hold on; axis equal;
% plot(right_line.x(pright), right_line.y(pright), 'b.');
plot(left_line.x, left_line.y, 'r.'); hold on; axis equal;
% plot(right_line.x, right_line.y, 'b.');
plot(middle_line.x, middle_line.y, 'g.');

plot(new_left_line.x, new_left_line.y, 'c.');
hold off;

