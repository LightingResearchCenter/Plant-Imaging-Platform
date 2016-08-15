function output = NanotecInit(sPort)
%% limit switch behavior check
sPort.Tag = 'Nanotec';
serialCom.writeToSerial(sPort,'$');
output = serialCom.writeToSerial(sPort,'l+5154'); %tells the motor to rev. at limit

output = {output,serialCom.writeToSerial(sPort,'h+17235968')};%bitMaskfor inputs
output = {output,serialCom.writeToSerial(sPort,':port_in_a7')};%Limit Switch
output = {output,serialCom.writeToSerial(sPort,':port_in_b0')};%user Defined/homeswitch
output = {output,serialCom.writeToSerial(sPort,':port_in_c7')};%Limit Switch

end