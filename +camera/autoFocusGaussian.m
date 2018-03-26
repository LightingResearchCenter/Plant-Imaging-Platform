function autoFocusGaussian(VidObj, Zmotor,StepSize,hystVal)
% AUTOFOCUS command
%


% TODO add preallocation
Low = Zmotor.UserData.Lower;
High = Zmotor.UserData.Upper;
z = [];
C = [];
drawnow;

if VidObj == -1
    ok = D850_driver_v2('open'); %#ok<*NASGU>
    ok = D850_driver_v2('live_on');
end
var = onCleanup(@clean);
opts = optimset('TolFun',max([StepSize,1]),'TolX',max([StepSize,10]));
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
serialCom.moveTo(Zmotor,round(loc));
if VidObj == -1
    [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    curImage = getsnapshot(app.VidObj);
end
imshow(curImage);
drawnow;
[l,w,~] = size(curImage);
smallImage = curImage(round(l/3:l*2/3),round(w/3:w*2/3),3);
imshow(curImage);
drawnow;
[l,w,~] = size(smallImage);
fun = @(x) contrastMetric(x);
B = blockproc(smallImage,round([l/2,w/2]),fun);
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