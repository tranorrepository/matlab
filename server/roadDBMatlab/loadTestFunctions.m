function testFunctions = loadTestFunctions()

% load function handles for test functions
% output - testFunctions : struct of test function handles

testFunctions.drawPointsRoadScan = @drawPointsRoadScan;

end% loadTestFunctions

function drawPointsRoadScan(history, roadPaintData)

% draw paint and line points on road scan image
% image saved as drawPointsRoadScan.png
% input - history : road scan image
%         roadPaintData : paint and line points

image(:, :, 1) = history;
image(:, :, 2) = history;
image(:, :, 3) = history;

for index = 1 : length(roadPaintData)
    if roadPaintData{index}.isPaintLeft == 1
        % paint points
        image(roadPaintData{index}.leftPoint(2), roadPaintData{index}.leftPoint(1), 1) = 255;
        image(roadPaintData{index}.leftPoint(2), roadPaintData{index}.leftPoint(1), 2) = 0;
        image(roadPaintData{index}.leftPoint(2), roadPaintData{index}.leftPoint(1), 3) = 0;
    elseif roadPaintData{index}.isPaintLeft == 0
        % line points
        image(roadPaintData{index}.leftPoint(2), roadPaintData{index}.leftPoint(1), 1) = 0;
        image(roadPaintData{index}.leftPoint(2), roadPaintData{index}.leftPoint(1), 2) = 0;
        image(roadPaintData{index}.leftPoint(2), roadPaintData{index}.leftPoint(1), 3) = 255;
    end
    
    if roadPaintData{index}.isPaintRight == 1
        image(roadPaintData{index}.rightPoint(2), roadPaintData{index}.rightPoint(1), 1) = 255;
        image(roadPaintData{index}.rightPoint(2), roadPaintData{index}.rightPoint(1), 2) = 0;
        image(roadPaintData{index}.rightPoint(2), roadPaintData{index}.rightPoint(1), 3) = 0;
    elseif roadPaintData{index}.isPaintRight == 0
        image(roadPaintData{index}.rightPoint(2), roadPaintData{index}.rightPoint(1), 1) = 0;
        image(roadPaintData{index}.rightPoint(2), roadPaintData{index}.rightPoint(1), 2) = 0;
        image(roadPaintData{index}.rightPoint(2), roadPaintData{index}.rightPoint(1), 3) = 255;
    end
end

imwrite(image, 'drawPointsRoadScan.png');

end% drawPointsRoadScan