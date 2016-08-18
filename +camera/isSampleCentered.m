function [ s, dirMove ] = isSampleCentered( BWimg, results,nRun, preDir, stepLR, stepTB)
%isSampleCentered Summary of this function goes here
%

%% Input Setup
imgSize = 50;
if nargin == 2
nRun = 0;
preDir = 0;
stepLR = int32(floor((3*imgSize*results.object.Cal.pix2mm)/(results.object.Cal.LRstep2mm/100)));
stepTB = int32(floor((3*(imgSize*results.object.Cal.pix2mm)/(results.object.Cal.TBstep2mm/100))));
else
    nRun = nRun +1;
end
%% Split up edge of pictures
s.imgLeft = BWimg(:,end-imgSize:end);
s.imgRight = BWimg(:,1:imgSize);
s.imgTop= BWimg(1:imgSize,:);
s.imgBot= BWimg(end-imgSize:end,:);
dirMove = 0;
%% Check sample Location
sampleLeft = any(s.imgLeft(:), 1);
sampleRight = any(s.imgRight(:), 1);
sampleTop = any(s.imgTop(:), 1);
sampleBot = any(s.imgBot(:), 1);
if sampleLeft
    dirMove = 1;
elseif sampleRight
    dirMove = 2;
elseif sampleTop
    dirMove = 3;
elseif sampleBot
    dirMove = 4;
end
if preDir ~= dirMove
    
end
if results.direction == 1
    switch dirMove
        case 0
            return
        case 1
            if preDir == 2 
                stepLR = .5*stepLR;
            end
            serialCom.stepMove(results.object.Xmotor,-stepLR);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2, results,nRun, dirMove, stepLR, stepTB);
        case 2
            if preDir == 1 
                stepLR = .5*stepLR;
            end
            serialCom.stepMove(results.object.Xmotor,stepLR);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results,nRun, dirMove, stepLR, stepTB);
        case 3
            if preDir == 4 
                stepTB = .5*stepLR;
            end
            serialCom.stepMove(results.object.Ymotor,stepTB);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results,nRun, dirMove, stepLR, stepTB);
        case 4
            if preDir == 3
                stepTB = .5*stepTB;
            end
            serialCom.stepMove(results.object.Ymotor,-stepTB);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results,nRun, dirMove, stepLR, stepTB);
        otherwise
            
    end
else
    switch dirMove
        case 0
            return
        case 2
            if preDir == 1
                stepLR = .5*stepLR;
            end
            serialCom.stepMove(results.object.Xmotor,stepLR);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results,nRun, dirMove, stepLR, stepTB);
        case 1
            if preDir == 2 
                stepLR = .5*stepLR;
            end
            serialCom.stepMove(results.object.Xmotor,-stepLR);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2, results,nRun, dirMove, stepLR, stepTB);
        case 3
            if preDir == 4
                stepTB = .5*stepTB;
            end
            serialCom.stepMove(results.object.Ymotor,stepTB);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results,nRun, dirMove, stepLR, stepTB);
        case 4
            if preDir == 3
                stepTB = .5*stepTB;
            end
            serialCom.stepMove(results.object.Ymotor,-stepTB);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results,nRun, dirMove, stepLR, stepTB);
        otherwise
            disp('what did you do to get here?')
    end
end
end
