function output = writeToSerial(sPort,text)
fullText = serialCom.str2com(text);
fwrite(sPort,fullText);
if strcmpi(sPort.Tag,'MSP432')
    while (sPort.BytesAvailable < 1)
    end
end
output = fscanf(sPort);
serialCom.comErrorCheck(output)
end