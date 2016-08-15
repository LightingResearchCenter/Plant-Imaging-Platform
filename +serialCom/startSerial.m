function [ sPort ] = startSerial(  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
serialInfo = instrhwinfo('serial');
r = instrfind;
[s,v] = listdlg('PromptString','Select Com Port',...
    'SelectionMode','single',...
    'ListString',serialInfo.SerialPorts);
if v == 1
    if ~isempty(r)
        if any(strcmpi(r.port,serialInfo.SerialPorts{s}))
            port = strcmpi(r.port,serialInfo.SerialPorts{s});
            sPort = r(port);
        else
            [s1,v1] = listdlg('PromptString','Which Device is on this port?',...
                'SelectionMode','single',...
                'ListString',{'NanoTec','MSP432'});
            if v1 == 1
                if s1 == 1 % Nanotec
                    
                    sPort = serial(serialInfo.SerialPorts{s},'BaudRate',115200);
                    str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                    if any([str{:}])
                        fopen(sPort);
                        sPort.Status;
                        set(sPort,'Terminator',char(13));
                    else
                        error('Port was not valid, please check to make sure it is available, and not in use');
                    end
                    serialCom.NanotecInit(sPort);
                elseif s1==2 % MSP432
                    sPort = serial(serialInfo.SerialPorts{s},'BaudRate',19200);
                    str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                    if any([str{:}])
                        fopen(sPort);
                        sPort.Status;
                        set(sPort,'Terminator',char(13));
                    else
                        error('Port was not valid, please check to make sure it is available, and not in use');
                    end
                else
                    error('unknown error with device model')
                end
                serialCom.MSP432Init(sPort);
            else
                error('No device was selcted');
            end
        end
    else
        [s1,v1] = listdlg('PromptString','Which Device is on this port?',...
            'SelectionMode','single',...
            'ListString',{'NanoTec','MSP432'});
        if v1 == 1
            if s1 == 1 % Nanotec
                
                sPort = serial(serialInfo.SerialPorts{s},'BaudRate',115200);
                str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                if any([str{:}])
                    fopen(sPort);
                    sPort.Status;
                    set(sPort,'Terminator',char(13));
                else
                    error('Port was not valid, please check to make sure it is available, and not in use');
                end
                serialCom.NanotecInit(sPort);
            elseif s1==2 % MSP432
                
                sPort = serial(serialInfo.SerialPorts{s},'BaudRate',19200);
                str = strfind(serialInfo.AvailableSerialPorts,serialInfo.SerialPorts{s});
                if any([str{:}])
                    fopen(sPort);
                    sPort.Status;
                    set(sPort,'Terminator',char(13));
                else
                    error('Port was not valid, please check to make sure it is available, and not in use');
                end
                serialCom.MSP432Init(sPort);
            else
                error('No device was selcted');
            end
        end
    end
else
    error('No port was Selected');
end
end

