function [vid,src] = startCamera()

cameraInfo = imaqhwinfo;
[s,v] = listdlg('PromptString','Select Camera Family',...
    'SelectionMode','single',...
    'ListString',cameraInfo.InstalledAdaptors);
if v == 1
    cameraFamily =cameraInfo.InstalledAdaptors{s};
    devInfo = imaqhwinfo(cameraFamily);
    
else
    error('no camera was selected');
end
if length(devInfo.DeviceIDs) ~= 1
    error('There is more than one camera connected to the computer');
end

[s,v] = listdlg('PromptString','Select Video Format',...
    'SelectionMode','single',...
    'ListString',devInfo.DeviceInfo.SupportedFormats);
if v == 1
    format = devInfo.DeviceInfo.SupportedFormats{s};
else
    error('no format was selected');
end
vid = videoinput(cameraFamily,1,format);
if strcmpi(cameraFamily,'pointgrey')
    src = getselectedsource(vid);
    vid.FramesPerTrigger = 1;
    src.WhiteBalanceRBMode = 'Manual';
    src.WhiteBalanceRB = [707 719];
    src.Saturation = 175;
    %     vid.ROIPosition = [124 124 976 774];
    src.GainMode  = 'Manual';
    src.Gain = 7;
    src.ShutterMode = 'Manual';
    src.Shutter = 100;
    src.FrameRatePercentageMode = 'Auto';
    triggerconfig(vid, 'manual');
    
end
end