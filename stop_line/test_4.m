

load('fdatabase.mat');

clf(figure(707))

segNum = size(fdatabase, 2);
% for each segment
for sec = 1: segNum
    % For drawing only.
    FDB = fdatabase(sec);
    if ~isempty(FDB.lineData)
        numOfLines = size(FDB.lineData, 1);
        
        for ll = 1:numOfLines
            line = FDB.lineData{ll};
            
            if ~isempty(line)
                ind =  (line.paint / max(line.paint)) >= 0.5;
                plot(line.x(ind), line.y(ind), '.', ...
                    line.x, line.y, '-');
                hold on; axis equal; grid on
            end
        end
    end
end % end of section iteration plot


load('lm_database_0.mat');
num_of_groups_0 = size(lm_database, 2);
lm_centers_0 = zeros(num_of_groups_0, 2);
lm_start_stop_0 = zeros(2 * num_of_groups_0, 2);
for ii = 1:num_of_groups_0
    lm_centers_0(ii, 1:2) = [lm_database(ii).center.x, lm_database(ii).center.y];
    lm_start_stop_0(2 * ii - 1, 1:2) = [lm_database(ii).start.x, lm_database(ii).start.y];
    lm_start_stop_0(2 * ii, 1:2) = [lm_database(ii).stop.x, lm_database(ii).stop.y];
end

plot(lm_centers_0(:, 1), lm_centers_0(:, 2), 'g*', 'MarkerSize', 5);
for ii = 1:num_of_groups_0
    plot(lm_start_stop_0(2*ii - 1:2*ii, 1), lm_start_stop_0(2*ii - 1:2*ii, 2), 'g');
end


load('lm_database_1.mat');
num_of_groups_1 = size(lm_database, 2);
lm_centers_1 = zeros(num_of_groups_0, 2);
lm_start_stop_1 = zeros(2 * num_of_groups_0, 2);
for ii = 1:num_of_groups_0
    lm_centers_1(ii, 1:2) = [lm_database(ii).center.x, lm_database(ii).center.y];
    lm_start_stop_1(2 * ii - 1, 1:2) = [lm_database(ii).start.x, lm_database(ii).start.y];
    lm_start_stop_1(2 * ii, 1:2) = [lm_database(ii).stop.x, lm_database(ii).stop.y];
end

plot(lm_centers_1(:, 1), lm_centers_1(:, 2), 'g*', 'MarkerSize', 5);
for ii = 1:num_of_groups_1
    plot(lm_start_stop_1(2*ii - 1:2*ii, 1), lm_start_stop_1(2*ii - 1:2*ii, 2), 'g');
end

hold off; title('road data');


standPoint.lat = 37.39630022;
standPoint.lon = -122.05374589;
standPoint.alt = 0.000000;

COEFF_DD2METER = 111320.0;
PI = 3.1415926536;

% Output to kml file

