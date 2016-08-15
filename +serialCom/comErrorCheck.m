function comErrorCheck(str)
% COMERRORCHECK  is a check to make sure the motor understood the command
% checks to make sure the motor understood the command that was sent to it 

strloc = strfind(str,'?');
if ~isempty(strloc)
    try
        error('There was an error with the command sent to the motor.\nMotor Returned: %s',str)
    catch ME
        throwAsCaller(ME);
    end 
end


end