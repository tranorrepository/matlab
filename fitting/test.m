% TEST.M
%
%
%
load('common.mat');
% load('newdata0.mat');

database = cell(1, 2);

% data base is empty
if isempty(database{1, 2})
    % number of segment
    numOfSeg = size(newdata, 1);
    database = cell(numOfSeg, 2);
    
    for ns = 1:numOfSeg
        % data fitting and remapping
        % curve fitting for new data and add to database;
        
        newLines = newdata{ns, 2};
        newLinesAfterFit = lineFitting(newLines);
        
        database{ns, 1} = newdata{ns, 1};
        database{ns, 2} = newLinesAfterFit;
        
        ol1 = newdata{ns, 2}{1, 1};
        ol2 = newdata{ns, 2}{1, 2};
        
        plot(ol1(ol1(:, 3) == 1, X), ol1(ol1(:, 3) == 1, Y), 'k.', 'MarkerSize', 1); hold on;
        plot(ol2(ol2(:, 3) == 1, X), ol2(ol2(:, 3) == 1, Y), 'k.', 'MarkerSize', 1); hold on;
        axis equal
        
        nl1 = database{ns, 2}{1, 1};
        nl2 = database{ns, 2}{1, 2};
        
        plot(nl1(nl1(:, 3) == 1, X), nl1(nl1(:, 3) == 1, Y), 'r.', 'MarkerSize', 1); hold on;
        plot(nl2(nl2(:, 3) == 1, X), nl2(nl2(:, 3) == 1, Y), 'r.', 'MarkerSize', 1); hold on;
        
        
    end
end

% load('newdata1.mat');
% 
% segconfig = database;
% landmark = database;
% 
% [database, nbody, nlm] = DatabaseUpdate(segconfig, database, newdata, landmark);
%
% 
% load('test_1.mat');
% 
% for i = 1:5
% [database, nbody, nlm] = DatabaseUpdate(segconfig, database, newdata, landmark);
% end
% 
% for ds = 1:7
%     ol1 = newdata{ds, 2}{1, 1};
%     ol2 = newdata{ds, 2}{1, 2};
%     
%     plot(ol1(ol1(:, 3) == 1, 1), ol1(ol1(:, 3) == 1, 2), 'ko', 'MarkerSize', 3); hold on;
%     plot(ol2(ol2(:, 3) == 1, 1), ol2(ol2(:, 3) == 1, 2), 'ko', 'MarkerSize', 3); hold on;
%     
%     axis equal
%     
%     nl1 = database{ds, 2}{1, 1};
%     nl2 = database{ds, 2}{1, 2};
%     
%     plot(nl1(:, 1), nl1(:, 2), 'c-', 'MarkerSize', 1); hold on;
%     plot(nl2(:, 1), nl2(:, 2), 'c-', 'MarkerSize', 1); hold on;
%     
%     plot(nl1(nl1(:, 3) >= 0.5, 1), nl1(nl1(:, 3) >= 0.5, 2), 'ro', 'MarkerSize', 3); hold on;
%     plot(nl2(nl2(:, 3) >= 0.5, 1), nl2(nl2(:, 3) >= 0.5, 2), 'ro', 'MarkerSize', 3); hold on;
% end

