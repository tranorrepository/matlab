close all; clear variables;

addpath('.\data_sec11_1');

clf(figure(101));

FILE_NUM = 9500;
DIST = 5.3 * 5.3;

DEGREE = 4;

% minx = 514.95925484856411;
% maxx = 415.95925484856411;

xy = [1845.0910308706275,507.26129964262299,1845.4852421596602,448.08369062826841,1844.9578039460432,527.26085590236448,1845.6184690842445,428.08413436852692];
x = xy(1:2:end);
y = xy(2:2:end);
x0 = (x(3));
x1 = (x(4));

y0 = (y(3));
y1 = (y(4));

theta = atan2((y0-y1),(x0-x1));

Xrange = real((x+y*1i)*exp(-theta*j));

if Xrange(3) < Xrange(4)
    step = 0.1;    
else
    step = -0.1;    
end
xlist = Xrange(3):step:Xrange(4);

for ii = 5 % 0:FILE_NUM
    formatSpec = 'fg_%d_sec_11_group_0_lane_0.txt';
    str = sprintf(formatSpec, ii);
    if exist(str, 'file')
        fileID = fopen(str, 'r');
        formatSpec = '%f, %f, %f';
        A = fscanf(fileID, formatSpec);
        fclose(fileID);
        
        m = length(A);
        A = reshape(A, 3, m/3)';
        n = size(A, 1);
        nl1 = A(1:n/2, :);
        nl2 = A(n/2 + 1:n, :);
        
        subplot(2, 2, 1)
        plot(nl1(nl1(:, 3) > 0, 1), nl1(nl1(:, 3) > 0, 2), 'b.');
        hold on; grid on; axis equal;
        plot(nl2(nl2(:, 3) > 0, 1), nl2(nl2(:, 3) > 0, 2), 'r.');
        title('Original Data');

        ind2 = find(nl2(:, 3) > 0);
        
        % rotation
        linein.x = nl2(:, 1);
        linein.y = nl2(:, 2);
        rotout = rotline(linein, -theta);
        
        subplot(2, 2, 2)
        plot(rotout.x, rotout.y, 'g.');
        axis equal; grid on; hold on;
        
        % polyfit
        polyout.x = xlist';
        [pp, mu, su] = polyfit(rotout.x, rotout.y, DEGREE);
        [polyout.y, ~] = polyval(pp, polyout.x, mu, su);
        
        plot(polyout.x, polyout.y, 'm.');
        hold off; title('Rotated + Polyfitted');
        
        % make another line
        splout.x = xlist';
        [splout.y, ~] = polyval(pp, splout.x, mu, su);
        
        numPnts = length(splout.x);
        out.x = zeros(numPnts, 1);
        out.y = zeros(numPnts, 1);
        for jj = 1:numPnts
            index = jj+1;
            if jj == numPnts
                index = jj;
            end
            dx = splout.x(index) - splout.x(index-1);
            dy = splout.y(index) - splout.y(index-1);
            tmp = tan(atan2(dy, dx) + 0.5 * pi);
            if tmp > 0
                flag = -1;
            else
                flag = 1;
            end
            out.x(jj) = flag * sqrt(DIST / (1 + tmp^2)) + splout.x(jj);
            out.y(jj) = tmp * (out.x(jj) - splout.x(jj)) + splout.y(jj);
        end
        
        subplot(2, 2, 3)
        plot(polyout.x, polyout.y, 'm.');
        hold on; axis equal; grid on; title('Resampled + Polyfitted');
        plot(out.x, out.y, 'c.');
        
        % polyfit for resampled data
        
%         [ppr, mur, sur] = polyfit(out.x, out.y, DEGREE);
%         [out.y, ~] = polyval(ppr, out.x, mur, sur);
%          
%         plot(out.x, out.y, 'k'); hold off;
        
        % sample all data with 0.1 space
%         nnl2.x = (minx:-0.1:maxx)';
%         [nnl2.y, ~] = polyval(pp, nnl2.x, mu, su);

        nnl2 = rotline(polyout, theta);
        nnl1 = rotline(out, theta);
        
        subplot(2, 2, 1)
        plot(nnl1.x, nnl1.y, 'g.');
        hold on; axis equal; grid on;
        plot(nnl2.x, nnl2.y, 'm.');
        hold off; title('Constructed');
        
    end
    
    nndata(:, 1:2) = [out.x, out.y];
    nndata(:, 3) = 1;
    nndata(:, 4:5) = [polyout.x, polyout.y];
    nndata(:, 6) = 1;
    
    fid = fopen('section11.bin', 'w+');
    if fid
        for kk = 1:size(nndata, 1)
            nbytes = fprintf(fid, '%.15f, %.15f, %.15f, %.15f, %.15f, %.15f\n', nndata(kk, :));
        end
        
        fclose(fid);
    end
end