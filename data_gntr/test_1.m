data = load('config.txt');

numOfSegs = size(data, 1);
numOfPnts = size(data, 2);

figure(100)
clf(100)
plot(data(:, 1:2:end-1), data(:, 2:2:end), 'b*'); hold on; axis equal;

ndata = zeros(numOfSegs, numOfPnts / 2);
ndata(:, 1:2:end-1) = 0.5 * data(:, 1:4:end-3) + 0.5 * data(:, 3:4:end-1);
ndata(:, 2:2:end)   = 0.5 * data(:, 2:4:end-2) + 0.5 * data(:, 4:4:end);

plot(ndata(:, 1:2:end-1), ndata(:, 2:2:end), 'g*'); hold off;

fid = fopen('newconfig.txt', 'wt');
if fid
    for i = 1:numOfSegs
        fprintf(fid, '%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,\n', ndata(i, :));
    end
    fclose(fid);
end
