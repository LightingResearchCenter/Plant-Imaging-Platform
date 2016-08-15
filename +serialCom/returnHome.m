function [] = returnHome(sPort,varargin)
if nargin == 1
    [forward,backward] = serialCom.findextens(sPort);
else
    if varargin{1}>0
        forward = varargin{1};
        backward = varargin{2};
    else
        forward = varargin{2};
        backward = varargin{1};
    end
end
if abs(abs(forward)-abs(backward))>= 20 %20 allows for differences in limit switches
    warning('The extents that are being used were not centered on the home point');
end
centerPos = -((ceil(((abs(forward)+abs(backward))/2)))- forward);
output{1} = serialCom.writeToSerial(sPort,'C');
serialCom.comErrorCheck(output{1});
currLocation = str2num(output{1}(3:end));
serialCom.stepMove(sPort,(-1*currLocation));
pause(.1);
serialCom.stepMove(sPort,centerPos);
serialCom.writeToSerial(sPort,'D0');
end