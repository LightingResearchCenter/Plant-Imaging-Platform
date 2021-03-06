function [obj, pictureTable] = searchRow(obj,varargin)
%% check inputs
p = inputParser;
validPlatformObject = @(x) isa(x, 'PlatformObjects');

defaultDirection = 1;
validDirection = [1,-1];
checkDirection = @(x) any(ismember(x,validDirection));
defaultStep = 100;
defaultTable = cell2table(cell(0,4),...
    'VariableNames', {'SampleNum', 'FileName', 'XLoction', 'YLocation'});
defaultOutput = 'output';
addRequired(p,'object',validPlatformObject);
addOptional(p,'imgTable',defaultTable,@istable);
addParameter(p,'direction',defaultDirection,checkDirection);
addParameter(p,'step',defaultStep,@isinteger);
addParameter(p,'output',defaultOutput,@isdir);
parse(p,obj,varargin{:});
%% run setup
if p.Results.direction == 1
    obj.CurX=(p.Results.object.Cal.LRextents(2)+50); % move all the way to te left
elseif p.Results.direction == -1
    obj.CurX=(p.Results.object.Cal.LRextents(1)-50); % move all the way to the right
end
objects = p.Results.object;
pictureTable = p.Results.imgTable;
%% start moving along row
output = serialCom.writeToSerial(p.Results.object.Xmotor,'$');
statusInt = str2num(output(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
while (~statusBin(3))
    serialCom.stepMove(p.Results.object.Xmotor,p.Results.direction*p.Results.step);
    [TFSample,BWimg]=camera.isSample(p.Results.object.CurImg); 
    if TFSample
        if ~isequal(BWimg,ones(size(BWimg)))
            if ~camera.isEdge(BWimg)
                searchCol = p.Results.object.CurY;
                camera.isSampleCentered(BWimg,p.Results); %%this is the important line your working on 
                [TFSample]=camera.isNewSample(p.Results.object.CurX,p.Results.object.CurY,pictureTable);
                if TFSample
                    fileName = p.Results.object.saveImgs(p.Results.output);
                    newTable = struct('SampleNum',height(pictureTable)+1,...
                        'FileName', fileName,...
                        'XLocation',  p.Results.object.CurX,...
                        'YLocation', p.Results.object.CurY );
%                     pause(.2);
                    newTable = struct2table(newTable);
                    pictureTable = [pictureTable;newTable];
                    clear('newTable');
                    
                end
                objects.CurY = searchCol;
            end
        end
    end
    %
    output = serialCom.writeToSerial(p.Results.object.Xmotor,'$');
    statusInt = str2num(output(5:end)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt);
end
%% compile table and outputs
% insert what to do when a rowsearch is over
serialCom.writeToSerial(p.Results.object.Xmotor,'D');

end