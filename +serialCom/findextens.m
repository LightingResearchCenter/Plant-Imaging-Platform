function [forward,backward] = findextens(sPort)

%% check forawrd
serialCom.writeToSerial(sPort,'D');
output = serialCom.writeToSerial(sPort,'$');
statusInt = str2num(output(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt,8);
while (~statusBin(3))
    serialCom.stepMove(sPort,20000);
    
    output = serialCom.writeToSerial(sPort,'$');
    statusInt = str2num(output(5:end)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt);
    
end
forwardstr = serialCom.writeToSerial(sPort,'C');
forward = str2num(forwardstr(3:end-1));
serialCom.writeToSerial(sPort,'D');
%% check Backward
output = serialCom.writeToSerial(sPort,'$');
statusInt = str2num(output(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt);
while (~statusBin(3))
    serialCom.stepMove(sPort,-20000);
    output = serialCom.writeToSerial(sPort,'$');
    statusInt = str2num(output(5:end)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt);
end
backwardstr = serialCom.writeToSerial(sPort,'C');
backward = str2num(backwardstr(3:end-1));
serialCom.writeToSerial(sPort,'D');
end