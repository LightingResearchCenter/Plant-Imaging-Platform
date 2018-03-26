function [xc,yc,R,BW] = FindDiskCenter50MP(leafDiskImage,showGraphics)
% Inputs:
%   leafDiskImage: matrix, 50 MPixel color camera image
%   showGraphics: boolean, true = show debugging figures, false = no figures
% Outputs:
%   (xc, yc): doubles, center of leaf disk (column, row) rounded to whole number
%   R: double, radius of leaf disk in pixels rounded to whole number

tic
[BW,~] = createMaskToBinarizeWholeImage2(leafDiskImage);
SE = strel('disk',100);
BW = imclose(BW,SE);
toc
tic
[ySize,xSize] = size(BW);
xfov = 600; % pixels
yfov = 600; % pixels
xImageStep = 400;
% yImageStep = 400; % Not needed because alogrithm searches horizontally 
xPos = round(xSize/2); % 4100; % Start in middle of image
yPos = round(ySize/4); %1200; % First search row is 1/4 down from top of image
edgeCount = 0;
xPtsAll = [];
yPtsAll = [];
moveDir = -1; % -1 = left, 1 = right
xMoves = 0;
noEdge = 0;
if showGraphics
    figure(1)
    imshow(BW,'InitialMagnification','fit');
    hFrame = patch([xPos,xPos+xfov,xPos+xfov,xPos],[yPos,yPos,yPos+yfov,yPos+yfov],'r','FaceColor','none','EdgeColor','r');
end

while xMoves <40 && edgeCount <4
    searchDim = 'x';
    xMoves = xMoves + 1;
    I = BW(yPos:yPos+yfov-1,xPos:xPos+xfov-1);
    [stepDir,xPts,yPts] = edgeFind(I,xPos,yPos,searchDim);
    if showGraphics
        set(hFrame,'Vertices',[xPos,xPos+xfov,xPos+xfov,xPos;yPos,yPos,yPos+yfov,yPos+yfov]');
        I2 = leafDiskImage(yPos:yPos+yfov-1,xPos:xPos+xfov-1);
        figure(2)
        imshow(I2);
    end
    if ~isempty(stepDir)
        if stepDir ~= moveDir || rem(edgeCount,2) == 0 % Avoid getting points on same side of disk
            edgeCount = edgeCount+1;
            moveDir = stepDir;
            xPtsAll = [xPtsAll,xPts];
            yPtsAll = [yPtsAll,yPts];
            % xPos1(edgeCount) = xPos;
                if edgeCount==2
                    yPos = round(ySize*3/4); % Second search row is 3/4 down from top of image
                    xPos = round(xSize/2);
                    moveDir = -1;
                end
        end
    end
    xPos = xPos + moveDir*xImageStep;
    if (xPos<1 || xPos>(xSize-xfov))
        disp('No edge found');
        noEdge = 1;
        break;
    end
end
if (xMoves==40)
    disp('No edge found');
    noEdge = 1;
end

if (noEdge == 0)
    [xc,yc,R,~] = circfit(xPtsAll,yPtsAll);
    R = floor(R);
    xc = round(xc);
    yc = round(yc);
else
    xc = NaN;
    yc = NaN;
    R = NaN;
    return;
end
toc
if (showGraphics && noEdge==0)
    theta = 0:pi/100:2*pi;
    xfit = R*cos(theta)+xc;
    yfit = R*sin(theta)+yc;
    figure(1)
    hold on
    plot(xc,yc,'ro');
    plot(xfit,yfit,'g-');
    plot(xPtsAll,yPtsAll,'bo');
    hold off
    % Crop image
    Icrop = leafDiskImage(yc-R:yc+R,xc-R:xc+R,3); % blue channel only
    figure(2)
    imshow(Icrop,'InitialMagnification','fit');
end
end

