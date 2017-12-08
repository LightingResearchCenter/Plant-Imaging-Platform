function [forward,backward] = findextens(sPort)

%% check forawrd
serialCom.writeToSerial(sPort,'D');
output = serialCom.writeToSerial(sPort,'$');
statusInt = str2num(output(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
while (~statusBin(3))
    output{1} = serialCom.writeToSerial(sPort,'d1');
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
serialCom.writeToSerial(sPort,'D');
%% check Backward
output = serialCom.writeToSerial(sPort,'$');
statusInt = str2num(output(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt);
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
backwardstr = serialCom.writeToSerial(sPort,'C');
backward = str2num(backwardstr(3:end));
serialCom.writeToSerial(sPort,'D');
end