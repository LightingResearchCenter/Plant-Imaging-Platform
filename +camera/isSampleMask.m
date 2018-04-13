function [ sampleFound ,img1_double] = isSampleMask( img )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


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
if sum( img1_double(:)) > .4*x*y
    sampleFound = true;
else
    sampleFound = false;
end
end
