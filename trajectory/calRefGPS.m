function ref_gps = calRefGPS(gps_track, ref_pnt)

COEFF_DD2METER = 111320.0;


numOfPnts = size(gps_track.lon, 1);
ref_gps.x = zeros(numOfPnts, 1);
ref_gps.y = zeros(numOfPnts, 1);
for i = 1:numOfPnts
    diff_x = gps_track.lon(i) - ref_pnt.x;
    diff_y = gps_track.lat(i) - ref_pnt.y;
    lat = ref_pnt.y * pi / 180;
    
    ref_gps.y(i) = diff_y * COEFF_DD2METER;
    ref_gps.x(i) = diff_x * (111413 * cos(lat) - 94 * cos(3 * lat));
end