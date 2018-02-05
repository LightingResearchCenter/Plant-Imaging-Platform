function [ app,imgTable ] = SearchSystem( app, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
tic
p = inputParser;
validPlatformObject = @(x) isa(x, 'ImagingPlatform');

defaultDirection = 1;
validDirection = [1,-1];
checkDirection = @(x) any(ismember(x,validDirection));
defaultTable = cell2table(cell(0,4),...
    'VariableNames', {'SampleNum', 'FileName', 'XLocation', 'YLocation'});
defaultOutput = fullfile('output',datestr(now,'yyyy_mm_dd-HH_MM_SS'));
addRequired(p,'app',validPlatformObject);
addOptional(p,'imgTable',defaultTable,@istable);
addParameter(p,'direction',defaultDirection,checkDirection);
addParameter(p,'output',defaultOutput,@isdir);
parse(p,app,varargin{:});
imgTable= p.Results.imgTable;
direction = p.Results.direction;
output = p.Results.output;
if ~(7 == exist(output,'dir'))
    mkdir(output)
end
preview(p.Results.app.VidObj);
if p.Results.direction == 1
    app.CurX=(p.Results.app.Cal.LRextents(2)+50); % move all the way to te left
    moveY=(p.Results.app.Cal.TBextents(2)+50); % move all the way to the Top
    app.CurY = moveY;
elseif p.Results.direction == -1
    app.CurX=(p.Results.app.Cal.LRextents(1)-50); % move all the way to the right
    moveY=(p.Results.app.Cal.TBextents(1)-50); % move all the way to the Top
    app.CurY = moveY;
end
outputCom = serialCom.writeToSerial(p.Results.app.Ymotor,'$');
statusInt = str2num(outputCom(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
while (~statusBin(3))
    %% WrITE FUNCTION HERE
    app.CurY = moveY;
    disp(app.CurY)
    [app,imgTable] = searchRow(p.Results.app,'step',floor(p.Results.app.Xstep*1.2),'output',output,'direction',direction,'imgTable',imgTable);
    direction = direction*-1;
    moveY = double(app.CurY + floor(app.Ystep*1.2));
    outputCom = serialCom.writeToSerial(p.Results.app.Ymotor,'$');
    statusInt = str2num(outputCom(5:end)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt,8);
end
serialCom.writeToSerial(p.Results.app.Ymotor,'D');
app.CurY = 0;
app.CurX = 0;
toc
end

