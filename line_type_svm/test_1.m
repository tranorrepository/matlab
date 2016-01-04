all_data = load('C:\Users\Ming.Chen\Desktop\results\09_28_0\airport2\feature.txt');
all_labels = load('C:\Users\Ming.Chen\Desktop\results\09_28_0\airport2\labels.txt');

fitems = size(all_data, 1);
litems = size(all_labels, 1);

if fitems ~= litems
    error('data items and labels are not equal!');
end

for ii = 1:100
    index = randi([1 floor(fitems / 2)], 2, 1);
    [minInd, ~] = min(index);
    [maxInd, ~] = max(index);
    
    [ii, minInd, maxInd]
    
    traindata = zeros(fitems - maxInd + minInd - 1, size(all_data, 2));
    trainlabel = zeros(fitems - maxInd + minInd - 1, 1);
    
    traindata(1:minInd-1, :) = all_data(1:minInd-1, :);
    traindata(minInd:end, :) = all_data(maxInd+1:end, :);
    
    trainlabel(1:minInd-1, :) = all_labels(1:minInd-1, :);
    trainlabel(minInd:end, :) = all_labels(maxInd+1:end, :);
    
    
    testdata = all_data(minInd:maxInd, :);
    testlabel = all_labels(minInd:maxInd, :);
    
    svm_struct = svmtrain(traindata, trainlabel);
    predlabel = svmclassify(svm_struct, testdata);
    
    matched = sum(testlabel == predlabel);
    matchedRate = matched / size(testlabel, 1);
    fprintf('matched count: %d of %d\n', matched, maxInd - minInd + 1);
    fprintf('matched rate: %f\n', matchedRate);
    
    pause(1)
end