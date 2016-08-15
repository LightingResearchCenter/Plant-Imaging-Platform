function cal = calibration(objects)
cal = struct(  'pix2mm',    [],...
    'LRstep2mm',    [],...
    'LRextents',    [],...
    'TBstep2mm',    []);
%% LR direction
h = preview(objects.VidObj);
message = sprintf('Please Place the Ruler inside the preview window.\n When ready click Ok');
reply = questdlg(message, 'Place Ruler', 'OK', 'Cancel', 'OK');
if strcmpi(reply, 'cancel')
    % User said No, so exit.
    return;
end
pause(0.1)
img = objects.CurImg;
imshow(img);


message = sprintf('Please draw a line that is 1 CM in length along the Left/Right Direction.\n When finished double click the line.');
reply = questdlg(message, 'Draw Line', 'OK', 'Cancel', 'OK');
h = imline;
position = wait(h);
cal.pix2mm = 10/pdist(position); 
serialCom.stepMove(objects.Xmotor,100);
pause(1);
img2 = objects.CurImg;
[x1,y1]= getpts();

imshow(img2);
[x2,y2] = getpts();
cal.LRstep2mm = pdist([x1,y1;x2,y2])*cal.pix2mm; 
serialCom.stepMove(objects.Xmotor,-100);
close(gcf);
%% TB Direction 
h = preview(objects.VidObj);
message = sprintf('Please Place the Ruler inside the preview window.\n When ready click Ok');
reply = questdlg(message, 'Place Ruler', 'OK', 'Cancel', 'OK');
if strcmpi(reply, 'cancel')
    % User said No, so exit.
    return;
end
pause(0.1)
img = objects.CurImg;
imshow(img);

message = sprintf('Please select a point in the Top/Bottom Direction.\n When finished double click the line.');
reply = questdlg(message, 'select point', 'OK', 'Cancel', 'OK');

serialCom.stepMove(objects.Ymotor,100);
pause(1);
img2 = objects.CurImg;
[x1,y1]= getpts();

imshow(img2);
[x2,y2] = getpts();
cal.TBstep2mm = pdist([x1,y1;x2,y2])*cal.pix2mm; 
serialCom.stepMove(objects.Ymotor,-100);
close(gcf);
%% get LR extents
[forward, backward] = serialCom.findextens(objects.Xmotor);
cal.LRextents = [forward, backward];
serialCom.returnHome(objects.Xmotor, cal.LRextents(1),cal.LRextents(2));
message = sprintf('Place the tray on the platfrom and focus the image.\n Then Press OK.');
reply = questdlg(message, 'Focus', 'OK', 'Cancel', 'OK');
closepreview;
end