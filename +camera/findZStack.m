function [zStackLocs] = findZStack(app,closeCamera)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
disp(datestr(now));
if nargin == 1
    closeCamera = true;
end
if ~closeCamera
    ok = D850_driver_v2('live_on');
    sampleFound = camera.isSampleCentered(app,0);
else
    if app.VidObj == -1
        ok = D850_driver_v2('open'); %#ok<*NASGU>
        ok = D850_driver_v2('live_on');
        var = onCleanup(@clean);
    end
    sampleFound = true;
end
if ~sampleFound
    return
end
centerLoc = app.curZ;
[centerVal,B] = takeCalImg(app.VidObj,app.Zmotor,centerLoc);
% [ok,curImage] = D850_driver_v2('live_get');
% [ sampleFound ,Iout] = camera.isSampleMask( curImage );
% img  = rangefilt(curImage(:,:,3));
% images = cell(100,1);
tempArr = B(:);
testVal = ones(100,1)*-1;
testLoc = ones(100,1)*-1;
testVal(1) =max(tempArr);
testLoc(1) = centerLoc;
allVal(1,:) = B(:);
% images{1} = immultiply(im2double(img),Iout);
% imCmbed = images{1};
i = 1;
threshold = .6;
% imshow(imCmbed);
% drawnow;
while testVal(i) >= centerVal*threshold
    i = i+1;
    testLoc(i) = testLoc(i-1)-app.StepsImageSpinner.Value;
    [testVal(i),B] = takeCalImg(app.VidObj,app.Zmotor,testLoc(i));
    allVal(i,:) = B(:);
    if testVal(i) > centerVal
        centerVal = testVal(i);
        centerLoc = testLoc(i);
    end
%     [ok,curImage] = D850_driver_v2('live_get');
%     [ sampleFound ,Iout] = camera.isSampleMask( curImage );
%     img  = rangefilt(curImage(:,:,3));
%     images{i} = immultiply(im2double(img),Iout);
%     imCmbed = imadd(imCmbed,images{i});
%     imshow(imCmbed);
%     drawnow;
    if (testLoc(i)-app.StepsImageSpinner.Value/2 > app.Zmotor.UserData.Upper) || (testLoc(i)-app.StepsImageSpinner.Value/2 < app.Zmotor.UserData.Lower)
        break
    end
   
end
upperLoc = testLoc(end);
i=i+1;
[testLoc(i),ind]  = max(testLoc(testLoc>0));
testVal(i) = testVal(ind);
% [ok,curImage] = D850_driver_v2('live_get');
% [ sampleFound ,Iout] = camera.isSampleMask( curImage );
% img  = rangefilt(curImage(:,:,3));
% images{i} = immultiply(im2double(img),Iout);
% imCmbed = imadd(imCmbed,images{i});
while testVal(i) >= centerVal*threshold
    i = i+1;
    testLoc(i) = testLoc(i-1)+app.StepsImageSpinner.Value;
    [testVal(i),B] = takeCalImg(app.VidObj,app.Zmotor,testLoc(i));
    allVal(i,:) = B(:);
    if testVal(i) > centerVal
        centerVal = testVal(i);
        centerLoc = testLoc(i);
    end
%     [ok,curImage] = D850_driver_v2('live_get');
%     [ sampleFound ,Iout] = camera.isSampleMask( curImage );
%     img  = rangefilt(curImage(:,:,3));
%     images{i} = immultiply(im2double(img),Iout);
%     imCmbed = imadd(imCmbed,images{i});
%     imshow(imCmbed);
%     drawnow;
    if (testLoc(i)-app.StepsImageSpinner.Value/2 > app.Zmotor.UserData.Upper) || (testLoc(i)-app.StepsImageSpinner.Value/2 < app.Zmotor.UserData.Lower)
        break
    end
    
end
% imshow(imCmbed);
[v,ind] = max(allVal,[],1,'omitnan');

stackInds = unique(ind);
maxLocs = testLoc(stackInds);
lowerLoc = min(maxLocs);
upperLoc = max(maxLocs);
if lowerLoc == upperLoc
    cntr = round(mean([lowerLoc,upperLoc]));
    
    zStackLocs(1) = round(cntr-app.StepsImageSpinner.Value*.5);

    zStackLocs(2) = round(cntr+app.StepsImageSpinner.Value*.5);

else
    zStackLocs = round(lowerLoc:app.StepsImageSpinner.Value:upperLoc);
end
if length(zStackLocs) <= 2
    cntr = round(mean([lowerLoc,upperLoc]));
    
    zStackLocs(1) = round(cntr-app.StepsImageSpinner.Value*.5);

    zStackLocs(2) = round(cntr+app.StepsImageSpinner.Value*.5);

end
zStackLocs(zStackLocs<200) = [];
D850_driver_v2('live_off');
zStackLocs = sort(zStackLocs,'descend');
for i= 1:length(zStackLocs)
    serialCom.moveTo(app.Zmotor,zStackLocs(i));
    savename2                   = sprintf('Img%03g',i);
    app.FileNameEditField.Value = savename2;
    writeImage(app,savename2);
end
% disp(length(zStackLocs))
end

function [result,B] = takeCalImg(VidObj,Zmotor,loc)
serialCom.moveTo(Zmotor,round(loc));

if VidObj == -1
    [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    curImage = getsnapshot(app.VidObj);
end
[l,w,~] = size(curImage);
% curImage(1:round(l*0.1),:,:) = [];
% curImage(:,1:round(w*0.1),:) = [];
% curImage(end-round(l*0.1):end,:,:) = [];
% curImage(:,end-round(w*0.1):end,:) = [];
% figure(1)
% imshow(curImage);
% drawnow;

fun = @(x) camera.contrastMetric(x);
[ sampleFound ,Iout] = camera.isSampleMask( curImage );
img  = rangefilt(curImage(:,:,3));
image = immultiply(im2double(img),Iout);

[l,w,~] = size(image);
B = blockproc(image,round([l/4,w/4]),fun);
fun = @(x) camera.isSampleMask(x.data);
B2 = blockproc(curImage,round([l/4,w/4]),fun);
B(~B2) = 0;
% figure(2)
% drawnow;
% imshow(imadjust(uint8(B)));
result = max(max(B));
end
function writeImage(app,fileName)
saveExt     = app.FormatDropDown_2.Value;
saveLoc     = fullfile(app.SaveDir, fileName);
file        = java.io.File(saveLoc);
if ~file.exists()
    if app.nikonCam
        camera.saveNikonImg(saveLoc,0);
    else
        imwrite(app.CurImg(app), saveLoc);
    end
else
    i = 1;
    while file.exists()
        saveLoc = fullfile(app.SaveDir, [fileName,'(',num2str(i),')']);
        file=java.io.File(saveLoc);
        i=i+1;
    end
    if app.nikonCam
        camera.saveNikonImg(saveLoc,0);
    else
        imwrite(CurImg(app), saveLoc);
    end
end
end

function clean
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
end


