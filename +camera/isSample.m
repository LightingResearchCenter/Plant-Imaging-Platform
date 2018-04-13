function [ sampleFound ,Iout] = isSample( app )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if app.VidObj == -1
    ok = D850_driver_v2('open'); %#ok<*NASGU>
    ok = D850_driver_v2('live_on');
end
var = onCleanup(@clean);
if app.VidObj == -1
    [ok,img] = D850_driver_v2('live_get'); %#ok<*ASGLU>
else
    img = getsnapshot(app.VidObj);
end
[ sampleFound ,Iout] = camera.isSampleMask(img);
end

function clean
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
end