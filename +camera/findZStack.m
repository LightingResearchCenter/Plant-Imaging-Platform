function [zStackLocs] = findZStack(app)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if app.VidObj == -1
    ok = D850_driver_v2('open'); %#ok<*NASGU>
    ok = D850_driver_v2('live_on');
end
var = onCleanup(@clean);
centerLoc = app.curZ;
[centerVal,B] = takeCalImg(app.VidObj,app.Zmotor,centerLoc);
testVal(1) = centerVal;
testLoc(1) = centerLoc;
allVal(1,:) = B(:);
i = 0;
while testVal(end) >= centerVal*(3/4)
    i = i+1;
    testLoc(i) = testLoc(end)+app.StepsImageSpinner.Value*2;
    [testVal(i),B] = takeCalImg(app.VidObj,app.Zmotor,testLoc(end));
    allVal(i,:) = B(:);
   
    if (testLoc(end) > app.Zmotor.UserData.Upper) || (testLoc(end) < app.Zmotor.UserData.Lower)
        break
    end
   
end
upperLoc = testLoc(end);
testLoc(end+1)  = centerLoc;
testVal(end+1) = centerVal;

while testVal(end) >= centerVal*(3/4)
    i = i+1;
    testLoc(i) = testLoc(end)-app.StepsImageSpinner.Value*2;
    [testVal(i),B] = takeCalImg(app.VidObj,app.Zmotor,testLoc(end));
    allVal(i,:) = B(:);
    
    if (testLoc(end) > app.Zmotor.UserData.Upper) || (testLoc(end) < app.Zmotor.UserData.Lower)
        break
    end
end

allVal(:,[1,4,13,16])=[];
[v,ind] = max(allVal,[],1,'omitnan');
stackInds = unique(ind);
maxLocs = testLoc(stackInds);
lowerLoc = min(maxLocs);
upperLoc = max(maxLocs);
if lowerLoc == upperLoc
    zStackLocs(1) = round(lowerLoc-app.StepsImageSpinner.Value);
    zStackLocs(2) = round(upperLoc);
    zStackLocs(3) = round(upperLoc+app.StepsImageSpinner.Value);
else
    zStackLocs = round((lowerLoc-app.StepsImageSpinner.Value):app.StepsImageSpinner.Value:(upperLoc+app.StepsImageSpinner.Value));
end
if length(zStackLocs) <2
    zStackLocs(1) = round(lowerLoc-app.StepsImageSpinner.Value);
    zStackLocs(2) = round(upperLoc);
    zStackLocs(3) = round(upperLoc+app.StepsImageSpinner.Value);
end
disp(zStackLocs)
end
function [result,B] = takeCalImg(VidObj,Zmotor,loc)
serialCom.moveTo(Zmotor,round(loc));

if VidObj == -1
    [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    curImage = getsnapshot(app.VidObj);
end
imshow(curImage);
drawnow;
[l,w,~] = size(curImage);
fun = @(x) contrastMetric(x);
B = blockproc(curImage(:,:,3),round([l/4,w/4]),fun);
result = max(max(B));
end

function C = contrastMetric(Image)

Y = rangefilt(Image.data);

data  = double(Y(:));
C  = var(data)/mean(data);
end

function clean
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
end


