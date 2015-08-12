load ('Frankfurt_0_ex.mat');
%load ('Frankfurt_1_ex.mat');
%load ('Frankfurt_2_ex.mat');

for ii = 1: 20
   %% minimal distance = 10 GPS line
    minDist = 10;
    plot_on = 1;
   [leftV, rightV] = laneNumberDetection(fullSections{ii,2},minDist,plot_on)    
end
