function sampleFound = isSampleCentered(app,closeCamera)
%isSampleCentered Summary of this function goes here
%

% Input Setup
if nargin == 1
    closeCamera = true;
end
% check location
if closeCamera
    if app.VidObj == -1
        ok = D850_driver_v2('open'); %#ok<*NASGU>
        ok = D850_driver_v2('live_on');
        var = onCleanup(@clean);
    end   
end
if app.VidObj == -1
    [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    curImage = getsnapshot(app.VidObj);
end

[sampleFound ,BWimg] = camera.isSampleMask( curImage );

nRun = 0;
while (sampleFound) && (nRun <10)
    Ilabel1 = logical(BWimg);
    stat1 = regionprops(Ilabel1,'centroid');
    sampleCentroid = [stat1(1).Centroid(1),stat1(1).Centroid(2)];
    Ilabel2 = ones(size(BWimg));
    stat2 = regionprops(Ilabel2,'centroid');
    pictureCentroid = [stat2(1).Centroid(1),stat2(1).Centroid(2)];
    deltaX = sampleCentroid(1)-pictureCentroid(1);
    deltaY = sampleCentroid(2)-pictureCentroid(2);
    Xstep = floor(((deltaX/50)*app.Xmm2step));
    Ystep = floor(((deltaY/50)*(app.Ymm2step)));
    
    % tell motor to move and check new location.
    
    if abs(Xstep)+abs(Ystep) > 20
        serialCom.moveTo(app.Xmotor,app.curX-round(Xstep));
        serialCom.moveTo(app.Ymotor,app.curY-round(Ystep));
        if app.VidObj == -1
            [ok,curImage] = D850_driver_v2('live_get'); %#ok<*ASGLU>
        else
            curImage = getsnapshot(app.VidObj);
        end
        [sampleFound ,BWimg] = camera.isSampleMask( curImage );
    else
        break
    end
    nRun = nRun +1;
end
if sampleFound
    hystVal = (app.ImagesSpinner.Value*app.StepsImageSpinner.Value)/2;
    camera.autoFocusGaussian(app.VidObj,app.Zmotor,app.FocusStepEditField.Value*2,hystVal,0);
end
end

function clean
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
end