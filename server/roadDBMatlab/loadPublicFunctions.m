function publicFunctions = loadPublicFunctions()

% load function handles for public functions
% output - publicFunctions : function handles for public function

publicFunctions.coordinateChange = @coordinateChange;

end% for function loadPublicFunctions

function GPS = coordinateChange(gpsData, GPSref)

% change coordinate based on reference gps
% input - gpsData : original gps
%         GPSref : reference gps
% output - GPS : ref gps of gpsData based on GPSref

GPS = [];

dif_x = gpsData(1) - GPSref(1);
dif_y = gpsData(2) - GPSref(2);
latitude = GPSref(1)*3.14159265359/180;

GPS(1) = dif_x*111320.0;  %latitude
GPS(2) = dif_y*(111413*cos(latitude)-94*cos(3*latitude));  %longitude

end% coordinateChange