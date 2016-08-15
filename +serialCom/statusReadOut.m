function out = statusReadOut( sPort , varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
output = serialCom.writeToSerial(sPort,'$');
statusInt = str2num(output(5:end)); %#ok<ST2NM>
statusBin = dec2binvec(statusInt);
%% is the controller ready?
if statusBin(1)
    disp('Motor is Ready');
else
    if nargin == 1
        disp('Motor is not Ready');
    elseif nargin == 2
        disp('The Motor still is notn ready, Resetting the motor');
        newoutput = serialCom.writeToSerial(sPort,'~');
        out=serialCom.statusReadOut(sPort,1);
    end
end
%% Where is the motor?
if statusBin(2)
    disp('Motor is at zero Position');
else
    output = serialCom.writeToSerial(sPort,'C');
    disp(['Motor is position ',output(3:end)]);
end
%% is there a postion error
if statusBin(3)
    if nargin == 1
        disp('There was a position error, Resetting the motor');
        newoutput = serialCom.writeToSerial(sPort,'D');
        out = serialCom.statusReadOut(sPort,0);
    elseif nargin == 2
        disp('There was a position error, Resetting the motor');
        newoutput = serialCom.writeToSerial(sPort,'D');
        out= serialCom.statusReadOut(sPort,0);
    end
else
    disp('The motor is all set');
    out =1;
end
end

