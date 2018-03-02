function im = niconPreview(figh)
%NICONPREVIEW Summary of this function goes here
%   Detailed explanation goes here
ok = D850_driver_v1('open');
ok = D850_driver_v1('live_on');
pause(0.5); %Wait some time for setting up. Maybe could be less than 500ms.
set(figh, 'CloseRequestFcn',@clean);
%ok = D850_driver_v1('capture');
ax = axes(figh);
himg = imshow(zeros(424,640),'Border','tight','Parent',ax);
while 1
    if isempty(findobj(figh))
        break;
    else
        im = D850_driver_v1('live_get');
        set(himg, 'CData', im);
        drawnow;
    end
end
end

function clean(src, callbackData)
try
    D850_driver_v1('live_off');
catch
end
D850_driver_v1('close');
delete(src);
end