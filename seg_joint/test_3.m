data1 = load('fgroup_18.txt');
data2 = load('fgroup_19.txt');
data3 = load('fgroup_20.txt');

p1 = data1(:, 3);
p2 = data2(:, 3);
p3 = data3(:, 3);

figure(101)
clf(101)
subplot(2, 2, 1)
plot(data1(p1 >= 0.5, 1), data1(p1 >= 0.5, 2), 'b.'); hold on; axis equal
plot(data2(p2 >= 0.5, 1), data2(p2 >= 0.5, 2), 'g.');
plot(data3(p3 >= 0.5, 1), data3(p3 >= 0.5, 2), 'b.');
title('original data'); grid on;
hold off;

st1 = [data1(1, 1:2);    data1(2180, 1:2); data1(4360, 1:2); data1(6540, 1:2)];
ed1 = [data1(2179, 1:2); data1(4359, 1:2); data1(6539, 1:2); data1(end, 1:2)];

st2 = [data2(1, 1:2);    data2(1322, 1:2)];
ed2 = [data2(1321, 1:2); data2(end, 1:2)];

st3 = [data3(1, 1:2);   data3(874, 1:2);];
ed3 = [data3(873, 1:2); data3(end, 1:2)];

count = 2;

xy = round(max(abs([st3(1:count, :) - ed2; ed1(1:count, :) - st2])));
dx = xy(1);
dy = xy(2);
dmax = 6 * (dx^2 + dy^2);
d1 = ed2;
d2 = st2;
oddx = [];
oddy = [];

for ddx = -dx:0.1:dx
    for ddy = -dy:0.1:dy
        d1(:, 1) = ed2(:, 1) + ddx;
        d1(:, 2) = ed2(:, 2) + ddy;
        d2(:, 1) = st2(:, 1) + ddx;
        d2(:, 2) = st2(:, 2) + ddy;
        d3 = st3(1:count, :) - d1;
        d4 = ed1(1:count, :) - d2;
        d = sum(sum(d3 .* d3)) + sum(sum(d4 .* d4));
        if d < dmax
            dmax = d;
            
            oddx = ddx;
            oddy = ddy;
        end
    end
end
out = [sqrt(dmax), oddx, oddy]

ndata1 = data2;
ndata1(:, 1) = data2(:, 1) + oddx;
ndata1(:, 2) = data2(:, 2) + oddy;
ndata1(:, 3) = data2(:, 3);

figure(101)
subplot(2, 2, 2)
plot(ndata1(p2 >= 0.5, 1), ndata1(p2 >= 0.5, 2), 'g.'); hold on; axis equal
plot(data1(p1 >= 0.5, 1), data1(p1 >= 0.5, 2), 'b.');
plot(data3(p3 >= 0.5, 1), data3(p3 >= 0.5, 2), 'b.');
title('mse shit data'); grid on
hold off;


% st
cnt1 = [1321; 1299];
cnt = [0; 1321; 2620];
mdata1 = data2;

i = 1;
fd = ed1(1:count, :) - st2;
dx = fd(i, 1);
dy = fd(i, 2);

pnts = floor(cnt1(i) / 2);
ddx = linspace(dx, 0, pnts)';
ddy = linspace(dy, 0, pnts)';
mdata1((1:pnts) + cnt(i), 1) = mdata1((1:pnts) + cnt(i), 1) + ddx;
mdata1((1:pnts) + cnt(i), 2) = mdata1((1:pnts) + cnt(i), 2) + ddy;

i = 2;
fd = ed1(1:count, :) - st2;
dx = fd(i, 1);
dy = fd(i, 2);

pnts = floor(cnt1(i) / 2);
ddx = linspace(dx, 0, pnts)';
ddy = linspace(dy, 0, pnts)';
mdata1((1:pnts) + cnt(i), 1) = mdata1((1:pnts) + cnt(i), 1) + ddx;
mdata1((1:pnts) + cnt(i), 2) = mdata1((1:pnts) + cnt(i), 2) + ddy;

% ed
cnt1 = [873; 940];
cnt = [0; 873; 1813];

mdata3 = data3;
i = 1;
bd = ed2 - st3(1:count, :);
dx = bd(i, 1);
dy = bd(i, 2);

pnts = floor(cnt1(i) / 2);
ddx = linspace(dx, 0, pnts)';
ddy = linspace(dy, 0, pnts)';
index = (1:pnts) + cnt(i);
mdata3(index, 1) = mdata3(index, 1) + ddx;
mdata3(index, 2) = mdata3(index, 2) + ddy;

i = 2;
bd = ed2 - st3(1:count, :);
dx = bd(i, 1);
dy = bd(i, 2);

pnts = floor(cnt1(i) / 2);
ddx = linspace(dx, 0, pnts)';
ddy = linspace(dy, 0, pnts)';
index = (1:pnts) + cnt(i);
mdata3(index, 1) = mdata3(index, 1) + ddx;
mdata3(index, 2) = mdata3(index, 2) + ddy;


figure(101)
subplot(2, 2, 3)
plot(mdata1(p2 >= 0.5, 1), mdata1(p2 >= 0.5, 2), 'g.'); hold on; axis equal
plot(data1(p1 >= 0.5, 1), data1(p1 >= 0.5, 2), 'b.');
plot(mdata3(p3 >= 0.5, 1), mdata3(p3 >= 0.5, 2), 'b.');
title('stretch data'); grid on
hold off;




st2 = [ndata1(1, 1:2);    ndata1(1322, 1:2)];
ed2 = [ndata1(1321, 1:2); ndata1(end, 1:2)];

fd = ed1(1:count, :) - st2;
bd = st3(1:count, :) - ed2;
cnt1 = [1321; 1299];
cnt = [0; 1321; 2620];
mdata1 = ndata1;
for i = 1:count
    dx = fd(i, 1);
    dy = fd(i, 2);
    
    pnts = floor(cnt1(i) / 2);
    ddx = linspace(dx, 0, pnts)';
    ddy = linspace(dy, 0, pnts)';
    mdata1((1:pnts) + cnt(i), 1) = mdata1((1:pnts) + cnt(i), 1) + ddx;
    mdata1((1:pnts) + cnt(i), 2) = mdata1((1:pnts) + cnt(i), 2) + ddy;
    
    dx = bd(i, 1);
    dy = bd(i, 2);
    
    pnts = floor(cnt1(i) / 2);
    ddx = linspace(0, dx, pnts)';
    ddy = linspace(0, dy, pnts)';
    index = (cnt(i+1) - pnts + 1):cnt(i+1); 
    mdata1(index, 1) = mdata1(index, 1) + ddx;
    mdata1(index, 2) = mdata1(index, 2) + ddy;
end

figure(101)
subplot(2, 2, 4)
plot(mdata1(p2 >= 0.5, 1), mdata1(p2 >= 0.5, 2), 'g.'); hold on; axis equal
plot(data1(p1 >= 0.5, 1), data1(p1 >= 0.5, 2), 'b.');
plot(data3(p3 >= 0.5, 1), data3(p3 >= 0.5, 2), 'b.');
title('mse shit + stretch data'); grid on
hold off;