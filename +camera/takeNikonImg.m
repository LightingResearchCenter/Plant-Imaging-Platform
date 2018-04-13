function [ results ] = takeNikonImg( )
%takePicAndSave Summary of this function goes here
%   Detailed explanation goes here

ok = D850_driver_v2('open'); %#ok<*NASGU>

var = onCleanup(@clean);
[~,results] = D850_driver_v2('capture_mem');
end

function clean
D850_driver_v2('close');
end
