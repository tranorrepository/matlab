function [yy] = dataResample(xlist,w,v)

X1 = xlist(1);
X2 = xlist(end);

ind0 = 1;
yy = zeros(1,length(xlist));
for kk = 1: length(xlist)
    %find X1 X2
    xx = xlist(kk);
    if (X1 < X2)
        x1 = v(ind0);
        y1 = w(ind0);
        while xx > x1
            ind0 = ind0 + 1;
            if ind0 < length(v)
                x1 = v(ind0);
                y1 = w(ind0);
            else
                ind0 = ind0 -1;
                x1 = v(ind0);
                y1 = w(ind0);
                break;
            end
        end
        if (ind0 >1)
            x0 = v(ind0-1);
            y0 = w(ind0-1);
        else
            x0 = v(1);
            y0 = w(1);
        end
        if (x0 == x1)
            yy(kk) = y0;
        else
            yy(kk) =  (x0-xx)/(x0-x1)*y1 + (xx-x1)/(x0-x1)*y0;
        end
    else
        x1 = v(ind0);
        y1 = w(ind0);
        while xx < x1
            ind0 = ind0 + 1;
            if ind0 < length(v)
                x1 = v(ind0);
                y1 = w(ind0);
            else
                ind0 = ind0 -1;
                x1 = v(ind0);
                y1 = w(ind0);
                break;
            end
        end
        if (ind0 >1)
            x0 = v(ind0-1);
            y0 = w(ind0-1);
        else
            x0 = v(1);
            y0 = w(1);
        end
        if (x0 == x1)
            yy(kk) = y0;
        else
            yy(kk) =  (x0-xx)/(x0-x1)*y1 + (xx-x1)/(x0-x1)*y0;
        end
    end
end
end