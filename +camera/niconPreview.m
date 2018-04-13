function im = niconPreview(figh)
%NICONPREVIEW Summary of this function goes here
%   Detailed explanation goes here
ok = D850_driver_v2('open');
ok = D850_driver_v2('live_on');
pause(0.5); %Wait some time for setting up. Maybe could be less than 500ms.
set(figh, 'CloseRequestFcn',@clean);

ax = axes(figh);
himg = imshow(zeros(424,640),'Border','tight','Parent',ax);
i =0;
while 1
    if isempty(findobj(figh))
        break;
    else
        [ok,im] = D850_driver_v2('live_get');
        [~, masked] = camera.createMask(im);
        set(himg, 'CData', masked);
        drawnow;
    end
    
    i = i+1;
    
end
% imtool(im);
end

function clean(src, callbackData)
try
    D850_driver_v2('live_off');
catch
end
D850_driver_v2('close');
delete(src);
end