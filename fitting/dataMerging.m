function dblines = dataMerging(newdata1,dblines1);  
%% line merging
        y1 = newdata1{1,1}(:,2);
        b1 = dblines1{1,1}(:,2);
        
        y2 = newdata1{1,2}(:,2);
        b2 = dblines1{1,2}(:,2);
        
        m1 = (y1 + b1)/2;
        m2 = (y2 + b2)/2;
        
        xx = newdata1{1,1}(:,1);
           
       
        dblines = { [xx m1 ones(size(m1))] ,[xx m2 ones(size(m2))] };
end