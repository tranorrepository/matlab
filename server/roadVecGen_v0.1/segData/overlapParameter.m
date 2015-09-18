function [cosAlpha sinAlpha] = overlapParameter(current1x,current1y,current2x,current2y)
        rou = sqrt((current2y - current1y )^2 + (current2x - current1x)^2 );
        cosAlpha = ( current2x- current1x)/rou;
        sinAlpha = (current2y - current1y)/rou;
end