%%
function [dx dy MC] = dataMatchAlign(dataBaseT,newDataT)

laneNum = size(dataBaseT,2) - 1;

% try eacch possible lane to find the best match lane
for ii = 1: laneNum
    [dx1 dy1 MC1] = lineMatchAlign(dataBaseT{ii}(:,[1:3]),newDataT{1});
    [dx2 dy2 MC2] = lineMatchAlign(dataBaseT{ii+1}(:,[1:3]),newDataT{2});
    MC{ii} = MC1*MC2;
    dx{ii} = (dx1+dx2)/2;
    dy{ii} = (dy1+dy2)/2;
end
end

function [dx dy MC] = lineMatchAlign(dataBaseT,newDataT)
[blockNew] = dotLineBlockIndex2(newDataT);
[blockDB]  = dotLineBlockIndex2(dataBaseT);

%% new data
% get x position for each dash line
a =  newDataT(blockNew(:),1);
x1{1} = reshape(a,length(a)/2,2);

% get y position for each dash line
a =  newDataT(blockNew(:),2);
y1{1} = reshape(a,length(a)/2,2);

%% data base
% get x position for each dash line
a =  dataBaseT(blockDB(:),1);
x1{2} = reshape(a,length(a)/2,2);

% get y position for each dash line
a =  dataBaseT(blockDB(:),2);
y1{2} = reshape(a,length(a)/2,2);

% match on x axis and y axis.
[dx, MCx] = axisMatch(x1);
[dy, MCy] = axisMatch(y1);

% final Matching Coefficient on both directions.
MC = MCx*MCy;

end



function [delta MC] = axisMatch(xy)

% find x/y range: [min max]
for ii = 1:2
    minxx(ii) = min(min(xy{ii}));
    maxxx(ii) = max(max(xy{ii}));
end
minx = min(minxx);
maxx = max(maxxx);

A = -1*ones(round(maxx - minx)*10+50,2);
for ii = 1:2
    a = min(xy{ii},[],2);
    b = max(xy{ii},[],2);
    
    a = round((a-minx)*10);
    b = round((b-minx)*10);
    
    for jj = 1: length(a)
        range = 1 + (a(jj):b(jj));
        A(range,ii) = 1;
    end
end

[X lags]= xcorr(A(:,1),A(:,2));

if 1
figure(80);
plot(A),ylim([-2 2]);
figure(90);
plot(X,'-o')
end

[M ,I] = max(X);
delta = lags(I);

%% compute coefficient in x axis
n1 = norm(A(:,1));
n2 = norm(A(:,2));

MC = M/n1/n2;
end

function [dotBlkIndex] = dotLineBlockIndex2(data)
% DOTLINEBLOCKINDEX
%   dotted line information from input data
%
%   INPUT:
%
%   data - organized GPS data, 19 columns(ford) or 6 columns(Honda)
%
%   OUTPUT:
%
%   dotBlkIndex - dotted line start/stop block index of GPS data
%   dotLineIndex - the column of paint dotted line
%

% assume the data is organized as expected

dotLineIndex = 3;
% dotted and solid line start/stop index
% from which index to which the dotted/slid line starts and ends
items = size(data, 1);
dotBlkIndex = zeros(1, 2); % start, stop
blkIndex = 1;
bChanged = false;
for i = 1:items
    value = data(i, dotLineIndex);
    if (1.0 == value)
        if (false == bChanged)
            dotBlkIndex(blkIndex, 1) = i;   % start
        end
        bChanged = true;
    else
        if (true == bChanged)
            dotBlkIndex(blkIndex, 2) = i-1; % stop
            if 10 < (dotBlkIndex(blkIndex, 2) - dotBlkIndex(blkIndex, 1))
                blkIndex = blkIndex + 1;
            end
            bChanged = false;
        end
    end
end

if (true == bChanged) && (0 == dotBlkIndex(blkIndex, 2))
    dotBlkIndex(blkIndex, 2) = items;
end
end