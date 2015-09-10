data1 = load('fgroup_1.txt');
data2 = load('fgroup_2.txt');
data21 = load('fgroup_21.txt');

p1 = data1(:, 3);
p2 = data2(:, 3);
p21 = data21(:, 3);

figure(100)
clf(100)
subplot(2, 2, 1)
plot(data1(p1 >= 0.5, 1), data1(p1 >= 0.5, 2), 'g.'); hold on; axis equal
plot(data2(p2 >= 0.5, 1), data2(p2 >= 0.5, 2), 'b.');
plot(data21(p21 >= 0.5, 1), data21(p21 >= 0.5, 2), 'b.');
title('original data'); grid on;
hold off;

st1 = [data1(1, 1:2);   data1(993, 1:2);  data1(2037, 1:2)];
ed1 = [data1(992, 1:2); data1(2036, 1:2); data1(end, 1:2)];

st2 = [data2(1, 1:2);   data2(893, 1:2);  data2(1786, 1:2)];
ed2 = [data2(893, 1:2); data2(1785, 1:2); data2(2680, 1:2)];

st21 = [data21(1, 1:2);    data21(824, 1:2); data21(1647, 1:2)];
ed21 = [data21(823, 1:2);  data21(1646, 1:2); data21(end, 1:2)];

xy = round(max(abs([st2 - ed1; ed21 - st1])));
dx = xy(1);
dy = xy(2);
dmax = 6 * (dx^2 + dy^2);
d1 = ed1;
d2 = st1;
oddx = [];
oddy = [];

for ddx = -dx:0.1:dx
    for ddy = -dy:0.1:dy
        d1(:, 1) = ed1(:, 1) + ddx;
        d1(:, 2) = ed1(:, 2) + ddy;
        d2(:, 1) = st1(:, 1) + ddx;
        d2(:, 2) = st1(:, 2) + ddy;
        d3 = st2 - d1;
        d4 = ed21 - d2;
        d = sum(sum(d3 .* d3)) + sum(sum(d4 .* d4));
        if d < dmax
            dmax = d;
            
            oddx = ddx;
            oddy = ddy;
        end
    end
end
out = [sqrt(dmax), oddx, oddy]

ndata1 = data1;
ndata1(:, 1) = data1(:, 1) + oddx;
ndata1(:, 2) = data1(:, 2) + oddy;
ndata1(:, 3) = data1(:, 3);

figure(100)
subplot(2, 2, 2)
plot(ndata1(p1 >= 0.5, 1), ndata1(p1 >= 0.5, 2), 'g.'); hold on; axis equal
plot(data2(p2 >= 0.5, 1), data2(p2 >= 0.5, 2), 'b.');
plot(data21(p21 >= 0.5, 1), data21(p21 >= 0.5, 2), 'b.');
title('mse shit data'); grid on
hold off;

fd = ed21 - st1;
bd = st2 - ed1;
cnt1 = [992; 1044; 1099];
cnt = [0; 992; 2036; 3135];
mdata1 = data1;
for i = 1:3
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

figure(100)
subplot(2, 2, 3)
plot(mdata1(p1 >= 0.5, 1), mdata1(p1 >= 0.5, 2), 'g.'); hold on; axis equal
plot(data2(p2 >= 0.5, 1), data2(p2 >= 0.5, 2), 'b.');
plot(data21(p21 >= 0.5, 1), data21(p21 >= 0.5, 2), 'b.');
title('mse shit data'); grid on
hold off;