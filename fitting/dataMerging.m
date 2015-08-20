function dblines = dataMerging(newdata1,dblines1) 
%% line merging
        y1 = newdata1{1,1}(:,2);
        b1 = dblines1{1,1}(:,2);     
        
        pn1 = newdata1{1,1}(:,3);
        pd1 = dblines1{1,1}(:,3);      
        
        y2 = newdata1{1,2}(:,2);
        b2 = dblines1{1,2}(:,2);      
        
        pn2 = newdata1{1,2}(:,3);
        pd2 = dblines1{1,2}(:,3);      
        
        m1 = (y1 + b1)/2;
        m2 = (y2 + b2)/2;
        p1 = (pn1 + pd1);
        p2 = (pn2 + pd2);      
        
        xlist = newdata1{1,1}(:,1);       
        dblines = { [xlist m1 p1] ,[xlist m2 p2] };       
  
        
        figure(600)
        xlist = newdata1{1,1}(:,1);
        subplot(3,1,1);
        
        ind1 =  (p1/max(p1)) >= 0.5;
        ind2 =  (p2/max(p2)) >= 0.5;
        
        plot(xlist(ind1),m1(ind1),'r.',xlist(ind2),m2(ind2),'b.');
           
        subplot(3,1,2);
        plot(xlist,p1,'-r.');
        grid on;
         subplot(3,1,3);
        plot(xlist,p2,'-b.');
        %axis equal;
        grid on;
       % title(['Lane number =' num2str(matchedLane) ', SecID = ' num2str(segID)]);
end