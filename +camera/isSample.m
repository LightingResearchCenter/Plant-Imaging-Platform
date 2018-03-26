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
if sum( img1_double(:)) > .5*x*y
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