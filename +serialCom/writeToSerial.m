function output = writeToSerial(sPort,text)
fullText = serialCom.str2com(text);
fwrite(sPort,fullText);
if strcmpi(sPort.Tag,'MSP432')
%     while (sPort.BytesAvailable < 1)
%         pause(0.5)
%     end
end
output = fscanf(sPort);
if strcmpi(sPort.Tag,'MSP432')
    while sPort.BytesAvailable > 1
       output = fscanf(sPort);
    end
end
serialCom.comErrorCheck(output)
end