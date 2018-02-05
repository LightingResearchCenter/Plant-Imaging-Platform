function [] = setExtentPoint(xPort,yPort)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
absStepCount = 20000;
serialCom.writeToSerial(xPort,'D');
tempOut = serialCom.writeToSerial(xPort,'$');
statusInt = str2num(tempOut(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
while (~statusBin(3))
    output{1} = serialCom.writeToSerial(xPort,'d0');
    serialCom.comErrorCheck(output{1});
    output{2} = serialCom.writeToSerial(xPort,['s',num2str(absStepCount)]);
    serialCom.comErrorCheck(output{2});
    output{3} = serialCom.writeToSerial(xPort,'A');
    serialCom.comErrorCheck(output{3});
    output{4} = serialCom.writeToSerial(xPort,'$');
    statusInt = str2num(output{4}(5:end)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt);
    
end
forwardstr = serialCom.writeToSerial(xPort,'C');
forward = str2num(forwardstr(3:end));
serialCom.writeToSerial(xPort,'D0');
forwardstr = serialCom.writeToSerial(xPort,'C');
forward = str2num(forwardstr(3:end));
disp(forward);


absStepCount = 20000;
serialCom.writeToSerial(yPort,'D');
tempOut = serialCom.writeToSerial(yPort,'$');
statusInt = str2num(tempOut(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
while (~statusBin(3))
    output{1} = serialCom.writeToSerial(yPort,'d0');
    serialCom.comErrorCheck(output{1});
    output{2} = serialCom.writeToSerial(yPort,['s',num2str(absStepCount)]);
    serialCom.comErrorCheck(output{2});
    output{3} = serialCom.writeToSerial(yPort,'A');
    serialCom.comErrorCheck(output{3});
    output{4} = serialCom.writeToSerial(yPort,'$');
    statusInt = str2num(output{4}(5:end)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt);
    
end
forwardstr = serialCom.writeToSerial(yPort,'C');
forward = str2num(forwardstr(3:end));
serialCom.writeToSerial(yPort,'D0');
forwardstr = serialCom.writeToSerial(yPort,'C');
forward = str2num(forwardstr(3:end));
disp(forward);

end

