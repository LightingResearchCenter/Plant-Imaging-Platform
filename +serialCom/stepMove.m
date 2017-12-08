function [output] = stepMove(sPort,stepCount)
%STEPCOUNT send command to motor to move by the count specified
%   note d0 = right and negative counts while d1 = left and positive counts
%   output(end) will contain the position return call
output{4} = serialCom.writeToSerial(sPort,'$');
statusInt = str2double(output{4}(5:end));
statusBin = dec2binvec(statusInt,8);
if statusBin(3)
    warning(sprintf('There was a position error from the motor.\n\tResetting motor errors'));
    output{5} = serialCom.writeToSerial(sPort,'D');
end

if stepCount >0
    output{1} = serialCom.writeToSerial(sPort,'d1');
    serialCom.comErrorCheck(output{1});
else
    output{1} = serialCom.writeToSerial(sPort,'d0');
    serialCom.comErrorCheck(output{1});
end

absStepCount = int16(floor(abs(stepCount)));
output{2} = serialCom.writeToSerial(sPort,['s',num2str(absStepCount)]);
serialCom.comErrorCheck(output{2});
output{3} = serialCom.writeToSerial(sPort,'A');
serialCom.comErrorCheck(output{3});
output{4} = serialCom.writeToSerial(sPort,'$');
statusInt = str2double(output{4}(5:end));
statusBin = dec2binvec(statusInt,8);
if statusBin(3)
    output{5} = serialCom.writeToSerial(sPort,'D');
end

serialCom.waitTillReady(sPort);
end