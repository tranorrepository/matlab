function cfgdata = generateManualCfg(cfgpnts)

p1.x = 0.0;
p1.y = 0.0;

p2.x = 0.0;
p2.y = 0.0;

p3.x = 0.0;
p3.y = 0.0;
p4.x = 0.0;
p4.y = 0.0;

DIST = 20;

numOfPnts = size(cfgpnts, 1);
cfgdata = zeros(numOfPnts, 4);

for i = 1:numOfPnts
    if i == numOfPnts
        p1.x = cfgpnts(i, 1);
        p1.y = cfgpnts(i, 2);
        p2.x = cfgpnts(1, 1);
        p2.y = cfgpnts(1, 2);
    else
        p1.x = cfgpnts(i, 1);
        p1.y = cfgpnts(i, 2);
        p2.x = cfgpnts(i+1, 1);
        p2.y = cfgpnts(i+1, 2);
    end
    
    dx = p2.x - p1.x;
    dy = p2.y - p1.y;
    
    p3.y = p1.y - 20 * dy / sqrt(dx^2 + dy^2);
    p3.x = p1.x - (p1.y - p3.y) * dx / dy;
    
    p4.y = p2.y + 20 * dy / sqrt(dx^2 + dy^2);
    p4.x = p2.x + (p4.y - p2.y) * dx / dy;
    
    cfgdata(i, 1:2) = [p1.x p1.y];
    cfgdata(i, 3:4) = [p2.x p2.y];
    cfgdata(i, 5:6) = [p3.x p3.y];
    cfgdata(i, 7:8) = [p4.x p4.y];
end