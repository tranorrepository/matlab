data1 = load('fgroup_8.txt');
data2 = load('fgroup_9.txt');
data3 = load('fgroup_10.txt');

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

st1 = [data1(1, 1:2);   data1(772, 1:2);  data1(1543, 1:2)];
ed1 = [data1(771, 1:2); data1(1542, 1:2); data1(2313, 1:2)];

st2 = [data2(1, 1:2);   data2(779, 1:2);  data2(1604, 1:2)];
ed2 = [data2(778, 1:2); data2(1603, 1:2); data2(end, 1:2)];

st3 = [data3(1, 1:2);     data3(2197, 1:2); data3(4400, 1:2)];
ed3 = [data3(2196, 1:2);  data3(4399, 1:2); data3(end, 1:2)];

count = 3;

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

fd = ed1(1:count, :) - st2;
bd = st3(1:count, :) - ed2;
cnt1 = [778; 825; 875];
cnt = [0; 778; 1603; 2478];
mdata1 = data2;
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
subplot(2, 2, 3)
plot(mdata1(p2 >= 0.5, 1), mdata1(p2 >= 0.5, 2), 'g.'); hold on; axis equal
plot(data1(p1 >= 0.5, 1), data1(p1 >= 0.5, 2), 'b.');
plot(data3(p3 >= 0.5, 1), data3(p3 >= 0.5, 2), 'b.');
title('stretch data'); grid on
hold off;


st2 = [ndata1(1, 1:2);   ndata1(779, 1:2);  ndata1(1604, 1:2)];
ed2 = [ndata1(778, 1:2); ndata1(1603, 1:2); ndata1(end, 1:2)];

fd = ed1(1:count, :) - st2;
bd = st3(1:count, :) - ed2;
cnt1 = [778; 825; 875];
cnt = [0; 778; 1603; 2478];
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