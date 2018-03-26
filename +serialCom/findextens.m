function sPort = findextens(sPort)
sPort.UserData.calibration = 1;
%% check forawrd
absStepCount = 20000;
serialCom.writeToSerial(sPort,'D');
tempOut = serialCom.writeToSerial(sPort,'$');
statusInt = str2num(tempOut(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
serialCom.writeToSerial(sPort,'d0');
serialCom.writeToSerial(sPort,['s',num2str(absStepCount)]);
while (~statusBin(3))
    serialCom.writeToSerial(sPort,'A');
    output = serialCom.writeToSerial(sPort,'$');
    statusInt = str2num(output(5:end)); %#ok<ST2NM>
    while statusInt<161
        output = serialCom.writeToSerial(sPort,'$');
        statusInt = str2num(output(5:end)); %#ok<ST2NM>
    end
    statusBin = dec2binvec(statusInt);
end
serialCom.writeToSerial(sPort,'d1');
serialCom.writeToSerial(sPort,['s',num2str(100)]);
serialCom.writeToSerial(sPort,'A');
forwardstr = serialCom.writeToSerial(sPort,'C');
forward = str2num(forwardstr(3:end));
serialCom.writeToSerial(sPort,'D');
%% check Backward
tempOut = serialCom.writeToSerial(sPort,'$');
statusInt = str2num(tempOut(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt);
serialCom.writeToSerial(sPort,'d1');
serialCom.writeToSerial(sPort,['s',num2str(absStepCount)]);
while (~statusBin(3))
    serialCom.writeToSerial(sPort,'A');
    output = serialCom.writeToSerial(sPort,'$');
    statusInt = str2num(output(5:end)); %#ok<ST2NM>
    while statusInt<161
        output = serialCom.writeToSerial(sPort,'$');
        statusInt = str2num(output(5:end)); %#ok<ST2NM>
    end
    statusBin = dec2binvec(statusInt);
end
serialCom.writeToSerial(sPort,'d0');
serialCom.writeToSerial(sPort,['s',num2str(100)]);
serialCom.writeToSerial(sPort,'A');
backwardstr = serialCom.writeToSerial(sPort,'C');
backward = str2num(backwardstr(3:end));
serialCom.writeToSerial(sPort,'D');
if forward> backward
    sPort.UserData.Upper = forward;
    sPort.UserData.Lower = backward;
    sPort.UserData.hystersis = 50;
else
    sPort.UserData.Upper = backward;
    sPort.UserData.Lower = forward;
    sPort.UserData.hystersis = 50;
end
sPort.UserData.calibration = 0;
end