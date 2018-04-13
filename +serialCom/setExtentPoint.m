function [newExtent,oldExtent] = setExtentPoint(sPort)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
absStepCount = 20000;
serialCom.writeToSerial(sPort,'D0');
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
serialCom.writeToSerial(sPort,'s150');
serialCom.writeToSerial(sPort,'A');
forwardstr = serialCom.writeToSerial(sPort,'C');
oldExtent = str2num(forwardstr(3:end));
serialCom.writeToSerial(sPort,'D0');
forwardstr = serialCom.writeToSerial(sPort,'C');
newExtent = str2num(forwardstr(3:end));
%Move farther away from the switch
serialCom.writeToSerial(sPort,'d1');
serialCom.writeToSerial(sPort,'s200');
serialCom.writeToSerial(sPort,'A');
end

