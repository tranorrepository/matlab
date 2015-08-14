function fdatabase = generateFDatabase(database)
% GENERATEFDATABASE
%
%   INPUT:
%
%   database - 
%             {1, 2}         section info
%                 {1, M} M   lanes info
%                     [1, 2] lines info
%
%   OUTPUT:
%
%   fdatabase - 
%               {1, 2}
%                   {1, 4} lines

load('common.mat');

color = cell(1, 3);
color{1, 1} = 'b';
color{1, 2} = 'g';
color{1, 3} = 'c';

% number of database segment
numOfDB = size(database, 1);

% foreground database
fdatabase = cell(numOfDB, 2);

% iterate each database segment
for ns = 1:numOfDB
    % segment ID of database
    segID = database{ns, 1};
    fdatabase{ns, 1} = segID;
    
    % num of lanes in current segment
    numOfLanes = size(database{ns, 2}, 2);
    
    templines = cell(1, numOfLanes + 1);

    % merge lane common lines
    for nl = 1:numOfLanes
        if ~isempty(database{ns, 2}{1, nl})
            if 1 == nl
                templines(1, nl:nl+1) = database{ns, 2}{1, nl};
                templines{1, nl  } = database{ns, 2}{1, nl}{1, 1};
                templines{1, nl+1} = database{ns, 2}{1, nl}{1, 2};
            else
                if ~isempty(templines{1, nl}) && ~isempty(templines{1, nl-1})
                    line1 = templines{1, nl};
                    line2 = database{ns, 2}{1, nl}{1, 1};
                    
                    % merge lane common lane
                    % movedvec - two lines shift vector in total
                    %            [1:2, 3:4] 1:2 first line, 3:4 second line
                    [merged, movedvec] = lineMerging(line1, line2);
                    
                    for ii = 1:nl-1
                        if ~isempty(templines{1, ii})
                            templines{1, ii}(:, 1) = ...
                                templines{1, ii}(:, 1) + movedvec(1, 1);
                            templines{1, ii}(:, 2) = ...
                                templines{1, ii}(:, 2) + movedvec(1, 2);
                            break;
                        end
                    end
                    
                    templines{1, nl} = merged;
                    
                    templines{1, nl+1} = database{ns, 2}{1, nl}{1, 2};
                    templines{1, nl+1}(:, 1) = templines{1, nl+1}(:, 1) + ...
                        movedvec(1, 3);
                    templines{1, nl+1}(:, 2) = templines{1, nl+1}(:, 2) + ...
                        movedvec(1, 4);
                else
                    templines{1, nl  } = database{ns, 2}{1, nl}{1, 1};
                    templines{1, nl+1} = database{ns, 2}{1, nl}{1, 2};
                end
            end
        end
    end
    
    fdatabase{ns, 2} = templines;
 
    if PLOT_ON
        figure(100)
        % background database
        for ll = 1:numOfLanes
            if ~isempty(database{ns, 2}{1, ll})
                ol1 = database{ns, 2}{1, ll}{1, 1};
                ol2 = database{ns, 2}{1, ll}{1, 2};
                plot(ol1(ol1(:, 3) ~= INVALID_FLAG, X), ...
                    ol1(ol1(:, 3) ~= INVALID_FLAG, Y), color{ll}); hold on;
                plot(ol2(ol2(:, 3) ~= INVALID_FLAG, X), ...
                    ol2(ol2(:, 3) ~= INVALID_FLAG, Y), color{ll}); hold on;
            end
        end
        
        axis equal
        
        % foreground database
        for ll = 1:numOfLanes+1
            ol = fdatabase{ns, 2}{1, ll};
            if ~isempty(ol)
                plot(ol(ol(:, PAINT_IND) ~= INVALID_FLAG, X), ...
                    ol(ol(:, PAINT_IND) ~= INVALID_FLAG, Y), ...
                    'r', 'MarkerSize', 3); hold on;
            end
        end
        
    end
end