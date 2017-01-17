function [ fullPath ] = saveImgs( objects, path)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
serialCom.writeToSerial(objects.Ymotor,'LA000:255');
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,[fileName, '.png']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LA000:000');
serialCom.writeToSerial(objects.Ymotor,'LB001:255');
pause(0.1);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,[fileName, '.png']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LB002:255');
pause(0.1);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,[fileName, '.png']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LB004:255');
pause(0.1);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,[fileName, '.png']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LB008:255');
pause(0.1);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,[fileName, '.png']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LB015:255');
pause(0.1);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,[fileName, '.png']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LA015:255');
pause(0.1);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,[fileName, '.png']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LA000:255');
end