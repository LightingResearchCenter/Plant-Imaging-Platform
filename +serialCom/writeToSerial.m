function output = writeToSerial(sPort,text)
if strcmpi(sPort.Tag,'Pololu')
    fullText = serialCom.str2com(text,'',['',13]);
else
    fullText = serialCom.str2com(text);
end
fprintf(sPort,fullText);

output = fgetl(sPort);
while (sPort.BytesAvailable > 1)
    output = fgetl(sPort);
end
serialCom.comErrorCheck(output)
end