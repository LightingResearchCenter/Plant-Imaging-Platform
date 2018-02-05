function [outputArg1,outputArg2] = moveTo(sPort,loc)
%MOVETO Summary of this function goes here
%   Detailed explanation goes here

forwardstr = serialCom.writeToSerial(sPort,'C');
Cur = str2double(forwardstr(3:end));
if loc ~= Cur
    move = loc - Cur;
    serialCom.stepMove(sPort ,move);
end
end

