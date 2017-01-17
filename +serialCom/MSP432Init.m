function MSP432Init(sPort)
sPort.Tag = 'MSP432';
serialCom.writeToSerial(sPort,'LA000:255');
end