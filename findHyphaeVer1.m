function [hyphaeCnt] = findHyphaeVer1(leafImage,thickness,rhoRes,thetaRes,showGraphics, eqlize)
% Find hyphae in leaf image

%showGraphics = true; % true or false
numPeaksLimit = 30; % The maximum number of peaks returned by houghpeaks()
peakThreshold = 100; % Threshold of Hough transform peak value
fillGapLen = 20; % Maximum gap size defining line segments, [pixels]
minLineLen = 200; %Minimum line segment length returned by houghlines(), [pixels]
peakOverAvgThres = 4;
adjacentLineRatioThres = 0.15; %0.20;
lineLengthThres = 200; % [pixels]
d = 8; %12; % Adjacent line disance away from line, [pixel length]

theta = -90:thetaRes:90-thetaRes; % Degrees
if eqlize
    leafImage = histeq(leafImage);
end
B = fibermetric(leafImage, thickness, 'ObjectPolarity','bright'); %, 'StructureSensitivity', 3); % 'bright' or 'dark'
% Length of Hough transform lines
I = ones(size(B));
[Hlen,~,~] = hough(I,'RhoResolution',rhoRes,'Theta',theta);
% Image binarization
T = adaptthresh(B, 0.2);
BW = imbinarize(B,T); %'adaptive');%,0.50);
% Hough transform
[H,T,R] = hough(BW,'RhoResolution',rhoRes,'Theta',theta);
H2 = H./Hlen;
H2(isnan(H2)) = 1;
% Find peaks that are high in both transforms
H = round(H.*H2);
P = houghpeaks(H,numPeaksLimit,'Threshold',peakThreshold);
% Find line segments of possible hyphae
lines = houghlines(BW,T,R,P,'FillGap',fillGapLen,'MinLength',minLineLen);
numLines = length(lines);
peakRowColumn(1,:) = P(1,:);
Pindex = 1;
for loop = 2:numLines
    if (lines(loop).rho~=lines(loop-1).rho && lines(loop).theta~=lines(loop-1).theta)
        Pindex = Pindex + 1;
    end
    peakRowColumn(loop,:) = P(Pindex,:);
end

% Compute feature criteria
% Feature: Hough transform peak over mean
peakOverAvg = zeros(numLines,1);
H1 = H(:);
meanH = mean(H1(H1~=0)); % Mean of non-zero array elements 
for loop = 1:numLines
    peakOverAvg(loop) = H(peakRowColumn(loop,1),peakRowColumn(loop,2))/meanH;
end

% Feature: Adjacent line segment intensity ratio
adjacentLineRatio = zeros(numLines,1);
if showGraphics
    xyForPlot = zeros(2,2,numLines);
    xyAdjForPlot = zeros(2,2,numLines);
end
for loop = 1:numLines
    xy = [lines(loop).point1;lines(loop).point2];
    lineProfile = improfile(BW,xy(:,1), xy(:,2));
    lineDensity = mean(lineProfile);
    % adjacent parallel line
    if lines(loop).theta<0
        adjPoint1 = [lines(loop).point1(1)-d*cos(lines(loop).theta*pi/180),lines(loop).point1(2)-d*sin(lines(loop).theta*pi/180)]; % [x,y]
        adjPoint2 = [lines(loop).point2(1)-d*cos(lines(loop).theta*pi/180),lines(loop).point2(2)-d*sin(lines(loop).theta*pi/180)]; % [x,y]
    else
        adjPoint1 = [lines(loop).point1(1)+d*cos(lines(loop).theta*pi/180),lines(loop).point1(2)+d*sin(lines(loop).theta*pi/180)]; % [x,y]
        adjPoint2 = [lines(loop).point2(1)+d*cos(lines(loop).theta*pi/180),lines(loop).point2(2)+d*sin(lines(loop).theta*pi/180)]; % [x,y]
    end
    xyAdj = [adjPoint1;adjPoint2];
    if showGraphics
        xyForPlot(:,:,loop) = xy;
        xyAdjForPlot(:,:,loop) = xyAdj;
    end
    lineAdjProfile = improfile(BW,xyAdj(:,1), xyAdj(:,2));
    lineDensityAdj = mean(lineAdjProfile);
    adjacentLineRatio(loop) = lineDensityAdj/lineDensity;
end

% Features: Line segment length, theta and rho
lineLength = zeros(numLines,1);
lineTheta = zeros(numLines,1);
lineRho = zeros(numLines,1);
for loop = 1:numLines
    lineLength(loop) = norm(lines(loop).point1 - lines(loop).point2);
    lineTheta(loop) = lines(loop).theta;
    lineRho(loop) = lines(loop).rho;
end

% Apply feature criteria to find lines that are hyphae
isHyphae = false(numLines,1);
for loop = 1:numLines
    isHyphae(loop) = peakOverAvg(loop) > peakOverAvgThres &&...
        adjacentLineRatio(loop) < adjacentLineRatioThres &&...
        lineLength(loop) > lineLengthThres;
end
hyphaeCnt = nnz(isHyphae);

if showGraphics
    close('all');
    %if (ishandle(5))
    %    close(5);
    %end
    figure(1)
    imshow(leafImage,'InitialMagnification','fit');
    title('Starting Image')
    figure(2);
    imshow(B*3,'InitialMagnification','fit'); % x3
    title(['Fiberous structures ',num2str(thickness,'%d'),' pixels thick'])
    figure(3)
    imshow(BW,'InitialMagnification','fit')
    figure(4)
    imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
    xlabel('\theta'),ylabel('\rho');
    axis on;axis normal;
    title(['Hough Transform, H (H^2/lenght)',', max(H) = ',num2str(max(H(:)),'%d')]);
    x = T(peakRowColumn(:,2));
    y = R(peakRowColumn(:,1));
    figure(4)
    hold on
    plot(x,y,'o','color','red');
    hold off
    figure(5)
    imshow(BW,'InitialMagnification','fit');
    hold on
    for loop = 1:numLines
        plot(xyAdjForPlot(:,1,loop), xyAdjForPlot(:,2,loop),'LineWidth',1,'Color','red');
        if isHyphae(loop)
            plot(xyForPlot(:,1,loop), xyForPlot(:,2,loop),'LineWidth',2,'Color','green');
        end
    end
    drawnow
end
hold off
