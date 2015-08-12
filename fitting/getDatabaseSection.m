function [matchDatabaseSetions] = getDatabaseSection(matchSectionNum,databaseSecions)
num = matchSectionNum(1,2) - matchSectionNum(1,1);
col = size(databaseSecions{1,2},2)-1; %%databaseSecions add column to mark sectionID
matchDatabaseSetions = cell(num,2);
lines = cell(1,ceil(col/4));
for i = matchSectionNum(1,1):matchSectionNum(1,2)-1
    matchDatabaseSetions{i-matchSectionNum(1,1)+1,1} = i;
    for j = 1:size(lines,2)
    lines{1,j} = databaseSecions{i,2}(:,4*j-3:4*j); %% there is a problem!!!!!
    end
    matchDatabaseSetions{i-matchSectionNum(1,1)+1,2} = lines;
end
end