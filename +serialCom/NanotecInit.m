function output = NanotecInit(sPort)
%% limit switch behavior check
sPort.Tag = 'Nanotec';
serialCom.writeToSerial(sPort,'$');
output = serialCom.writeToSerial(sPort,'l+5154'); %tells the motor to rev. at limit
serialCom.writeToSerial(sPort,'D');
serialCom.writeToSerial(sPort,'C');
output = {output,serialCom.writeToSerial(sPort,'h+17235968')};%bitMask for inputs
output = {output,serialCom.writeToSerial(sPort,':port_in_a7')};%Limit Switch
output = {output,serialCom.writeToSerial(sPort,':port_in_b0')};%user Defined/homeswitch
output = {output,serialCom.writeToSerial(sPort,':port_in_c7')};%Limit Switch
serialCom.writeToSerial(sPort,'D');
serialCom.writeToSerial(sPort,'C');
end