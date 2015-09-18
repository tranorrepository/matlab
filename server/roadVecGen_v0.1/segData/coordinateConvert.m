function  relativeCon = coordinateConvert(sectionBoundary,refCoff)

sectionMat = sectionBoundary(:,1:2);
row = size(sectionMat,1);
relativeCon = zeros(row,2);

for i = 1:row
    relativeCon(i,1:2)=coordinateChange(sectionMat(i,1:2),refCoff);
%     text(relativeCon(i,1),relativeCon(i,2), num2str(i));
end
% figure(1)
% hold on;
% plot(relativeCon(:,1),relativeCon(:,2),'r*');
end

function relativeCon=coordinateChange(GPSMat,refCoff)
dif_x = GPSMat(1,1) - refCoff(1,1);%longtitude
dif_y = GPSMat(1,2) - refCoff(1,2);%latitude
latitude = refCoff(1,2)*3.14159265359/180;

relativeCon(1,1) = dif_x*(111413*cos(latitude) - 94*cos(3*latitude));%longtitude
relativeCon(1,2) = dif_y * 111320.0; %latitude
end
