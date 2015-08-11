
load('test_1.mat');

figure(4);

[ndb, nbody, nlm] = DatabaseUpdate(segconfig, database, newdata, landmark);

% load('database0810.mat');
% 
% 
% numOfDatasets = size(matchDatabaseSetions, 1);
% 
% outdatabase = matchDatabaseSetions;
% 
% figure(1);
% axis equal
% 
% for nd = 1:numOfDatasets
%     outdatabase{nd, 2} = lineFitting(matchDatabaseSetions{nd, 2});
% 
%     ol1 = matchDatabaseSetions{nd, 2}{1, 1};
%     ol2 = matchDatabaseSetions{nd, 2}{1, 2};
%     
%     plot(ol1(ol1(:, 3) == 1, 1), ol1(ol1(:, 3) == 1, 2), 'k.', 'MarkerSize', 1); hold on;
%     plot(ol2(ol2(:, 3) == 1, 1), ol2(ol2(:, 3) == 1, 2), 'k.', 'MarkerSize', 1); hold on;
%     
%     nl1 = outdatabase{nd, 2}{1, 1};
%     nl2 = outdatabase{nd, 2}{1, 2};
%     
%     plot(nl1(nl1(:, 3) == 1, 1), nl1(nl1(:, 3) == 1, 2), 'r.', 'MarkerSize', 1); hold on;
%     plot(nl2(nl2(:, 3) == 1, 1), nl2(nl2(:, 3) == 1, 2), 'r.', 'MarkerSize', 1); hold on;
% end