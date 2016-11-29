function [ objects,imgTable ] = SearchSystem( obj, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
tic
p = inputParser;
validPlatformObject = @(x) isa(x, 'PlatformObjects');

defaultDirection = 1;
validDirection = [1,-1];
checkDirection = @(x) any(ismember(x,validDirection));
defaultTable = cell2table(cell(0,4),...
    'VariableNames', {'SampleNum', 'FileName', 'XLoction', 'YLocation'});
defaultOutput = 'output';
addRequired(p,'objects',validPlatformObject);
addOptional(p,'imgTable',defaultTable,@istable);
addParameter(p,'direction',defaultDirection,checkDirection);
addParameter(p,'output',defaultOutput,@isdir);
parse(p,obj,varargin{:});
imgTable= p.Results.imgTable;
direction = p.Results.direction;
output = p.Results.output;
preview(p.Results.objects.VidObj);
if p.Results.direction == 1
    obj.CurX=(p.Results.objects.Cal.LRextents(2)+50); % move all the way to te left
    moveY=(p.Results.objects.Cal.TBextents(2)+50); % move all the way to the Top
    obj.CurY = moveY;
elseif p.Results.direction == -1
    obj.CurX=(p.Results.objects.Cal.LRextents(1)-50); % move all the way to the right
    moveY=(p.Results.objects.Cal.TBextents(1)-50); % move all the way to To[
    obj.CurY = moveY;
end
outputCom = serialCom.writeToSerial(p.Results.objects.Ymotor,'$');
statusInt = str2num(outputCom(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
while (~statusBin(3))
    %% WrITE FUNCTION HERE
    obj.CurY = moveY;
    disp(obj.CurY)
    [objects,imgTable] = searchRow(p.Results.objects,'step',floor(p.Results.objects.Xstep*1.5),'output',output,'direction',direction,'imgTable',imgTable);
    direction = direction*-1;
    moveY = double(obj.CurY + floor(obj.Ystep*1.5));
    outputCom = serialCom.writeToSerial(p.Results.objects.Ymotor,'$');
    statusInt = str2num(outputCom(5:end)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt,8);
end
serialCom.writeToSerial(p.Results.objects.Ymotor,'D');
obj.CurY = 0;
obj.CurX = 0;
toc
end

