function output = writeToSerial(sPort,text)
if strcmpi(sPort.Tag,'Pololu')
    fullText = serialCom.str2com(text,'',['',13]);
else
    fullText = serialCom.str2com(text);
end
fwrite(sPort,fullText);
i = 0;
maxTime = 25000;
% while (sPort.BytesAvailable < 1)&&i<maxTime
%     i = i+1;
%     drawnow;
% end
% if i == maxTime
%     error("timeout elapsed");
% end
output = fgetl(sPort);
% serialCom.comErrorCheck(output)
end