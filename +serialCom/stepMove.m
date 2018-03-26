function [output, posErr] = stepMove(sPort,stepCount)
%STEPCOUNT send command to motor to move by the count specified
%   note d0 = right and negative counts while d1 = left and positive counts
%   output will contain the position return call
%   posErr = 0 if no error, 1 if soft error, 2 if the motor errored at  end

posErr = 0;
output = serialCom.writeToSerial(sPort,'$');
statusInt = str2double(output(5:end));
statusBin = dec2binvec(statusInt,8);
if statusBin(3) 
    warning('StepMove:MotorError','There was a position error from the motor.\n\tResetting motor errors');
    serialCom.writeToSerial(sPort,'D');
end
curLocStr = serialCom.writeToSerial(sPort,'C');
curLoc = str2double(curLocStr(3:end));
if stepCount >0
    serialCom.writeToSerial(sPort,'d1');
    if ~sPort.UserData.calibration
        if sPort.UserData.Upper-sPort.UserData.hystersis <= curLoc+stepCount
            warning('StepMove:LimitSwitch','This movement is too close to the limit Switch, setting at the edge point.');
            stepCount = (sPort.UserData.Upper-sPort.UserData.hystersis) - curLoc;
            posErr = 1;
        end
    end
else
    serialCom.writeToSerial(sPort,'d0');
    if ~sPort.UserData.calibration
        if sPort.UserData.Lower+sPort.UserData.hystersis >= curLoc+stepCount
            warning('StepMove:LimitSwitch','This movement is too close to the limit Switch, setting at the edge point.');
            stepCount = (sPort.UserData.Lower+sPort.UserData.hystersis) - curLoc;
            posErr = 1;
        end
    end
end
if stepCount > 0
    serialCom.writeToSerial(sPort,'d1');
elseif stepCount < 0
    serialCom.writeToSerial(sPort,'d0');
else
    output = serialCom.writeToSerial(sPort,'$');
    return
end
absStepCount = int16(floor(abs(stepCount)));
serialCom.writeToSerial(sPort,['s',num2str(round(absStepCount))]);
serialCom.writeToSerial(sPort,'A');
serialCom.waitTillReady(sPort);
output = serialCom.writeToSerial(sPort,'$');
statusInt = str2double(output(5:end));
while(statusInt<161)
    output = serialCom.writeToSerial(sPort,'$');
    statusInt = str2double(output(5:end));
end
statusBin = dec2binvec(statusInt,8);
if statusBin(3)%TOOO just fix this (return home bounce error)'
    if statusInt>164
        keyboard;
        %this should only happen with the Y and Z Motors
    end
    serialCom.writeToSerial(sPort,'D');
    posErr = 2;
    if stepCount >0
        serialCom.writeToSerial(sPort,'d0');
    else
        serialCom.writeToSerial(sPort,'d1');
    end
    serialCom.writeToSerial(sPort,'s10');
    serialCom.writeToSerial(sPort,'A');
    error('StepMove:MotorError','There was a position error from the motor.\n\tResetting motor errors');
end

end