function isSampleCentered(app ,nRun)
%isSampleCentered Summary of this function goes here
%

% Input Setup
if nargin == 1
    nRun = 0;
else
    nRun = nRun +1;
end
if nRun >10
    return
end
% check location
if app.VidObj == -1
    ok = D850_driver_v2('open'); %#ok<*NASGU>
    ok = D850_driver_v2('live_on');
end
var = onCleanup(@clean);
if app.VidObj == -1
    [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    curImage = getsnapshot(app.VidObj);
end
imshow(curImage);
drawnow;
[ sampleFound ,BWimg] = isSample( app );
if sampleFound
    Ilabel1 = logical(BWimg);
    stat1 = regionprops(Ilabel1,'centroid');
    sampleCentroid = [stat1(1).Centroid(1),stat1(1).Centroid(2)];
    Ilabel2 = ones(size(BWimg));
    stat2 = regionprops(Ilabel2,'centroid');
    pictureCentroid = [stat2(1).Centroid(1),stat2(1).Centroid(2)];
    deltaX = sampleCentroid(1)-pictureCentroid(1);
    deltaY = sampleCentroid(2)-pictureCentroid(2);
    Xstep = floor(((deltaX/50)*app.Xmm2step));
    Ystep = floor(((deltaY/50)*(app.Ymm2step*1.3)));
    
    % tell motor to move and check new location.
    
    if abs(Xstep)+abs(Ystep) > 10
        serialCom.moveTo(app.Xmotor,app.curX-round(Xstep));
        serialCom.moveTo(app.Ymotor,app.curY-round(Ystep));
    else 
        return
    end
    if app.VidObj == -1
        [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
    else
        curImage = getsnapshot(VidObj);
    end
    [TFSample,~]=isSample(app);
    if TFSample && nRun <= 10
        camera.isSampleCentered(app,nRun);
    end
else
    return
end
end

function [ sampleFound ,Iout] = isSample( app )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if app.VidObj == -1
    [ok,img] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    img = getsnapshot(app.VidObj);
end
[bw2,~] = camera.createMask(img);
[x,y] = size(bw2);
se = strel('disk',5);
bw4 = imclose(bw2,se);
bw5 = imfill(bw4,'holes');


IL = bwlabel(bw5);
R = regionprops(bw5,'Area');
[~,ind] = max([R(:).Area]);

Iout = ismember(IL,ind);
% imshow(Iout);
img1_double = double(Iout);
if sum( img1_double(:)) > .25*x*y
    sampleFound = true;
else
    sampleFound = false;
end
end

function clean
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
end