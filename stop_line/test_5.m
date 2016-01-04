
standPoint.lat = 37.39630022;
standPoint.lon = -122.05374589;
standPoint.alt = 0.000000;

COEFF_DD2METER = 111320.0;
PI = 3.1415926536;

% Output to kml file

fid = fopen('roadVec.kml', 'w+');
if fp > 0
    % kml file header tags: <xml>, <kml>, <Document>
    fprintf(fid, '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kml>\n<Document>\n');
    
    % tags: <Style>, <StyleMap>
    fprintf(fid, '    <Style id=\"greenLineStyle\"><LineStyle><color>ff00ff00</color></LineStyle></Style>\n');
    fprintf(fid, '    <StyleMap id=\"greenLine\"><Pair><key>normal</key><styleUrl>#greenLineStyle</styleUrl></Pair></StyleMap>\n');
    
    % For each segment
    for ii = 1:segNum
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
                    
                    % tags: <Placemark>, <name>
                    fprintf(fid, '    <Placemark>\n        <name>Section-%d-Line-%d</name>\n', sectionIdx, lineIdx);
                    % tag: styleUrl
                    fprintf(fid, '        <styleUrl>#greenLine</styleUrl>\n');
                    % tag: <LineString>
                    fprintf(fid, '        <LineString>\n');
                    % tag: <coordinates>
                    fprintf(fid, '            <coordinates>\n                ');
                    
                    pntNum = length(line.x);
                    
                    for kk = 1:pntNum
                        latitude = (standPoint.lat)*PI/180;
                        
                        diff_x = line.x(kk) / (111413*cos(latitude)-94*cos(3*latitude));
                        diff_y = line.y(kk) / COEFF_DD2METER;
                        diff_z = 0.000000;
                        
                        outGpsPoint.lon = standPoint.lon + diff_x;
                        outGpsPoint.lat = standPoint.lat + diff_y;
                        outGpsPoint.alt = standPoint.alt + diff_z;
                        
                        
                        calcGpsFromRelativeLocation(standPoint, relPoint, outGpsPoint);
                        fprintf(fid, '%.7f,%.7f,%f ', outGpsPoint.lon, outGpsPoint.lat, alt);
                    end
                    
                    fprintf(fid, '\n            </coordinates>\n        </LineString>\n    </Placemark>\n');
                end
            end
        end
    end
    
    
    % End tags
    fprintf(fid, '</Document>\n</kml>');
    
    fclose(fid);
end
