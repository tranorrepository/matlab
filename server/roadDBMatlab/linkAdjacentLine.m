function [lineLink] = linkAdjacentLine(Kapa)
% LINKADJACENTLINE
%   Link the adjjacent lines ;
%   INPUT :
%   Kapa   -  ridge image
%
%   OUTPUT :
%   lineLink   -  image ,the closed lines is linked                               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Feiyang Luo, 2015 Sept 17. created.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[h,w] = size(Kapa);
L = bwlabel(Kapa);
stats = regionprops(L,'Centroid','PixelList','ConvexHull');
numStats = size(stats,1);
updown.up = zeros(1,2);
updown.down = zeros(1,2);
for i = 1:numStats
    pixelXY = stats(i).PixelList;
    x = pixelXY(:,1);
    y = pixelXY(:,2);
    ma = find(y == max(y));
    mi = find(y == min(y));
    updown(i).up = pixelXY(mi(1),:);  %% up Piont;
    updown(i).down = pixelXY(ma(1),:);  %% down point;    
end
numUpDown = size(updown,2);

for i =1:numUpDown
    for j = 1:numUpDown
        dstx = abs(stats(i).Centroid(2) - stats(j).Centroid(2));
        dsty = updown(i).up(1,2) - updown(j).down(1,2);
%         dstx = abs(updown(j).up(1) - updown(i).down(1));
        if dsty>0 && dsty<50 && dstx<20
            p1 = updown(i).up;
            p2 = updown(j).down;
            Kapa = insertShape(Kapa,'Line',[p1(1,1),p1(1,2),p2(1,1),p2(1,2)],'LineWidth',1,'Color','red');
        end
    end
end

lineLink = Kapa;

end


