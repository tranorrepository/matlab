function sectionPointsAfterOverlap = caculateOverlap(originalsectionPoints,extendscaleForOverlap)
row = size(originalsectionPoints,1);
sectionPointsAfterOverlap = [];
for i = 1: row-1
    [cosAlpha sinAlpha] = overlapParameter(originalsectionPoints(i,1),originalsectionPoints(i,2),...
                                                                          originalsectionPoints(i+1,1),originalsectionPoints(i+1,2));
    overlapleftx =  originalsectionPoints(i,1) - extendscaleForOverlap * cosAlpha;
    overlaplefty =  originalsectionPoints(i,2) - extendscaleForOverlap * sinAlpha;
    overlaprightx = extendscaleForOverlap * cosAlpha + originalsectionPoints(i+1,1);
    overlaprighty = extendscaleForOverlap * sinAlpha + originalsectionPoints(i+1,2);
    sectionPointsAfterOverlap(i,:) =  [overlapleftx,overlaplefty,originalsectionPoints(i,1),originalsectionPoints(i,2),...
                                                            originalsectionPoints(i+1,1),originalsectionPoints(i+1,2),overlaprightx,overlaprighty,i];
end
end


