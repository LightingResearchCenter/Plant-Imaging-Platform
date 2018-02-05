% Script for calling findHyphaeVer2(), collecting results and making feature and target matrices

pathName = 'C:\AndyNewStuff\GrapeMold\AutomatedMildewAnalyzerApparatus\GrapeMildewImagesPlate4\';
DIR = dir(pathName);
DIR = DIR(3:end);

thickness = [7]; % Fiber thickness in pixels
rhoRes = 3; % rho resolution for Hough transform, [pixels]
thetaRes = 1; % angle resolution for Hough transform, [degrees]

hyphaeCnt = [];
featureMatrix = [];
targetMatrix = [];
for loop = 15:length(DIR) %length(fileNameList)
    fileName = DIR(loop).name;
    pathFileName = [pathName,fileName];
    leafImage = imread(pathFileName);
    leafImage = leafImage(:,:,3); % Blue channel
    [hyphaeCnt(loop),fMatrix,tMatrix] = findHyphaeVer2(leafImage,thickness,rhoRes,thetaRes,true);
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
save(fileName,'featureMatrix')
fileName = ['targetMatrix',timeStamp];
save(fileName,'targetMatrix')

