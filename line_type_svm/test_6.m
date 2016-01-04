
COEFF_DD2METER = 111320.0;

% stdpnt.x = 37.39630022;
% stdpnt.y = -122.05374589;
% 
% relpnt.y = -72.973304904761903;
% relpnt.x = -33.095941047619043;
% 
% latitude = stdpnt.y * pi / 180;
% diff_x = relpnt.x / (111413 * cos(latitude) - 94 * cos(3 * latitude));
% diff_y = relpnt.y / COEFF_DD2METER;
% 
% outpnt.x = stdpnt.x + diff_x;
% outpnt.y = stdpnt.y + diff_y;
% 
% outpnt.x, outpnt.y
% 

ref.x = 37.39630022;
ref.y = -122.05374589;

cfggps = [37.39605277777778, -122.0546285417698];
numOfPnts = size(cfggps, 1);
cfgpnts = zeros(numOfPnts, 2);
for i = 1:numOfPnts
    diff_x = cfggps(i, 1) - ref.x;
    diff_y = cfggps(i, 2) - ref.y;
    lat = ref.y * pi / 180;
    
    cfgpnts(i, 2) = diff_y * COEFF_DD2METER;
    cfgpnts(i, 1) = diff_x * (111413 * cos(lat) - 94 * cos(3 * lat));
end

cfgpnts