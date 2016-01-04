clear variables; clc;
% all_data = load('C:/Users/Ming.Chen/Desktop/results/09_29_0/airport2/feature.txt');
% all_labels = load('C:/Users/Ming.Chen/Desktop/results/09_29_0/airport2/labels.txt');

% all_data = load('C:/Users/Ming.Chen/Desktop/results/10_05_0/feature.txt');
% all_labels = load('C:/Users/Ming.Chen/Desktop/results/10_05_0/labels.txt');

all_data = load('feature_training.txt');
all_labels = load('labels_training.txt');

fitems = size(all_data, 1);
litems = size(all_labels, 1);

if fitems ~= litems
    error('data items and labels are not equal!');
end

index = (1:fitems)';

ITERATE_TIMES = 200;

rate = zeros(ITERATE_TIMES, 1);
ind = 1;

for ii = 1:ITERATE_TIMES
    % 10% test data
    lindex = randi([1 fitems], floor(0.1 * fitems) + 1, 1);
    tindex = setxor(index, lindex);
    
    traindata = all_data(tindex, :);
    trainlabel = all_labels(tindex, :);
    
    testdata = all_data(lindex, :);
    testlabel = all_labels(lindex, :);
    
    option = optimset('MaxIter', 30000); % 设置迭代次数为30000
    svm_struct = svmtrain(traindata, trainlabel, ...
        'kernel_function', 'quadratic', ...
        'method', 'QP', 'option', option);
    predlabel = svmclassify(svm_struct, testdata);

%     svm_model = fitcsvm(traindata, trainlabel, 'KernelFunction', 'gaussian');
%     predlabel = predict(svm_model, testdata);

%     [predlabel, err] = classify(testdata, traindata, trainlabel, 'quadratic');
    
    matched = sum(testlabel == predlabel);
    rate(ind) = matched / size(testlabel, 1);
    fprintf('\n ii = %d\n', ii);
    fprintf('train items: %d, test items: %d\n', length(trainlabel), length(testlabel));
    fprintf('matched count: %d of %d\n', matched, length(testlabel));
    fprintf('matched rate: %f\n', rate(ind));
    
    ind = ind + 1;
    pause(0.1)
end

fprintf('\n\n');
fprintf('mean matched rate of 100 times: %f\n', mean(rate));
fprintf('min and max matched rate: %f, %f\n', min(rate), max(rate));
fprintf('one hundred matched rate times: %d\n', sum(rate == 1.0));