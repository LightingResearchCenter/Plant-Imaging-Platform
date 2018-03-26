% Script for calling findHyphaeVer2(), collecting results and making feature and target matrices

pathName = 'C:\AndyNewStuff\GrapeMold\AutomatedMildewAnalyzerApparatus\WholeLeafDiskMegaPixelCamera\';
%pathName = 'C:\AndyNewStuff\GrapeMold\AutomatedMildewAnalyzerApparatus\Mildew Pictures\NovemberSamples\Plate4\';
DIR = dir(pathName);
DIR = DIR(3:end);

thickness = 7; %[7]; % Fiber thickness in pixels
rhoRes = 3; % rho resolution for Hough transform, [pixels]
thetaRes = 1; % angle resolution for Hough transform, [degrees]

hyphaeCnt = [];
featureMatrix = [];
targetMatrix = [];
for loop = 15:15 %length(DIR) %length(fileNameList)
    fileName = 'CY2D2.jpg'; %'I2021_2017-11-11-134017-0000(C)_39_10-46-43.tif'; %'1_125thSec.jpg'; % DIR(loop).name;
    pathFileName = [pathName,fileName];
    leafImage = imread(pathFileName);
    %leafImage = leafImage(:,:,3); % Blue channel
    %leafImage = leafImage(2700:4700,3700:5700,3); % Blue channel
    leafImage = leafImage(2200:4200,3200:5200,3); % Blue channel
    [hyphaeCnt(loop),fMatrix,tMatrix] = findHyphaeVer2ManyAdjLines(leafImage,thickness,rhoRes,thetaRes,true);
    disp(['Loop Count = ',num2str(loop,'%d'),' Hyphae count = ',num2str(hyphaeCnt(loop),'%d')]);
    
    % Assemble NN input and target matricies
    featureMatrix = [featureMatrix,fMatrix];
    targetMatrix = [targetMatrix,tMatrix];

    userInput = input('Continue?');
    if userInput==0
        break;
    end
end
timeStamp = datestr(now,'yyyymmmddHHMM')
fileName = ['featureMatrix',timeStamp];
%save(fileName,'featureMatrix')
fileName = ['targetMatrix',timeStamp];
%save(fileName,'targetMatrix')

