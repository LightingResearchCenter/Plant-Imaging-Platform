% Experiment with finding leaf disk center on simulated images
%
%pathName = '\\ROOT\public\plummt\PMBot\Nikon Camera\';
%fileName = 'test2(B,Radius8,Smoothing4)_20_10-32-57.tif';
pathName = 'H:\FebDay1\';
DIR = dir(pathName);
DIR = DIR(3:end);
for loop = 1:ength(DIR)
    fileName = DIR(loop).name
%fileName = 'Feb2118_104941_(1).tiff';
%leafDisk = imread('simulatedDiskCrayon.bmp','bmp');
leafDisk = imread([pathName,fileName],'tif');
%
[BW,maskedRGBImage] = createMaskToBinarizeWholeImage2(leafDisk);
figure(1)
imshow(BW,'InitialMagnification','fit');
SE = strel('disk',10);
%BW = imerode(BW,SE);
SE = strel('disk',100);
BW = imclose(BW,SE);
figure(3)
imshow(BW,'InitialMagnification','fit');
tic
% leafDisk = BW;
%{
leafDisk = leafDisk(:,:,3); % Blue channel
% Image binarization
T = adaptthresh(leafDisk, 0.4,'Statistic','mean'); % 0.2
%leafDisk = uint8(filter2(ones(5,5)/25,leafDisk));
imshow(leafDisk,'InitialMagnification','fit');
%impixelinfo;
leafDisk = imbinarize(leafDisk); %'adaptive');%,0.50);
leafDisk = imcomplement(leafDisk);
SE = strel('square',20);
leafDisk = imdilate(leafDisk,SE);
leafDisk = imfill(leafDisk,'holes');
%leafDisk = bwperim(leafDisk);
figure(1)
imshow(leafDisk,'InitialMagnification','fit');
%}
xfov = 600; % pixels
yfov = 600; % pixels
xImageStep = 400;
yImageStep = 400;
xPos = 4100; %300; %5;
yPos = 1200; %3;
edgeCount = 0;
xPtsAll = [];
yPtsAll = [];
moveDir = -1; % -1 = left, 1 = right
hFrame = patch([xPos,xPos+xfov,xPos+xfov,xPos],[yPos,yPos,yPos+yfov,yPos+yfov],'r','FaceColor','none','EdgeColor','r');
xMoves = 0;
noEdge = 0;
while xMoves <20 && edgeCount <2
    searchDim = 'x';
    xMoves = xMoves + 1;
    I = BW(yPos:yPos+yfov-1,xPos:xPos+xfov-1);
    % I2 = leafDisk(yPos:yPos+yfov-1,xPos:xPos+xfov-1);
    %set(hFrame,'Vertices',[xPos,xPos+xfov,xPos+xfov,xPos;yPos,yPos,yPos+yfov,yPos+yfov]');
    % figure(2)
    % imshow(I2);
    [stepDir,xPts,yPts] = edgeFind(I,xPos,yPos,searchDim);
    
    % pause
    
    if ~isempty(stepDir)
        if stepDir ~= moveDir || edgeCount == 0 % Avoid getting points on same side of disk
            edgeCount = edgeCount+1;
            moveDir = stepDir;
            xPtsAll = [xPtsAll,xPts];
            yPtsAll = [yPtsAll,yPts];
            xPos1(edgeCount) = xPos;
        end
    end
    xPos = xPos + moveDir*xImageStep;
    if (xPos<1 || xPos>(8256-xfov))
        disp('No edge found');
        noEdge = 1;
        break;
    end
end
% Go to 2/3 y-axis position and look for edges
xPos = 2000;
yPos = 4000;
while xMoves <40 && edgeCount <4
    searchDim = 'x';
    xMoves = xMoves + 1;
    I = BW(yPos:yPos+yfov-1,xPos:xPos+xfov-1);
    % I2 = leafDisk(yPos:yPos+yfov-1,xPos:xPos+xfov-1);
    %set(hFrame,'Vertices',[xPos,xPos+xfov,xPos+xfov,xPos;yPos,yPos,yPos+yfov,yPos+yfov]');
    % figure(2)
    % imshow(I2);
    [stepDir,xPts,yPts] = edgeFind(I,xPos,yPos,searchDim);
    
    % pause
    
    if ~isempty(stepDir)
        if stepDir ~= moveDir || edgeCount == 0 % Avoid getting points on same side of disk
            edgeCount = edgeCount+1;
            moveDir = stepDir;
            xPtsAll = [xPtsAll,xPts];
            yPtsAll = [yPtsAll,yPts];
            xPos1(edgeCount) = xPos;
        end
    end
    xPos = xPos + moveDir*xImageStep;
    if (xPos<1 || xPos>(8256-xfov))
        disp('No edge found');
        noEdge = 1;
        break;
    end
end

if (noEdge == 0)
    [xc,yc,R,a] = circfit(xPtsAll,yPtsAll);
    theta = 0:pi/100:2*pi;
    xfit = R*cos(theta)+xc;
    yfit = R*sin(theta)+yc;
    toc
    figure(1)
    hold on
    plot(xc,yc,'ro');
    plot(xfit,yfit,'g-');
    plot(xPtsAll,yPtsAll,'bo');
    hold off
end

% Crop image
R = floor(R);
xc = round(xc);
yc = round(yc);
Icrop = leafDisk(yc-R:yc+R,xc-R:xc+R,3); % blue channel only
figure(2)
imshow(Icrop,'InitialMagnification','fit');
pause
end


