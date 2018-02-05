function [ sampleFound ,bw5] = isSample( img )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


[bw2,~] = camera.createMask(img);
[x,y] = size(bw2);
se = strel('disk',25);
bw4 = imclose(bw2,se);
bw5 = imfill(bw4,'holes');

img1_double = double(bw5);

if sum( img1_double(:)) > .80*x*y
    sampleFound = true;
else 
    sampleFound = false;
end
end