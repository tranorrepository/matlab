% TEST_3.m
% read GPS file and save to KML format

clear variables; clc;

% folder_str = ['20151111143352';
% '20151111143852';
% '20151111144353';
% '20151111144853';
% '20151111145354';
% '20151111145854';
% '20151111150340';
% '20151111150841';
% '20151111151343';
% '20151111151654';
% '20151111152155';
% '20151111152656';
% '20151111152810';
% '20151111153311';
% '20151112152019';
% '20151112152520';
% '20151112153021';
% '20151112153521'];
% dir_str = 'C:/Projects/datavideo/samsung_GT-I8190_356507052235334';

% folder_str = ['20151119030112';
%     '20151119030611';
%     '20151119031111';
%     '20151119031923';
%     '20151119032422';
%     '20151119032922';
%     '20151119033422';
%     '20151119033922';
%     '20151119034406';
%     '20151119034905';
%     '20151119035405';
%     '20151119035905';
%     '20151119040405';
%     '20151119040905';
%     '20151119041405';
%     '20151119041905';
%     '20151119042405'];
% dir_str = 'C:/Projects/datavideo/iPhone_6S_20151119';

% folder_str = ['20151123212717';
% '20151123213218';
% '20151123213719';
% '20151125144031';
% '20151125144532';
% '20151125145033';
% '20151125145534';
% '20151125150034';
% '20151125150535';
% '20151125151035';
% '20151125151536';
% '20151125152037'];
% 
% dir_str = 'C:/Projects/datavideo/Acer_E39_353014064289964';

folder_str = ['20151206175428';
    '20151206181153'];

dir_str = 'C:/Projects/datavideo/iPhone_7C24DF5B-E31D-4127-A5B2-12791D9EB10F';

files_num = size(folder_str, 1);

for ii = 1:files_num
    filename_str = sprintf('%s/%s/gps_%s', dir_str, folder_str(ii, :), folder_str(ii, :));
    if exist(filename_str, 'file')
        frid = fopen(filename_str, 'r');
        if frid < 0
            continue;
        end
        
        gps_track = textscan(frid, '%*s %*s %f64 %f64 %f64', 'Delimiter', ',');
        gps_data.lon = gps_track{1};
        gps_data.lat = gps_track{2};
        gps_data.alt = gps_track{3};
        
        wfilename_str = sprintf('%s/cam_%s.kml', dir_str, folder_str(ii, :));
        fwid = fopen(wfilename_str, 'w+');
        if fwid > 0
            fprintf(fwid, '%s\n', '<?xml version = "1.0" encoding = "UTF-8"?><kml xmlns="http://earth.google.com/kml/2.2"><Placemark><LineString><coordinates>');
            
            % coordinate
            num_of_pnts = size(gps_data.lon, 1);
            for jj = 1:num_of_pnts
                fprintf(fwid, '%.15f,%.15f,%.6f\n', gps_data.lat(jj), ...
                    gps_data.lon(jj), gps_data.alt(jj));
            end
            
            fprintf(fwid, '%s\n', '</coordinates></LineString><Style><LineStyle><color>#ffff00ff</color><width>5</width></LineStyle></Style></Placemark></kml>');
            fclose(fwid);
        end
        
        fclose(frid);
    end
end