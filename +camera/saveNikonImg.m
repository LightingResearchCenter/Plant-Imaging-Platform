function [ results ] = saveNikonImg(path)
%takePicAndSave Summary of this function goes here
%   Detailed explanation goes here

if exist(path,'file') ~= 2
    D850_driver_v2('open');
    var = onCleanup(@clean);
    path = regexprep(path,'\\','\\\\');
    [results] = D850_driver_v2('capture_file',path);
else
    
end
end
function clean
D850_driver_v2('close');
end