function lanePoints = calLanePointsRoadScan(history)

% calculate paint and line points of road scan image
% realized by luo feiyang
% input - history : road scan image
% output - lanePoints - paint and line points
%          leftPoint - isPaintLeft - rightPoint - isPaintRight
%          1 - lane, 0 - line, -1 - else
%          the length of lanePoints is same with length of road scan image

% LaneMarker Detection and recgnition
% laneMarkerDetection

% Cal rige for every block,adaptive parameters for ridgeDetection
[Kapa] = blkCalRidge(history);
Kapa = uint8(Kapa);
% imwrite(Kapa,'Kapa.png');

% Ransac processing
% [ransacImg] = ransacProcess(Kapa,300,30);
% imwrite(ransacImg,'ransacImg.png');

% Curve fittingImg
curveFittingImg = curveFitting(Kapa,6);
% imwrite(curveFittingImg,'curveFittingImg.png');

% Link the Adjacent line that is very close,
% [lane1] = linkAdjacentLine(curveFittingImg);
% imwrite(lane1,'Lane1.png');
lane1 = curveFittingImg;

% Link lines ,and eliminate line which is not Painting
if  size(lane1, 3) > 1
    lane1 = rgb2gray(lane1);
end
[Lane2] = linkPaintLine(lane1);
% imwrite(Lane2,'Lane2.png');

% Eliminat the length less than 500
[laneResult] = elimStLine(Lane2, 500);
% imwrite(laneResult,'laneResult.png');

% Save left and right Painting location
paintingImg = lane1&laneResult;
linkLineImg = xor(paintingImg,laneResult);

imwrite(paintingImg,'paintingImg.png');
imwrite(linkLineImg,'linkLineImg.png');

[paintLocation] = findPaintLoc(paintingImg);
[linkLineLocation] = findPaintLoc(linkLineImg);

% lane points data struct
% fill by liang feng
if size(paintLocation, 1) ~= size(linkLineLocation, 1)
    error('The size of paint location and line location is not same.');
end

for index = size(paintLocation, 1) : -1  : 1
    if paintLocation(index, 1) ~= -1
        % is left paint
        lanePoints{size(paintLocation, 1)-index+1}.leftPoint = [paintLocation(index, 1) paintLocation(index, 2)];
        lanePoints{size(paintLocation, 1)-index+1}.isPaintLeft = 1;
    else
        if linkLineLocation(index, 1) ~= -1
            % is left line
            lanePoints{size(paintLocation, 1)-index+1}.leftPoint = [linkLineLocation(index, 1) linkLineLocation(index, 2)];
            lanePoints{size(paintLocation, 1)-index+1}.isPaintLeft = 0;
        else
            % is not left paint or line
            lanePoints{size(paintLocation, 1)-index+1}.leftPoint = [-1 -1];
            lanePoints{size(paintLocation, 1)-index+1}.isPaintLeft = -1;
        end
    end
    
    if paintLocation(index, 3) ~= -1
        % is right paint
        lanePoints{size(paintLocation, 1)-index+1}.rightPoint = [paintLocation(index,3) paintLocation(index, 4)];
        lanePoints{size(paintLocation, 1)-index+1}.isPaintRight = 1;
    else
        if linkLineLocation(index, 3) ~= -1
            % is right line
            lanePoints{size(paintLocation, 1)-index+1}.rightPoint = [linkLineLocation(index, 3) linkLineLocation(index, 4)];
            lanePoints{size(paintLocation, 1)-index+1}.isPaintRight = 0;
        else
            % is not right paint or line
            lanePoints{size(paintLocation, 1)-index+1}.rightPoint = [-1 -1];
            lanePoints{size(paintLocation, 1)-index+1}.isPaintRight = -1;
        end
    end
end

end% function of calLanePointsRoadScan