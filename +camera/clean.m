function clean
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
end