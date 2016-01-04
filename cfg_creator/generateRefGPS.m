function cfgpnts = generateRefGPS(filename)

format long

cfggps = load(filename);
COEFF_DD2METER = 111320.0;
ref.x = -122.05374589;
ref.y = 37.39630022;

numOfPnts = size(cfggps, 1);
cfgpnts = zeros(numOfPnts, 2);
for i = 1:numOfPnts
    diff_x = cfggps(i, 1) - ref.x;
    diff_y = cfggps(i, 2) - ref.y;
    lat = ref.y * pi / 180;
    
    cfgpnts(i, 2) = diff_y * COEFF_DD2METER;
    cfgpnts(i, 1) = diff_x * (111413 * cos(lat) - 94 * cos(3 * lat));
end

