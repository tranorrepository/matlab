function subReportDatas = splitChangeLaneData(reportData,maxintervel)
data = reportData(:,1);
index2 = find(data==0);
diff2 = index2(2:end) - index2(1:end-1);
diff2 = abs(diff2);
ind = find(diff2 > maxintervel);

subReportDatas{1,2} = reportData;
subReportDatas{1,1} = [1,size(reportData,1)];
ii = 0;
if ~isempty(ind)
    aa = index2(ind);
    bb = index2(ind+1);
    size2 = length(aa);
    
    %% step 1:    
    for ii = 1: size2
        range = aa(ii)+1 : bb(ii)-1;
        subReportDatas{ii,2} = reportData(range,:);
        subReportDatas{ii,1} = [aa(ii)+1,bb(ii)-1];
    end
end
%% step 2:
if ~isempty(index2) & index2(1)> 1
    ii = ii + 1;
    range = 1+1:index2(1)-1-1;
    subReportDatas{ii,2} = reportData(range,:);
    subReportDatas{ii,1} = [1+1,index2(1)-1-1];
end

%% step 3:
if ~isempty(index2) & index2(end)< size(reportData,1)
    ii = ii + 1;
    range = index2(end)+1+1 : size(reportData,1)-1;
    subReportDatas{ii,2} = reportData(range,:);
    subReportDatas{ii,1} = [index2(end)+1+1,size(reportData,1)-1];
end
end


