% load('common.mat');
% 
% load('database0.mat');
% bdatabase = database;

numOfSeg = size(bdatabase, 1);

color = cell(1, 3);
color{1} = 'bo';
color{2} = 'go';
color{3} = 'ro';

figure(500)
hold off
for ss = 1:numOfSeg
    if ~isempty(bdatabase{ss, 2})
        for iii = 1:size(bdatabase{ss, 2}, 2)
            if ~isempty(bdatabase{ss, 2}{1, iii})
                ol = bdatabase{ss, 2}{1, iii};
                if ~isempty(ol)
                    plot(ol{1}(ol{1}(:, PAINT_IND) == 1, X), ...
                        ol{1}(ol{1}(:, PAINT_IND) == 1, Y), ...
                        color{iii}, 'MarkerSize', 3); hold on;
                    plot(ol{2}(ol{2}(:, PAINT_IND) == 1, X), ...
                        ol{2}(ol{2}(:, PAINT_IND) == 1, Y), ...
                        color{iii}, 'MarkerSize', 3); hold on;
                    
                    
                    plot(ol{1}(ol{1}(:, PAINT_IND) == 0, X), ...
                        ol{1}(ol{1}(:, PAINT_IND) == 0, Y), ...
                        'k.', 'MarkerSize', 1); hold on;
                    plot(ol{2}(ol{2}(:, PAINT_IND) == 0, X), ...
                        ol{2}(ol{2}(:, PAINT_IND) == 0, Y), ...
                        'k.', 'MarkerSize', 1); hold on;
                    axis equal;
                end
%                 st = sprintf('Lane %d, section %d', iii, bdatabase{1, 1});
%                 title(st);
            end
        end
    end
end
