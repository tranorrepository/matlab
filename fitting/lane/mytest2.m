% roadDBDemo
%
% demo section merge process
%
close all;
clc
format long

% load data
load('roadDBDemo.mat');

if size(database, 1) ~= size(refdata, 1)
    error('Invalid data set!');
end

datasection = size(database, 1);

mergedData  = cell(datasection, 1);

% call roadDBDemo to iterate each data section
for ds = 1:datasection
    
    newDataT{1} = refdata{ds, 1}(:,[2 1 5 ]);
    newDataT{2} = refdata{ds, 1}(:,[4 3 5 ]);
    
    dataBaseT{1} = database{ds, 1}(:,[2 1 5 7]);
    dataBaseT{2} = database{ds, 1}(:,[4 3 5 7]);
    dataBaseT{4} = database{ds, 1}(:,[4 3 5 7]);
    dataBaseT{3} = database{ds, 1}(:,[2 1 5 7]);
    
    [dx dy MC] = dataMatchAlign(dataBaseT,newDataT);
end