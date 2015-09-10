% cfgcreator

cfgpnts = generateRefGPS('cfgpntsgps.txt');
cfgdata = generateManualCfg(cfgpnts);

figure(100)
plot(cfgdata(:, 1:2:7), cfgdata(:, 2:2:8), 'g*');
axis equal

fid = fopen('ManualSeg_new.txt', 'wt');
if fid
    numOfSegs = size(cfgdata, 1);
    fprintf(fid, '%d\n', numOfSegs);
    fprintf(fid, '%s\n', 'width=20,overlap=50,minLength=120,maxLength=240,stepSize=50,paintV=0.5');
    for i = 1:numOfSegs
        if any(i == [11, 20])
            fprintf(fid, '%d,%d\n', i, 1);
        elseif any(i == [1, 9, 21])
            fprintf(fid, '%d,%d\n', i, 2);
        else
            fprintf(fid, '%d,%d\n', i, 3);
        end
        
        fprintf(fid, '%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,\n', cfgdata(i, :));
    end
    fclose(fid);
end