function [ status ] = statusReader( sPort )
% STATUSREADER asks the comport for a status and interperates the result
status = struct('positionMode',     [],...
                'travel',           [],...
                'accelRamp',        [],...
                'decelRamp',        [],...
                'direction',        []);
output = serialCom.writeToSerial(sPort,'Z|');
[startIndex,endIndex] = regexpi(output,'p\+[\d]+');
status.positionMode = str2num(output(startIndex+2:endIndex));
[startIndex,endIndex] = regexpi(output,'s\+[\d]+');
status.travel = str2num(output(startIndex+2:endIndex));
[startIndex,endIndex] = regexpi(output,'d\+[\d]+');
status.direction = str2num(output(startIndex+2:endIndex));
output = serialCom.writeToSerial(sPort,':accel');
[startIndex,endIndex] = regexpi(output,':accel\+[\d]+');
status.accelRamp = str2num(output(startIndex+7:endIndex))/1000;
output = serialCom.writeToSerial(sPort,':decel');
[startIndex,endIndex] = regexpi(output,':decel[\+\-][\d]+');
status.decelRamp = str2num(output(startIndex+7:endIndex))/1000;
if status.decelRamp == 0 
    status.decelRamp = status.accelRamp;
end
end

