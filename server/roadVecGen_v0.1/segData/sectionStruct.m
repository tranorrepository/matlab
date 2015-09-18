function stSection = sectionStruct(num,SectionPointsAfterOverlap)
stSection = cell(num,4);
%line = cell(row,4);
for i = 1:num
    stSection{i,1} = SectionPointsAfterOverlap(i,9);
    stSection{i,2} = SectionPointsAfterOverlap(i,1:8);
    %lane num and line attribute
    switch i
        case {1,3,4,7,8,14,16,17,19,21,22,23}
            lanenum = 2;
            lanesIdx = cell(1,lanenum);
            lane1 = [1,0];
            lane2 = [0,1];
            lanesIdx{1,1} = lane1;
            lanesIdx{1,2} = lane2;
        case {9,20,24}
            lanenum = 3;
            lanesIdx = cell(1,lanenum);
            lane1 = [1,1];  
            lane2 = [1,0]; 
            lane3 = [0,1]; 
            lanesIdx{1,1} = lane1;
            lanesIdx{1,2} = lane2;
            lanesIdx{1,3} = lane3;     
        case{11,12}
            lanenum = 2;
            lanesIdx = cell(1,lanenum);
            lane1 = [1,1];  
            lane2 = [1,1]; 
            lanesIdx{1,1} = lane1;
            lanesIdx{1,2} = lane2;  
          case{10,13}
            lanenum = 1;
            lanesIdx = cell(1,lanenum);
            lane1 = [1,1];  
            lanesIdx{1,1} = lane1;        
        otherwise
            lanenum = 3;
            lanesIdx = cell(1,lanenum);
            lane1 = [1,0];
            lane2 = [0,0];
            lane3 = [0,1];
            lanesIdx{1,1} = lane1;
            lanesIdx{1,2} = lane2;
            lanesIdx{1,3} = lane3;        
    end
    lanesIdx = [];
    lanesIdx{1, 1} = [1, 0];
    lanesIdx{1, 2} = [0, 1];
    stSection{i,3} = lanesIdx; 
    stSection{i,4} = 2; % lanenum;
end
end