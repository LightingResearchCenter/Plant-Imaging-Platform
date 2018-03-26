function [xc,yc,R,BW] = FindDiskCenter50MP_Centroid(leafDiskImage,showGraphics)
% Inputs:
%   leafDiskImage: matrix, 50 MPixel color camera image
%   showGraphics: boolean, true = show debugging figures, false = no figures
% Outputs:
%   (xc, yc): doubles, center of leaf disk (column, row) rounded to whole number
%   R: double, radius of leaf disk in pixels rounded to whole number

tic
[BW,~] = createMask(leafDiskImage);
SE = strel('disk',100);
BW = imclose(BW,SE);
toc
tic

s = regionprops(BW,'centroid', 'MajorAxisLength','MinorAxisLength');
centroids = cat(1, s.Centroid);
MajorAxisLengths = cat(1,s.MajorAxisLength);
MinorAxisLengths = cat(1,s.MinorAxisLength);
[~,index] = max(MinorAxisLengths);
xc = centroids(index,1);
yc = centroids(index,2);
R = (MajorAxisLengths(index)+MinorAxisLengths(index))/4;
R = floor(R);
xc = round(xc);
yc = round(yc);

% Crop image
[ySize,xSize,~] = size(BW);
y1 = yc-R;
if y1<1
    y1=1;
end
y2 = yc+R;
if y2>ySize
    y2=ySize;
end
x1 = xc-R;
if x1<1
    x1=1;
end
x2 = xc+R;
if x2>xSize
    x2=xSize;
end
Icrop = leafDiskImage(y1:y2,x1:x2,3); % blue channel only
figure(2)
imshow(Icrop,'InitialMagnification','fit');

if showGraphics
    figure(3)
    imshow(leafDiskImage,'InitialMagnification','fit');
    hold on
    plot(xc,yc,'r*')
    theta = 0:pi/100:2*pi;
    xfit = R*cos(theta)+xc;
    yfit = R*sin(theta)+yc;
    plot(xfit,yfit,'g-');
    hold off
end


