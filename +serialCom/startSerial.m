function [ sPort ] = startSerial(  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
serialInfo = instrhwinfo('serial');
r = instrfind;
[s,v] = listdlg('PromptString','Select Com Port',...
    'SelectionMode','single',...
    'ListString',seriallist);
if v == 1
    if ~isempty(r)
        if any(strcmpi(r.port,serialInfo.SerialPorts{s}))
            port = strcmpi(r.port,serialInfo.SerialPorts{s});
            sPort = r(port);
        else
            [s1,v1] = listdlg('PromptString','Which Device is on this port?',...
                'SelectionMode','single',...
                'ListString',{'NanoTec','MSP432','Pololu'});
            if v1 == 1
                if s1 == 1 % Nanotec
                    sPort = serial(serialInfo.SerialPorts{s},'BaudRate',115200);
                    str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                    if any([str{:}])
                        fopen(sPort);
                        sPort.Status;
                        set(sPort,'Terminator','CR');
                        serialCom.NanotecInit(sPort);
                    else
                        error('SerialCom:StartSerial:nanotecPortUnavailable','Port was not valid, please check to make sure it is available, and not in use');
                    end
                elseif s1==2 % MSP432
                    sPort = serial(serialInfo.SerialPorts{s},'BaudRate',19200);
                    str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                    if any([str{:}])
                        fopen(sPort);
                        sPort.Status;
                        set(sPort,'Terminator','CR');
                        serialCom.MSP432Init(sPort);
                    else
                        error('SerialCom:StartSerial:msp432PortUnavailable','Port was not valid, please check to make sure it is available, and not in use');
                    end
                elseif s1 == 3 %Pololu
                    sPort = serial(serialInfo.SerialPorts{s},'BaudRate',9600);
                    str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                    if any([str{:}])
                        fopen(sPort);
                        sPort.Status;
                        set(sPort,'Terminator',char(13));
                        sPort.Tag = 'Pololu';
                    else
                        error('SerialCom:StartSerial:pololuPortUnavailable','Port was not valid, please check to make sure it is available, and not in use');
                    end
                else
                    error('SerialCom:StartSerial:deviceDialogUnknown','unknown error with device model')
                end
                
            else
                error('SerialCom:StartSerial:noDeviceSelect','No device was selcted');
            end
        end
    else
        [s1,v1] = listdlg('PromptString','Which Device is on this port?',...
            'SelectionMode','single',...
            'ListString',{'NanoTec','MSP432','Pololu'});
        if v1 == 1
            if s1 == 1 % Nanotec
                
                sPort = serial(serialInfo.SerialPorts{s},'BaudRate',115200);
                str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                if any([str{:}])
                    fopen(sPort);
                    sPort.Status;
                    set(sPort,'Terminator',char(13));
                    serialCom.NanotecInit(sPort);
                else
                    error('SerialCom:StartSerial:nanotecPortUnavailable','Port was not valid, please check to make sure it is available, and not in use');
                end
            elseif s1==2 % MSP432
                
                sPort = serial(serialInfo.SerialPorts{s},'BaudRate',19200);
                str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                if any([str{:}])
                    fopen(sPort);
                    sPort.RecordDetail = 'verbose';
                    sPort.RecordName = 'MySerialFile.txt';
                    record(sPort,'on')
                    sPort.Status;
                    set(sPort,'Terminator',char(13));
                    serialCom.MSP432Init(sPort);
                else
                    error('SerialCom:StartSerial:msp432PortUnavailable','Port was not valid, please check to make sure it is available, and not in use');
                end
                
            elseif s1 == 3 %Pololu
                sPort = serial(serialInfo.SerialPorts{s},'BaudRate',9600);
                str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                if any([str{:}])
                    fopen(sPort);
                    sPort.Status;
                    set(sPort,'Terminator',char(13));
                    sPort.Tag = 'Pololu';
                else
                    error('SerialCom:StartSerial:pololuPortUnavailable','Port was not valid, please check to make sure it is available, and not in use');
                end
            else
                error('SerialCom:StartSerial:deviceDialogUnknown','unknown error with device model');
            end
        else
            error('SerialCom:StartSerial:noDeviceSelect','No device was selcted');
        end
    end
else
    error('SerialCom:StartSerial:noPortSelect','No port was Selected');
end


end

