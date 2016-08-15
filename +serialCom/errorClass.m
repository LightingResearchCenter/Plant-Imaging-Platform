classdef errorClass
    %ERRORCLASS Helps to define what the error codes from the motor means
    %   Detailed explanation goes here
    
    properties
        errorNum
    end
    properties (Dependent = true)
        errorString
    end
    methods
        function eC = errorClass(var)
            if isnumeric(var)
                eC.errorNum = var;
            end
            
        end
        function eC = set.errorNum(eC,num)
            eC.errorNum = num;
        end
        function value = get.errorString(obj)
            switch obj.errorNum
                case 0
                    value = 'NOERROR';
                case hex2dec('01')
                    value = 'LOWVOLTAGE';
                case hex2dec('02')
                    value = 'TEMP';
                case hex2dec('04')
                    value = 'TMC';
                case hex2dec('08')
                    value = 'EE';
                case hex2dec('10')
                    value = 'QEI';
                case hex2dec('20')
                    value = 'INTERNAL';
                case hex2dec('80')
                    value = 'DRIVER';
                otherwise
                    msgID = 'serialCom:errorClass:UnknownError';
                    msgtext = 'Motor returnd an unknown error message';
                    ME = MException(msgID,msgtext);
                    throwAsCaller(ME);
            end
        end
        function disp(obj)
            fprintf(1,'motor error: %s\n',obj.errorString);
        end
        function value = eq(obj,b)
            if isnumeric(b)
                value = eq(obj.errorNum,b); 
            else 
                value = eq(obj.errorNum,b.errorNum);
            end
        end
    end
end

