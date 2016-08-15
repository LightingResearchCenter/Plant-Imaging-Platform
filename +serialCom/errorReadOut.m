function [ output ] = errorReadOut( sPort )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
errorMemSize = 32;
output = cell(1,32);  
for i = 1:errorMemSize
    string = ['Z',num2str(i),'E'];
    output{i} = serialCom.writeToSerial(sPort,string);
    len = length(string)+2; % this corrects for headercharaters
    output{i} = serialCom.errorClass(str2num(output{i}(len:end-1))); %#ok<ST2NM>
    
end
output = [output{:}];
if ~(output(1) == 0)
    error(output(1).errorString)
end    

end

