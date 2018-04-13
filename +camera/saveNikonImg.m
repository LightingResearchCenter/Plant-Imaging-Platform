function [ results ] = saveNikonImg(path,closeCamera)
%takePicAndSave Summary of this function goes here
%   Detailed explanation goes here
if nargin == 1
    closeCamera = true;
end
if exist(path,'file') ~= 2
    if closeCamera
        D850_driver_v2('open');
        var = onCleanup(@clean);
    end
    path = regexprep(path,'\\','\\\\');
    [results] = D850_driver_v2('capture_file',path);
else
    
end
end
function clean
D850_driver_v2('close');
end