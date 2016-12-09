function [ fullPath ] = saveImgs( objects, path)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,[fileName, '.png']);
imwrite(curImg,fullPath);
end