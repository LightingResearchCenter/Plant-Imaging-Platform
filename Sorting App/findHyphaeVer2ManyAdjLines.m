function [hyphaeCnt,featureMatrix] = findHyphaeVer2ManyAdjLines(leafImage,thickness,rhoRes,thetaRes,showGraphics)
% Find hyphae in leaf image

%showGraphics = true; % true or false
numPeaksLimit = 100; % The maximum number of peaks returned by houghpeaks()
peakThreshold = 100; %100; % Threshold of Hough transform peak value
fillGapLen = 20; %10; %20; % Maximum gap size defining line segments, [pixels]
minLineLen = 150; %200; %Minimum line segment length returned by houghlines(), [pixels]
peakOverAvgThres = 3; %4;
adjacentLineRatioThres = 0.15; %0.15;
lineLengthThres = 200; % [pixels]
d = -20:1:20; %[-8,-4,4,8]; %8; % Adjacent line disance away from line, [pixel length]
d1 = [-6,-4,4,6];d1 = find(d1(1)==d|d1(2)==d|d1(3)==d|d1(4)==d); % Adjacent line distances for ratios
minArea = 40;
theta = -90:thetaRes:90-thetaRes; % Degrees
B = fibermetricAndy(leafImage, thickness, 'ObjectPolarity','bright','StructureSensitivity', 1.0); %, 'StructureSensitivity', 0.2); % 'bright' or 'dark'
% Length of Hough transform lines
I = ones(size(B));
[Hlen,~,~] = hough(I,'RhoResolution',rhoRes,'Theta',theta);
% Image binarization
T = adaptthresh(B, 0.4,'Statistic','mean'); % 0.2
BWold = imbinarize(B,T); %'adaptive');%,0.50);
cc = bwconncomp(BWold); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > minArea); 
BW = ismember(labelmatrix(cc), idx);  
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
if numLines==0
    hyphaeCnt = 0;
    featureMatrix = [];
    targetMatrix = [];
    return;
