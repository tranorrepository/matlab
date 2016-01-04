% TEST_3.m
% used to validate feature extracted from proposed mechanisim
%


[segCfg, segCfgList] = readSegCfgFile('C:/Projects/source/newco_demo/Demo/Test/lineTypeSVM/lineTypeSVM/config/US_Detroit_manualSeg.txt');
feature = load('C:/Users/Ming.Chen/Desktop/results/09_29_0/ford/feature.txt');
labels = load('C:/Users/Ming.Chen/Desktop/results/09_29_0/ford/labels_0.txt');
index = 1;

% modify these two items to run different datasets
seg_num = 26;
lane_num = 465;

for ii = 0:1:lane_num
    for segId = 1:seg_num
        str = sprintf('C:/Users/Ming.Chen/Desktop/results/09_29_0/ford/section_data_%d_%d.txt', segId, ii);
        rot = sprintf('C:/Users/Ming.Chen/Desktop/results/09_29_0/ford/section_data_%d_%d_rotated.txt', segId, ii);
        if exist(str, 'file')
            data = load(str);
            rotd = load(rot);
            [theta, xlimit] = calcRotAngleAndRange(segCfgList, segId);
            
            if xlimit(3) < xlimit(4)
                step = 0.1;
            else
                step = -0.1;
            end
            xfulllist = (xlimit(3):step:xlimit(4))';
            
            A = round((xlimit(1) - xlimit(3)) / step) + 1;
            B = round((xlimit(2) - xlimit(3)) / step) + 1;
            n = (B - A + 1);
            
%             sp = floor(n / 100);
%             mp = mod(n, 100);
%             pp = floor((mp - 1) / 2) + A + 1;
%             id = pp:sp:100*sp + pp;
            id = round(linspace(A, B, 100));
            
            paint = 10 * (feature(index, :))';
            
            miny = min(rotd(rotd(:, 3) > 0, 2));
            maxy = max(rotd(rotd(:, 3) > 0, 2));
            
            figure(100)
            subplot(2, 1, 1)
            plot(rotd(rotd(:, 3) > 0, 1), rotd(rotd(:, 3) > 0, 2), 'r.', ...
                [xfulllist(A) xfulllist(B)], [miny, miny], 'g*');
            axis equal; grid on; hold off
            title(['Rotated Data, SegId = ' num2str(segId) ...
                ', ii = ' num2str(ii) ', label = ' num2str(labels(index))]);
            if step < 0.0
                axis([xfulllist(end) xfulllist(1) miny-10 maxy+10]);
            else
                axis([xfulllist(1) xfulllist(end) miny-10 maxy+10]);
            end
            
            subplot(2, 1, 2)
            plot(data(:, 1), 10 * data(:, 3), 'r.', ...
                xfulllist(id), paint, 'c*', ...
                [xfulllist(A) xfulllist(B)], [-5, -5], 'g*');
            axis equal; grid on; hold off;
            title(['SegId = ' num2str(segId) ', ii = ' num2str(ii) ...
                ', label = ' num2str(labels(index))]);
            if step < 0.0
                axis([xfulllist(end) xfulllist(1) -5 15]);
            else
                axis([xfulllist(1) xfulllist(end) -5 15]);
            end
            
            index = index + 1;
            pause(0.5);
        end
    end
end
