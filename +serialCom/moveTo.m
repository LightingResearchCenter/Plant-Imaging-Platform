function  moveTo(sPort,loc)
%MOVETO Summary of this function goes here
%   Detailed explanation goes here

forwardstr = serialCom.writeToSerial(sPort,'C');
Cur = str2double(forwardstr(3:end));
i =0 ;
while (loc ~= Cur) && i <10
    move = loc - Cur;
    [~, posErr] =serialCom.stepMove(sPort ,move);
    if posErr == 1
        break
    end
    forwardstr = serialCom.writeToSerial(sPort,'C');
    Cur = str2double(forwardstr(3:end));
    i = i+1;
end
end