else
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
    peakOverAvg = zeros(1,numLines);
    H1 = H(:);
    meanH = mean(H1(H1~=0)); % Mean of non-zero array elements
    for loop = 1:numLines
        peakOverAvg(loop) = H(peakRowColumn(loop,1),peakRowColumn(loop,2))/meanH;
    end
    
    % Feature: Adjacent line segment intensity ratio
    % **** Modified to include mulitple adjacent lines different distances away *****
    adjacentLineRatio = zeros(length(d),numLines);
    % adjacentLineRatio = zeros(numLines,1);
    if showGraphics
        xyForPlot = zeros(2,2,numLines);
        xyAdjForPlot = zeros(2,2,numLines,length(d));
    end
    for loop = 1:numLines
        xy = [lines(loop).point1;lines(loop).point2];
        %lineProfile = improfile(BW,xy(:,1), xy(:,2));
        lineProfile = improfile(leafImage,xy(:,1), xy(:,2));
        lineDensity = mean(lineProfile);
        % adjacent parallel line
        for loopd = 1:length(d)
            if lines(loop).theta<0
                adjPoint1 = [lines(loop).point1(1)-d(loopd)*cos(lines(loop).theta*pi/180),lines(loop).point1(2)-d(loopd)*sin(lines(loop).theta*pi/180)]; % [x,y]
                adjPoint2 = [lines(loop).point2(1)-d(loopd)*cos(lines(loop).theta*pi/180),lines(loop).point2(2)-d(loopd)*sin(lines(loop).theta*pi/180)]; % [x,y]
            else
                adjPoint1 = [lines(loop).point1(1)+d(loopd)*cos(lines(loop).theta*pi/180),lines(loop).point1(2)+d(loopd)*sin(lines(loop).theta*pi/180)]; % [x,y]
                adjPoint2 = [lines(loop).point2(1)+d(loopd)*cos(lines(loop).theta*pi/180),lines(loop).point2(2)+d(loopd)*sin(lines(loop).theta*pi/180)]; % [x,y]
            end
            xyAdj = [adjPoint1;adjPoint2];
            if showGraphics
                xyForPlot(:,:,loop) = xy;
                xyAdjForPlot(:,:,loop,loopd) = xyAdj;
            end
            %lineAdjProfile = improfile(BW,xyAdj(:,1), xyAdj(:,2));
            lineAdjProfile = improfile(leafImage,xyAdj(:,1), xyAdj(:,2));
            lineAdjProfile(isnan(lineAdjProfile)) = []; % Remove NaN points caused by line extennding beyond image boundaries
            if isempty(lineAdjProfile)
                adjacentLineRatio(loopd,loop) = 1;
            else
                lineDensityAdj = mean(lineAdjProfile);
                adjacentLineRatio(loopd,loop) = lineDensityAdj/lineDensity;
                if isnan(adjacentLineRatio(loopd,loop))
                    disp('NaN')
                end
            end
        end
    end
    
    % Feature: Gaussian fits of adjacent line intensities, mean1, std1, amp1, mean2, std2,amp2
    Gamp1 = zeros(1,numLines);
    Gmean1 = zeros(1,numLines);
    Gstd1 = zeros(1,numLines);
    Gamp2 = zeros(1,numLines);
    Gmean2 = zeros(1,numLines);
    Gstd2 = zeros(1,numLines);
    for loop = 1:numLines
        yData = adjacentLineRatio(:,loop)-min(adjacentLineRatio(:,loop));
        %fitObject = fit(d',yData','gauss1');
        fitObject = fit(d',yData,'gauss2');
        G = coeffvalues(fitObject);
        Gamp1(loop) = G(1);
        Gmean1(loop) = G(2);
        Gstd1(loop) = G(3);
        Gamp2(loop) = G(4);
        Gmean2(loop) = G(5);
        Gstd2(loop) = G(6);
    end
     
    % Feature: Line segment density, density standard deviation,
    lineMean = zeros(1,numLines);
    lineVar = zeros(1,numLines);
    lineMoment3 = zeros(1,numLines);
    lineMoment4 = zeros(1,numLines);
    for loop = 1:numLines
        xy = [lines(loop).point1;lines(loop).point2];
        lineProfile = improfile(leafImage,xy(:,1), xy(:,2));
        lineMean(loop) = mean(lineProfile)/mean2(leafImage); % Mean relative to whole image mean
        profileStd = std(lineProfile,1); % sample std, not population estimate
        lineVar(loop) = moment(lineProfile,2)/mean(lineProfile)^2;
        lineMoment3(loop) = moment(lineProfile,3)/profileStd^3;
        lineMoment4(loop) = moment(lineProfile,4)/profileStd^4;
    end
    
    % Features: Line segment length, theta and rho
    lineLength = zeros(1,numLines);
    lineTheta = zeros(1,numLines);
    lineRho = zeros(1,numLines);
    for loop = 1:numLines
        lineLength(loop) = 0.001*(norm(lines(loop).point1 - lines(loop).point2)); % Divide by 1000 to normlize values
        lineTheta(loop) = lines(loop).theta;
        lineRho(loop) = lines(loop).rho;
    end
    
    % Apply feature criteria to find lines that are hyphae
    isHyphae = false(1,numLines);
    for loop = 1:numLines
        isHyphae(loop) = peakOverAvg(loop) > peakOverAvgThres &&...
            adjacentLineRatio(1,loop) < adjacentLineRatioThres &&...
            lineLength(loop) > 0.001*lineLengthThres;
    end
    featureMatrix = [peakOverAvg;adjacentLineRatio(d1(1),:);adjacentLineRatio(d1(2),:);adjacentLineRatio(d1(3),:);adjacentLineRatio(d1(4),:);...
        lineLength;lineMean;lineVar;lineMoment3;lineMoment4;Gamp1;Gmean1;Gstd1;Gamp2;Gmean2;Gstd2];
    [y1] = myNeuralNetworkFunction(featureMatrix);
    isHyphae = y1(1,:)>0.5;
    hyphaeCnt = nnz(isHyphae);
    
    if showGraphics
        close('all');
        %if (ishandle(5))
        %    close(5);
        %end
        figure(1)
        imshow(leafImage,'InitialMagnification','fit');
        set(gcf,'Position',[1,340,700,600]); % Left, bottom, width, height [0,100,560,420]
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
        set(gcf,'Position',[630,340,700,600]); % Left, bottom, width, height
        hold on
        figure(1); % Bring figure 1 to forefront
        hold on
        hyphCount = 0;
        for loop = 1:numLines
            for loopd = 1:1%length(d)
                figure(5)
                hpAdj(loop,loopd) = plot(xyAdjForPlot(:,1,loop,loopd), xyAdjForPlot(:,2,loop,loopd),'LineWidth',1,'Color','red');
                figure(1)
                hpAdjFig1(loop,loopd) = plot(xyForPlot(:,1,loop,loopd), xyForPlot(:,2,loop,loopd),'LineWidth',1,'Color','red');
            end
            
            figure(7)
            plot(d,adjacentLineRatio(:,loop),'b.');
            if ~strcmpi(get(gcf, 'WindowStyle'),'docked')
                set(gcf,'Position',[630,340,700,600]); % Left, bottom, width, height
            end
            %yData = adjacentLineRatio(loop,:)-min(adjacentLineRatio(loop,:));
            %fitObject = fit(d',yData','gauss2');
            %G = coeffvalues(fitObject);
            G = [Gamp1(loop),Gmean1(loop),Gstd1(loop),Gamp2(loop),Gmean2(loop),Gstd2(loop)];
            %yFit = G(1)*exp(-((d-G(2))/G(3)).^2)+min(adjacentLineRatio(loop,:));
            yFit = G(1)*exp(-((d-G(2))/G(3)).^2)...
                + G(4)*exp(-((d-G(5))/G(6)).^2)...
                + min(adjacentLineRatio(:,loop));
            hold on
            plot(d,yFit,'r-')
            hold off
            %text(0,0.3,['mean=',num2str(G(2),'%.1f'),' std=',num2str(G(3),'%.1f'),' A=',num2str(G(1),'%.1f')]);
            text(0,0.3,['mean=',num2str(G(2),'%.1f'),' std=',num2str(G(3),'%.1f'),' A=',num2str(G(1),'%.1f')]);
            text(0,0.2,['mean2=',num2str(G(5),'%.1f'),' std2=',num2str(G(6),'%.1f'),' A2=',num2str(G(4),'%.1f')]);
            set(gca,'Ylim',[0,1.2]);
        
            % figure(5)
            % figure(7) % bring to front
            figure(1)
            drawnow;
            %userInput(loop) = input(['line# ',num2str(loop,'%d'),' Hyphae? (0 or 1)']);
            a = []; % While loop to prevent error is only enter key is pressed
            toggle = 1;
            while isempty(a) || ~( (a==1) || (a==0) )
                try
                    a = input(['line# ',num2str(loop,'%d'),' Hyphae? (0 or 1)']);
                catch err
                    a=[];
                end
                toggle = xor(toggle,1);
                if toggle
                    set(hpAdjFig1(loop,loopd),'visible','off');
                else
                    set(hpAdjFig1(loop,loopd),'visible','on');
                end
            end
                
            set(hpAdjFig1(loop,loopd),'visible','off');
            userInput(loop) = a;
            
            figure(5)
            for loopd = 1:1 %length(d)
                set(hpAdj(loop,loopd),'visible','off');
            end
            if isHyphae(loop)
                hyphCount = hyphCount+1;
                hp(hyphCount) = plot(xyForPlot(:,1,loop), xyForPlot(:,2,loop),'LineWidth',2,'Color','green');
                set(hp(hyphCount),'visible','off');
            end
            %text(mean(xyAdjForPlot(:,1,loop,4)),mean(xyAdjForPlot(:,2,loop,4)),num2str(loop,'%d'),'Color',[1,1,0]);
        end
        drawnow
    end
    
    figure(5)
    if exist('hp','var')
        for loop = 1:hyphCount
            set(hp(loop),'visible','on');
        end
    end
    hold off
    drawnow
    featureMatrix = [peakOverAvg;adjacentLineRatio(d1(1),:);adjacentLineRatio(d1(2),:);adjacentLineRatio(d1(3),:);adjacentLineRatio(d1(4),:);...
        lineLength;lineMean;lineVar;lineMoment3;lineMoment4;Gamp1;Gmean1;Gstd1;Gamp2;Gmean2;Gstd2];
    featureTable = array2table(featureMatrix','VariableNames',{'peakOverAvg','Var2','Var3','Var4','Var5','lineLength','lineMean',...
        'lineVar','lineMoment3','lineMoment4','Gamp1','Gmean1','Gstd1','Gamp2',...
  'Gmean2','Gstd2'});
%     targetMatrix = [userInput;~userInput];
end
