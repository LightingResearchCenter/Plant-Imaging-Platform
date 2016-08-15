function [ s, dirMove ] = isSampleCentered( BWimg, results)
%isSampleCentered Summary of this function goes here
%
%% Split up edge of pictures
imgSize = 50;
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
stepLR = int32(floor((1.5*imgSize*results.object.Cal.pix2mm)/(results.object.Cal.LRstep2mm/100)));
stepTB = int32(floor((1.5*(imgSize*results.object.Cal.pix2mm)/(results.object.Cal.TBstep2mm/100))));

if results.direction == 1
    switch dirMove
        case 0
            return
        case 1
            serialCom.stepMove(results.object.Xmotor,-stepLR);
            
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2, results);
        case 2
            serialCom.stepMove(results.object.Xmotor,stepLR);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results);
        case 3
            serialCom.stepMove(results.object.Ymotor,stepTB);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results);
        case 4
            serialCom.stepMove(results.object.Ymotor,-stepTB);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results);
        otherwise
            
    end
else
    switch dirMove
        case 0
            return
        case 2
            serialCom.stepMove(results.object.Xmotor,stepLR);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results);
        case 1
            serialCom.stepMove(results.object.Xmotor,-stepLR);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2, results);
        case 3
            serialCom.stepMove(results.object.Ymotor,stepTB);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results);
        case 4
            serialCom.stepMove(results.object.Ymotor,-stepTB);
            [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
            camera.isSampleCentered( BWimg2,results);
        otherwise
            disp('what did you do to get here?')
    end
end
end
