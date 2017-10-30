function output = writeToSerial(sPort,text)
if strcmpi(sPort.Tag,'Pololu')
    fullText = serialCom.str2com(text,'',['',13]);
else
    fullText = serialCom.str2com(text);
end
fwrite(sPort,fullText);
if strcmpi(sPort.Tag,'MSP432')
    i = 0;
    maxTime = 25000;
    while (sPort.BytesAvailable < 1)&&i<maxTime
        %         pause(0.5)
        i = i+1;
        drawnow;
    end
    if i == maxTime
        error("timeout elapsed");
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