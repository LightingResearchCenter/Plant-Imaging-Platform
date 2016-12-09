function [ sampleFound ,bw5] = isSample( img )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


[bw2,~] = camera.createMask(img);
[x,y] = size(bw2);
imgSize = floor(x*y*.05);
bw3 = bwareaopen(bw2,imgSize);
se = strel('disk',25);
bw4 = imclose(bw3,se);
bw5 = imfill(bw4,'holes');

img1_double = double(bw5);
img2_double = double(ones(size(bw5)));
img3_double = double(zeros(size(bw5)));

if sum( abs( img1_double(:) - img2_double(:) ) ) == 0.0 | sum( abs( img1_double(:) - img3_double(:) ) ) == 0.0 
    sampleFound = false;
else 
    sampleFound = true;
end
end