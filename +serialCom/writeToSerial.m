function output = writeToSerial(sPort,text)
if strcmpi(sPort.Tag,'Pololu')
    fullText = serialCom.str2com(text,'',['',13]);
else
    fullText = serialCom.str2com(text);
end
fwrite(sPort,fullText);
if strcmpi(sPort.Tag,'MSP432')
    while (sPort.BytesAvailable < 1)
        %         pause(0.5)
    end
end
output = fscanf(sPort);
if strcmpi(sPort.Tag,'MSP432')
    while sPort.BytesAvailable > 1
        output = [output,fscanf(sPort)];
    end
end
serialCom.comErrorCheck(output)
end