% Autofocus routine

% pathName = '\\ROOT\dropbox\Machirouf_Koli\test\Focus Testing\';
% fileList = {'Dec0617_160852_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_160918_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_160947_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_160953_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161015_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161020_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161025_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161031_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161039_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161052_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161059_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161106_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161114_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161121_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161511_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161548_W100R40B40T40L40_(1).tiff',...
%     'Dec0617_161618_W100R40B40T40L40_(1).tiff'};

fileNum = [];
z = [];
C = [];
% Take image
fileNum(1) = 1 % 3;
fileName = fileList{fileNum(1)};
pathFileName = [pathName,fileName];
leafImage = imread(pathFileName);
leafImage = leafImage(:,:,2); % Change to Blue channel

z(1) = fileNum(1); %0; z axis pos
C(1) = contrastMetric(leafImage);

% Move +z distance and take image
fileNum(2) = fileNum(1) + 2 % 5;
fileName = fileList{fileNum(2)};
pathFileName = [pathName,fileName];
leafImage = imread(pathFileName);
leafImage = leafImage(:,:,2); % Change to Blue channel

z(2) = fileNum(2); %-fileNum(1); % z(2) =  current location
C(2) = contrastMetric(leafImage);

% Compute slope
P = polyfit(z,C,1); % Slope is P(1)

if (P(1)>0) % If slope is positive
    % Move +z distance and take image
    fileNum(3) = fileNum(2) + 2;
    fileName = fileList{fileNum(3)};
    pathFileName = [pathName,fileName];
    leafImage = imread(pathFileName);
    leafImage = leafImage(:,:,2); % Change to Blue channel
    
    z(3) = fileNum(3); %-fileNum(1);
    C(3) = contrastMetric(leafImage);
    P = polyfit(z,C,2);
    zPeak = -P(2)/(2*P(1)); % zPeak = -b/(2*a)
    if ((P(1)*zPeak^2 + P(2)*zPeak + P(3)) > (P(1)*(zPeak+1)^2 + P(2)*(zPeak+1) + P(3)))
        isPeak = true;
    else
        isPeak = false;
    end
    % while last measure location is less than z value of polynomial peak
    fileNumLoop = fileNum(3);
    while (z(end) < zPeak || ~isPeak)
        % Move +x distance and take image
        fileNumLoop = fileNumLoop+2
        fileName = fileList{fileNumLoop};
        pathFileName = [pathName,fileName];
        leafImage = imread(pathFileName);
        leafImage = leafImage(:,:,2); % Change to Blue channel
        z(end+1) = fileNumLoop; %-fileNum(1);
        C(end+1) = contrastMetric(leafImage);
        P = polyfit(z,C,2);
        zPeak = -P(2)/(2*P(1)); % zPeak = -b/(2*a)
        if ((P(1)*zPeak^2 + P(2)*zPeak + P(3)) > (P(1)*(zPeak+1)^2 + P(2)*(zPeak+1) + P(3)))
            isPeak = true;
        else
            isPeak = false;
        end

    end
else
    % Move -2*(z distance) and take image
    fileNum(3) = fileNum(2) - 4 % 1;
    fileName = fileList{fileNum(3)};
    pathFileName = [pathName,fileName];
    leafImage = imread(pathFileName);
    leafImage = leafImage(:,:,2); % Change to Blue channel
    
    z(3) = fileNum(3); %-fileNum(1);
    C(3) = contrastMetric(leafImage);
    P = polyfit(z,C,2);
    zPeak = -P(2)/(2*P(1)); % zPeak = -b/(2*a)
    if ((P(1)*zPeak^2 + P(2)*zPeak + P(3)) > (P(1)*(zPeak+1)^2 + P(2)*(zPeak+1) + P(3)))
        isPeak = true;
    else
        isPeak = false;
    end
    % while last measurement location is greater than x value of polynomial peak
    fileNumLoop = fileNum(3);
    while (z(end) > zPeak || ~isPeak)
        % Move -x distance and take image
        fileNumLoop = fileNumLoop - 2
        fileName = fileList{fileNumLoop};
        pathFileName = [pathName,fileName];
        leafImage = imread(pathFileName);
        leafImage = leafImage(:,:,2); % Change to Blue channel
        z(end+1) = fileNumLoop; %-fileNum(1);
        C(end+1) = contrastMetric(leafImage);
        P = polyfit(z,C,2);
        zPeak = -P(2)/(2*P(1)); % zPeak = -b/(2*a)
        if ((P(1)*zPeak^2 + P(2)*zPeak + P(3)) > (P(1)*(zPeak+1)^2 + P(2)*(zPeak+1) + P(3)))
            isPeak = true;
        else
            isPeak = false;
        end
    end
end

% Goto z location corresponding to polynomial peak
% Move (zPeak-zend) steps
focusPosition = zPeak;
% Show focued image

figure(2)
zfit = 0:1:16;
Cpoly = P(1)*zfit.^2 + P(2)*zfit + P(3);
plot(zfit,Cpoly,'b.-')
hold on
plot(z,C,'rd')
hold off

