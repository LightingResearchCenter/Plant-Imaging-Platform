function waitTillReady(sPort)
if strcmp(sPort.Tag,'Nanotec')
    output = serialCom.writeToSerial(sPort,'$');
    statusInt = str2num(output(5:end-1)); %#ok<ST2NM>
    statusBin = dec2binvec(statusInt);
    i=0;
    while and((statusBin(1)==0),i<1000)
        output = serialCom.writeToSerial(sPort,'$');
        statusInt = str2num(output(5:end)); %#ok<ST2NM>
        statusBin = dec2binvec(statusInt);
        i=i+1;
        pause(0.1)
        if statusBin(3) == 1
            break
        end
    end
    if i == 1000
        try
            error('there was an error waiting for the device to become ready');
        catch ME
            throwAsCaller(ME);
        end
    end
    pause(.01);
else
%     disp('msp432 was moved and finished');
end
end