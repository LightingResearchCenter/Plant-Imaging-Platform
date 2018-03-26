function [ results ] = takeNikonImg( )
%takePicAndSave Summary of this function goes here
%   Detailed explanation goes here

ok = D850_driver_v2('open'); %#ok<*NASGU>
ok = D850_driver_v2('live_on');
var = onCleanup(@clean);
[~,results] = D850_driver_v2('live_get');
end

function clean
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
end
