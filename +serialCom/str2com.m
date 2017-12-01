function [output] = str2com(inputstr,varargin)
   
if isempty(varargin)
    header = '#1';
    tail = ['',13];
else
    if length(varargin)==2
         header = varargin{1};
        tail = varargin{2};
    elseif length(varargin)==1
        error('Not enough input arguments');
    else
        error('Too many input arguments');
    end
end

output =[header,inputstr,tail];

end