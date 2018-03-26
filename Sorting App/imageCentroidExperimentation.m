pathName = 'H:\MarchDay1\'; % 'H:\FebDay1\';
DIR = dir(pathName);
DIR = DIR(3:end);
featureMatrix = [];
targetMatrix = [];
for loop = 2:2 %length(DIR)
    fileName = DIR(loop).name
    leafDisk = imread([pathName,fileName],'tif');
    
    [BW,~] = createMaskToBinarizeWholeImage2(leafDisk);
    SE = strel('disk',100);
    BW = imclose(BW,SE);
    figure(1)
    imshow(BW,'InitialMagnification','fit');
    
    s = regionprops(BW,'centroid', 'MajorAxisLength','MinorAxisLength');
    centroids = cat(1, s.Centroid);
    xc = centroids(index,1);
    yc = centroids(index,2);
    MajorAxisLengths = cat(1,s.MajorAxisLength);
    MinorAxisLengths = cat(1,s.MinorAxisLength);
    [~,index] = max(MinorAxisLengths);
    R = (MajorAxisLengths(index)+MinorAxisLengths(index))/4;
    R = floor(R);
    xc = round(xc);
    yc = round(yc);
    hold on
    plot(xc,yc,'r*')
    theta = 0:pi/100:2*pi;
    xfit = R*cos(theta)+xc;
    yfit = R*sin(theta)+yc;
    plot(xfit,yfit,'g-');
    hold off
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
    Icrop = leafDisk(y1:y2,x1:x2,3); % blue channel only
    figure(2)
    imshow(Icrop,'InitialMagnification','fit');

end