fid = fopen('roadVecStopline.kml', 'w+');
if fid > 0
    % kml file header tags: <xml>, <kml>, <Document>
    fprintf(fid, '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kml>\n<Document>\n');
    
    % tags: <Style>, <StyleMap>
    fprintf(fid, '    <Style id=\"greenLineStyle\"><LineStyle><color>ff00ff00</color></LineStyle></Style>\n');
    fprintf(fid, '    <StyleMap id=\"greenLine\"><Pair><key>normal</key><styleUrl>#greenLineStyle</styleUrl></Pair></StyleMap>\n');
    
    % For each segment
    for ii = 1:8 % segNum
        FDB = fdatabase(ii);
        if ~isempty(FDB.lineData)
            numOfLines = size(FDB.lineData, 1);
            
            for ll = 1:numOfLines
                line = FDB.lineData{ll};
                
                if ~isempty(line)
                    
                    % tags: <Placemark>, <name>
                    fprintf(fid, '    <Placemark>\n        <name>Section-%d-Line-%d</name>\n', ii, ll);
                    % tag: styleUrl
                    fprintf(fid, '        <styleUrl>#greenLine</styleUrl>\n');
                    % tag: <LineString>
                    fprintf(fid, '        <LineString>\n');
                    % tag: <altitudeMode>
                    fprintf(fid, '            <altitudeMode>relativeToGround</altitudeMode>\n');
                    % tag: <coordinates>
                    fprintf(fid, '            <coordinates>\n                ');
                    
                    pntNum = length(line.x);
                    
                    for kk = 1:pntNum
                        latitude = (standPoint.lat)*PI/180;
                        
                        diff_x = line.x(kk) / (111413*cos(latitude)-94*cos(3*latitude));
                        diff_y = line.y(kk) / COEFF_DD2METER;
                        
                        if line.paint(kk) / max(line.paint) >= 0.5
                            diff_z = 0.000000;
                        else
                            diff_z = -1.500000;
                        end
                        
                        outGpsPoint.lon = standPoint.lon + diff_x;
                        outGpsPoint.lat = standPoint.lat + diff_y;
                        outGpsPoint.alt = standPoint.alt + diff_z;
                        
                        fprintf(fid, '%.7f,%.7f,%f ', outGpsPoint.lon, outGpsPoint.lat, outGpsPoint.alt);
                    end
                    
                    fprintf(fid, '\n            </coordinates>\n        </LineString>\n    </Placemark>\n');
                end
            end
        end
    end
    
    % center points and line data
    for ii = 1:num_of_groups_0
        % center point
        fprintf(fid, '    <Placemark>\n        <name>Sign-%d</name>\n        <Point>\n            <coordinates>\n                ', ii);
        
        latitude = (standPoint.lat)*PI/180;
        
        diff_x = lm_centers_0(ii, 1) / (111413*cos(latitude)-94*cos(3*latitude));
        diff_y = lm_centers_0(ii, 2) / COEFF_DD2METER;
        diff_z = 0.000000;
        
        outGpsPoint.lon = standPoint.lon + diff_x;
        outGpsPoint.lat = standPoint.lat + diff_y;
        outGpsPoint.alt = standPoint.alt + diff_z;
        
        fprintf(fid, '%.7f,%.7f,%f ', outGpsPoint.lon, outGpsPoint.lat, outGpsPoint.alt);
        fprintf(fid, '\n            </coordinates>\n        </Point>\n    </Placemark>\n');
        
        % line data
        
        % tags: <Placemark>, <name>
        fprintf(fid, '    <Placemark>\n        <name>Section-%d-Line-%d</name>\n', ii, ll);
        % tag: styleUrl
        fprintf(fid, '        <styleUrl>#greenLine</styleUrl>\n');
        % tag: <LineString>
        fprintf(fid, '        <LineString>\n');
        % tag: <coordinates>
        fprintf(fid, '            <coordinates>\n                ');
        
        x = linspace(lm_start_stop_0(2*ii - 1, 1), lm_start_stop_0(2*ii, 1), 200);
        y = linspace(lm_start_stop_0(2*ii - 1, 2), lm_start_stop_0(2*ii, 2), 200);
        for jj = 1:200
            latitude = (standPoint.lat)*PI/180;
            
            diff_x = x(jj) / (111413*cos(latitude)-94*cos(3*latitude));
            diff_y = y(jj) / COEFF_DD2METER;
            diff_z = 0.000000;
            
            outGpsPoint.lon = standPoint.lon + diff_x;
            outGpsPoint.lat = standPoint.lat + diff_y;
            outGpsPoint.alt = standPoint.alt + diff_z;
            
            fprintf(fid, '%.7f,%.7f,%f ', outGpsPoint.lon, outGpsPoint.lat, outGpsPoint.alt);
        end
        
        fprintf(fid, '\n            </coordinates>\n        </LineString>\n    </Placemark>\n');
    end
    
    for ii = 1:num_of_groups_1
        % center point
        fprintf(fid, '    <Placemark>\n        <name>Sign-%d</name>\n        <Point>\n            <coordinates>\n                ', ii);
        
        latitude = (standPoint.lat)*PI/180;
        
        diff_x = lm_centers_1(ii, 1) / (111413*cos(latitude)-94*cos(3*latitude));
        diff_y = lm_centers_1(ii, 2) / COEFF_DD2METER;
        diff_z = 0.000000;
        
        outGpsPoint.lon = standPoint.lon + diff_x;
        outGpsPoint.lat = standPoint.lat + diff_y;
        outGpsPoint.alt = standPoint.alt + diff_z;
        
        fprintf(fid, '%.7f,%.7f,%f ', outGpsPoint.lon, outGpsPoint.lat, outGpsPoint.alt);
        fprintf(fid, '\n            </coordinates>\n        </Point>\n    </Placemark>\n');
        
        % line data
        
        % tags: <Placemark>, <name>
        fprintf(fid, '    <Placemark>\n        <name>Section-%d-Line-%d</name>\n', ii, ll);
        % tag: styleUrl
        fprintf(fid, '        <styleUrl>#greenLine</styleUrl>\n');
        % tag: <LineString>
        fprintf(fid, '        <LineString>\n');
        % tag: <coordinates>
        fprintf(fid, '            <coordinates>\n                ');
        
        x = linspace(lm_start_stop_1(2*ii - 1, 1), lm_start_stop_1(2*ii, 1), 200);
        y = linspace(lm_start_stop_1(2*ii - 1, 2), lm_start_stop_1(2*ii, 2), 200);
        for jj = 1:200
            latitude = (standPoint.lat)*PI/180;
            
            diff_x = x(jj) / (111413*cos(latitude)-94*cos(3*latitude));
            diff_y = y(jj) / COEFF_DD2METER;
            diff_z = 0.000000;
            
            outGpsPoint.lon = standPoint.lon + diff_x;
            outGpsPoint.lat = standPoint.lat + diff_y;
            outGpsPoint.alt = standPoint.alt + diff_z;
            
            fprintf(fid, '%.7f,%.7f,%f ', outGpsPoint.lon, outGpsPoint.lat, outGpsPoint.alt);
        end
        
        fprintf(fid, '\n            </coordinates>\n        </LineString>\n    </Placemark>\n');
    end
    
    
    % End tags
    fprintf(fid, '</Document>\n</kml>');
    
    fclose(fid);
end
