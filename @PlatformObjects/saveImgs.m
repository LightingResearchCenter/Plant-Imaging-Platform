function [ fullPath ] = saveImgs( objects, path)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
serialCom.writeToSerial(objects.Ymotor,'LA000:255');
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,['a',fileName, '.tiff']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LA000:000');
serialCom.writeToSerial(objects.Ymotor,'LB001:200');
pause(0.5);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,['b',fileName, '.tiff']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LB002:200');
pause(0.5);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,['c',fileName, '.tiff']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LB004:200');
pause(0.5);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,['d',fileName, '.tiff']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LB008:200');
pause(0.5);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,['e',fileName, '.tiff']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LB015:200');
pause(0.5);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,['f',fileName, '.tiff']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LA015:200');
pause(0.5);
curImg = objects.CurImg;
fileName = datestr(now,'yyyy_mm_dd-HH_MM_SS');
fullPath = fullfile(path,['g',fileName, '.tiff']);
imwrite(curImg,fullPath);
serialCom.writeToSerial(objects.Ymotor,'LA000:255');
end