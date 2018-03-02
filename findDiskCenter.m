function [xc,yc,R] = findDiskCenter(app,showGraphics)
% Image is a greyscale image
% xPos = absolute image x-position in units of pixels (to the right is positive)
% yPos = absolute image y-position in units of pixels (in (down on monitor image) is positive)
% showGraphics: false = no, true = yes

xfov = 2448; % pixels
yfov = 2048; % pixels
xImageStep = 2000; % pixels
yImageStep = 1600; % pixels
edgeCount = 0;
xPtsAll = [];
yPtsAll = [];
moveDir = -1; % -1 = left, 1 = right
xMoves = 0;
xPos = curX(app)/app.XStep2pix;
yPos = curY(app)/app.YStep2pix;
if showGraphics
    figure
    hFrame = patch([xPos,xPos+xfov,xPos+xfov,xPos],[yPos,yPos,yPos+yfov,yPos+yfov],'r','FaceColor','none','EdgeColor','r');
    set(gca,'YDir','reverse');
    set(gca,'YLim',[0,500000],'XLim',[0,500000])
end
xPos = curX(app)/app.XStep2pix;
yPos = curY(app)/app.YStep2pix;

while xMoves <20 && edgeCount <2
    searchDim = 'x';
    xMoves = xMoves + 1;
    %I = leafDisk(yPos:yPos+yfov-1,xPos:xPos+xfov-1);
    drawnow;
    Image = CurImg(app);
    BW = applyHVSMask(Image);
    SE = strel('disk',10);
    BW = imerode(BW,SE);
    SE = strel('disk',100);
    I = imclose(BW,SE);
    
    if showGraphics
        set(hFrame,'Vertices',[xPos,xPos+xfov,xPos+xfov,xPos;yPos,yPos,yPos+yfov,yPos+yfov]');
        % imshow(I);
    end
    [stepDir,xPts,yPts] = edgeFind(I,xPos,yPos,searchDim);
    
    if ~isempty(stepDir)
        if stepDir ~= moveDir || edgeCount == 0 % Avoid getting points on same side of disk
            edgeCount = edgeCount+1;
            moveDir = stepDir;
            xPtsAll = [xPtsAll,xPts];
            yPtsAll = [yPtsAll,yPts];
            xPos1(edgeCount) = xPos;
        end
    end
    serialCom.stepMove(app.Xmotor,-(moveDir*xImageStep)*app.XStep2pix);
    %     xPos = xPos + moveDir*xImageStep;
    xPos = curX(app)/app.XStep2pix;
end

% Go to mid chord point and move up
searchDim = 'y';
xmid = (xPos1(2)+xPos1(1))/2; % - xfov/2;
yPos = yPos-yImageStep;
yMoves = 0;
edgeCount = 0;
moveDir = -1; % -1 = away (up on screen), 1 = toward (down on screen)
xMove = xmid-xPos;
serialCom.stepMove(app.Xmotor,round((xMove)*app.XStep2pix)); %move to midpoint
xPos = curX(app)/app.XStep2pix;
while yMoves <20 && edgeCount <1
    yMoves = yMoves + 1;
    Image = CurImg(app);
    BW = applyHVSMask(Image);
    SE = strel('disk',10);
    BW = imerode(BW,SE);
    SE = strel('disk',100);
    I = imclose(BW,SE);
    if showGraphics
        set(hFrame,'Vertices',[xPos,xPos+xfov,xPos+xfov,xPos;yPos,yPos,yPos+yfov,yPos+yfov]');
        %imshow(I);
    end
    [stepDir,xPts,yPts] = edgeFind(I,xPos,yPos,searchDim);
    
    if ~isempty(stepDir)
        if yMoves < 3
            moveDir = -moveDir; % Too close to horixzontal chord, so get points on other side
        else
            edgeCount = edgeCount+1;
            moveDir = stepDir;
            xPtsAll = [xPtsAll,xPts];
            yPtsAll = [yPtsAll,yPts];
        end
    end
    serialCom.stepMove(app.Ymotor,(moveDir*YImageStep)*app.YStep2pix);
    %     yPos = yPos + moveDir*yImageStep;
    yPos = curY(app)/app.YStep2pix;
end

[xc,yc,R,~] = circfit(xPtsAll,yPtsAll);
theta = 0:pi/100:2*pi;
xfit = R*cos(theta)+xc;
yfit = R*sin(theta)+yc;
if showGraphics
    figure(1)
    hold on
    plot(xc,yc,'ro');
    plot(xfit,yfit,'g-');
    plot(xPtsAll,yPtsAll,'bo');
    hold off
end
end




