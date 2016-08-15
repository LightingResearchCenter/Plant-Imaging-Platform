function [output] = stepMove(sPort,stepCount)
%STEPCOUNT send command to motor to move by the count specified
%   note d0 = right and negative counts while d1 = left and positive counts
%   output(end) will contain the position return call
if strcmpi(sPort.Tag,'Nanotec')
    if stepCount >0
        output{1} = serialCom.writeToSerial(sPort,'d1');
        serialCom.comErrorCheck(output{1});
    else
        output{1} = serialCom.writeToSerial(sPort,'d0');
        serialCom.comErrorCheck(output{1});
    end
else
    if stepCount <0
        output{1} = serialCom.writeToSerial(sPort,'d1');
        serialCom.comErrorCheck(output{1});
    else
        output{1} = serialCom.writeToSerial(sPort,'d0');
        serialCom.comErrorCheck(output{1});
    end
    
end
absStepCount = int16(floor(abs(stepCount)));
output{2} = serialCom.writeToSerial(sPort,['s',num2str(absStepCount)]);
serialCom.comErrorCheck(output{2});
output{3} = serialCom.writeToSerial(sPort,'A');
serialCom.comErrorCheck(output{3});
serialCom.waitTillReady(sPort);
end