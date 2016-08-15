function [] = endAllSerial()
delete(instrfindall)

if ~isempty(instrfindall)
    error('an unexpected error occured while closing all serial ports');
end

end