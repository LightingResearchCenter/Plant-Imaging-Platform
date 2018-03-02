function [ results ] = takeNikonImg( )
%takePicAndSave Summary of this function goes here
%   Detailed explanation goes here
files = dir();
D850_driver_v1('open');
D850_driver_v1('capture');
D850_driver_v1('close');
filesNew = dir();
files = struct2table(files);
filesNew = struct2table(filesNew);
files(:,'date') = [];
filesNew(:,'date') = [];
files(:,'datenum') = [];
filesNew(:,'datenum') = [];
imgfile = setdiff(filesNew,files,'rows');
count = 1;
while height(imgfile) ~= 1
    filesNew = dir();
    filesNew = struct2table(filesNew);
    filesNew(:,'date') = [];
    filesNew(:,'datenum') = [];
    imgfile = setdiff(filesNew,files,'rows');
    if count == 100
        uialert(app.UIFigure,'timeout while waiting for camera','Timeout Error');
    end
    count = count +1;
end
results = imread(fullfile(imgfile.folder{1},imgfile.name{1}));
delete(fullfile(imgfile.folder{1},imgfile.name{1}))
end

