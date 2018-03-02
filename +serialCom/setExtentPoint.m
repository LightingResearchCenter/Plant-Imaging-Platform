function forward = setExtentPoint(sPort)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
absStepCount = 20000;
serialCom.writeToSerial(sPort,'D');
tempOut = serialCom.writeToSerial(sPort,'$');
statusInt = str2num(tempOut(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
while (~statusBin(3))
    output{1} = serialCom.writeToSerial(sPort,'d0');
    serialCom.comErrorCheck(output{1});
    output{2} = serialCom.writeToSerial(sPort,['s',num2str(absStepCount)]);
    serialCom.comErrorCheck(output{2});
    output{3} = serialCom.writeToSerial(sPort,'A');
    serialCom.comErrorCheck(output{3});
    output{4} = serialCom.writeToSerial(sPort,'$');
    statusInt = str2num(output{4}(5:end)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt);
    
end
forwardstr = serialCom.writeToSerial(sPort,'C');
forward = str2num(forwardstr(3:end));
serialCom.writeToSerial(sPort,'D0');
forwardstr = serialCom.writeToSerial(sPort,'C');
forward = str2num(forwardstr(3:end));



end

