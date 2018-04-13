function autoFocusGaussian(VidObj, Zmotor,StepSize,hystVal,closeCamera)
% AUTOFOCUS command
%

if nargin == 4
    closeCamera = 1;
end
% TODO add preallocation
Low = Zmotor.UserData.Lower;
High = Zmotor.UserData.Upper;
z = [];
C = [];

if closeCamera
    if VidObj == -1
        ok = D850_driver_v2('open'); %#ok<*NASGU>
        ok = D850_driver_v2('live_on');
        var = onCleanup(@clean);
    end
end
opts = optimset('TolX',max([StepSize,10]));
[x,fval,exitflag,output] = fminbnd(@(x)-takeCalImg(VidObj,Zmotor,x),Low+hystVal,High-hystVal,opts);

if VidObj == -1
    [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    curImage = getsnapshot(app.VidObj);
end
imshow(curImage);
drawnow;
end

function result = takeCalImg(VidObj,Zmotor,loc)
newLoc = round(loc);
serialCom.moveTo(Zmotor,newLoc);
if VidObj == -1
    [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    curImage = getsnapshot(VidObj);
end

[l,w,~] = size(curImage);
smallImage = curImage(round(l/3:l*2/3),round(w/3:w*2/3),3);
fun = @(x) camera.contrastMetric(x);

[l,w,~] = size(smallImage);
B = blockproc(smallImage,round([l/2,w/2]-1),fun);
result = max(max(B));
end

function clean
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
end