classdef PlatformObjects
%     PLATFORMOBJECTS stores and initializes all Platform objects needed
%     This will ask the user various questions on how to generate the
%     objects needed to operate the Plant-Pathology Microscope Platform.
%     Note: All recuired tool-boxes must be installed.
%     
%     Required Tool-Boxes:data_acq_toolbox, image_acquisition_toolbox,
%     image_toolbox, instr_control_toolbox, matlab, statistics_toolbox
    
    properties
        Xmotor  % serial pointer for X direction (left:right)
        Ymotor  % serial pointer for Y direction (top:bottom)
        VidObj  % VideoInput handel
        VidSrc
        Cal
        
        
    end
    properties (Dependent)
        Xstep
        Ystep
        CurX    % How far the X motor has moved from home
        CurY    % How far the Y motor has moved from home
        CurImg  % the current image seen by VidObj
    end
    methods (Access = private)
        output = calibration(obj)
    end
    
    methods
        function obj = PlatformObjects(varargin)
            switch nargin
                case 0
                    obj.Xmotor = serialCom.startSerial();
                    obj.Ymotor = serialCom.startSerial();
                    [obj.VidObj,obj.VidSrc] = camera.startCamera();
                    
                case 1
                    if isa(varargin{1},'serial')
                        obj.Xmotor = varargin{1};
                        obj.Ymotor = serialCom.startSerial();
                        obj.VidObj = camera.startCamera();
                    else
                        error('The first input must be a Serial Class Object, and should control the Left/Right Motor');
                    end
                case 2
                    if isa(varargin{1},'serial')
                        if isa(varargin{2},'serial')
                            obj.Xmotor = varargin{1};
                            obj.Ymotor = varargin{2};
                            obj.VidObj = camera.startCamera();
                        else
                            error('The second input must be a Serial Class Object, and should control the Top/Bottom Motor');
                        end
                    else
                        error('The first input must be a Serial Class Object, and should control the Left/Right Motor');
                    end
                case 3
                    if isa(varargin{1},'serial')
                        if isa(varargin{2},'serial')
                            if isa(varargin{3},'videoinput')
                                obj.Xmotor = varargin{1};
                                obj.Ymotor = varargin{2};
                                obj.VidObj = camera.startCamera();
                            else
                                error('The Third input must be a videoinput Class Object, and should control the Top/Bottom Motor');
                            end
                        else
                            error('The second input must be a Serial Class Object, and should control the Top/Bottom Motor');
                        end
                    else
                        error('The first input must be a Serial Class Object, and should control the Left/Right Motor');
                    end
                    
                otherwise
                    error('Too many inputs');
            end
            obj.Cal = calibration(obj);
        end
        
        function CurX = get.CurX(obj)
            curXStr = serialCom.writeToSerial(obj.Xmotor,'C');
            CurX = str2num(curXStr(3:end-1));
        end
        function CurY = get.CurY(obj)
            ii = 0;
            loop = true;
            while loop
                ii = ii + 1;
                if ii > 500
                    loop = false;
                end
                curYStr = serialCom.writeToSerial(obj.Ymotor,'C');
                CurY = str2num(curYStr);
                if ~isempty(CurY)
                    loop = false;
                end
            end
        end
        function obj = set.CurX(obj,newNum)
            if (newNum > obj.Cal.LRextents(1))||(newNum < obj.Cal.LRextents(2))
                error('That Position is ourside of the extents for the current  setup.');
            else
                curXStr = serialCom.writeToSerial(obj.Xmotor,'C');
                Cur = str2num(curXStr(3:end-1));
                if newNum ~= Cur
                    move = newNum - Cur;
                    serialCom.stepMove(obj.Xmotor ,move);
                end
            end
        end
        function obj = set.CurY(obj,newNum)
            curYStr = serialCom.writeToSerial(obj.Ymotor,'C');
            Cur = str2num(curYStr);
            if newNum ~= Cur
                move = newNum - Cur;
                serialCom.stepMove(obj.Ymotor ,move);
            end
            curYStr = serialCom.writeToSerial(obj.Ymotor,'C');
            Cur = str2num(curYStr);
            if abs(newNum - Cur) > 50 
                move = newNum - Cur;
                serialCom.stepMove(obj.Ymotor ,move);
            end
        end
        function CurImg = get.CurImg(obj)
            pause(1);
            CurImg = getsnapshot(obj.VidObj);
        end
        function Xstep = get.Xstep(obj)
            img = obj.CurImg;
            imgSize = size(img);
            Xstep = int32(floor((imgSize(2)*obj.Cal.pix2mm)/(obj.Cal.LRstep2mm/100)));
        end
        function Ystep = get.Ystep(obj)
            img = obj.CurImg;
            imgSize = size(img);
            Ystep = int32(floor(((imgSize(1)*obj.Cal.pix2mm)/(obj.Cal.TBstep2mm/100))*.94));
        end
        function moveHome(obj,str)
            p = inputParser;
            validPlatformObject = @(x) isa(x, 'PlatformObjects');
            validDirection = {'X';'Y'};
            checkDirection = @(x) any(validatestring(x,validDirection));
            addRequired(p,'object',validPlatformObject);
            addRequired(p,'string',checkDirection);
            parse(p,obj,str);
            if strcmpi(p.Results.string, 'X')
                output = serialCom.writeToSerial(p.Results.object.Xmotor,'C');
                dist = str2num(output(3:end));
                serialCom.stepMove(p.Results.object.Xmotor,-dist);
            elseif strcmpi(p.Results.string, 'Y')
                output = serialCom.writeToSerial(p.Results.object.Ymotor,'C');
                dist = str2num(output(3:end));
                serialCom.stepMove(p.Results.object.Ymotor,-dist);
            else
                error('That was not an axis of movement.');
            end
        end
        function posErrorFix(obj, str)
            p = inputParser;
            validPlatformObject = @(x) isa(x, 'PlatformObjects');
            validDirection = {'X';'Y'};
            checkDirection = @(x) any(validatestring(x,validDirection));
            addRequired(p,'object',validPlatformObject);
            addRequired(p,'string',checkDirection);
            parse(p,obj,str);
            if strcmpi(p.Results.string, 'X')
                serialCom.writeToSerial(p.Results.object.Xmotor,'D');
                
            elseif strcmpi(p.Results.string, 'Y')
                serialCom.writeToSerial(p.Results.object.Ymotor,'D');
            else
                error('how did you get here even?');
            end
        end
        function delete(obj)
            delete(obj.Xmotor);
            delete(obj.Ymotor);
            delete(obj.VidObj);
            delete(imaqfind);
            serialCom.endAllSerial;
        end
    end
    
end

