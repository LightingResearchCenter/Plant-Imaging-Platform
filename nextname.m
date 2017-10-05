function name = nextname(name,sufx)
% Return the next unused filename, incrementing a numbered suffix if required.
%
% (c) 2017 Stephen Cobeldick
%
%%% Syntax:
%  name = nextname(name,sufx)
%
% A file or folder name is supplied as the first input: the name may be
% a relative or absolute path. The second input is a string that will be
% appended to the name, it must contain the starting integer, for example:
% '(0)', '_1', ' v001', '.temp.1000', etc. The integer value is incremented
% to ensure that the returned name is not currently used by a file/folder.
% Leading zeros are taken into account, so that the returned name does have
% the same numeric value as any existing file/folder.
%
% Padding the suffix number with leading zeros indicates the required
% number length, thus allowing for the creation of fixed-width names.
%
% Note: Because of how DIR works names of files must have an extension.
%
%% Examples %%
%
%%% Given a directory containing files 'A1.m', 'A2.m', 'A3.m', and 'A5.m':
%
% nextname('A.m','0')
%  ans = A0.m
%
% nextname('A.m','1')
%  ans = A4.m
%
% nextname('A.m','23')
%  ans = A23.m
%
% nextname('A.m','005')
%  ans = A005.m
%
%% Inputs and Outputs %%
%
%%% Input Arguments:
% name = CharVector, any filename or directory name, absolute or relative.
% sufx = CharVector, the suffix to append, containing exactly one integer.
%
%%% Output Arguments:
% name = CharVector, the input name with numbered suffix, an unused file/folder name.
%
% name = nextname(name,sufx)

%% Input Wrangling %%
%
assert(ischar(name)&&size(name,1)==1,'Input <name> must be a 1xN char array.')
assert(ischar(sufx)&&size(sufx,1)==1,'Input <sufx> must be a 1xN char array.')
tkn = regexp(sufx,'\d+','match');
val = sscanf(sprintf('%s\v',tkn{:}),'%u\v'); % faster than STR2DOUBLE.
assert(numel(val)==1,'The suffix must contain exactly one integer value.')
wid = numel(tkn{1});
%
%% Get Existing Files / Folders %%
%
[pth,fnm,ext] = fileparts(name);
%
% Find files/subfolders on that path:
raw = dir(fullfile(pth,[fnm,regexprep(sufx,'\d+','*'),ext]));
%
% Generate regular expression:
fmt = regexprep(regexptranslate('escape',sufx),'\d+','(\\d+)');
fmt = ['^',regexptranslate('escape',fnm),fmt,regexptranslate('escape',ext),'$'];
%
% Extract numbers from names:
tkn = regexpi({raw.name},fmt,'tokens','once');
tkn = [tkn{:}];
%
%% Identify First Unused Name %%
%
if numel(tkn)
	% For speed these values must be converted before the WHILE loop:
	vec = sscanf(sprintf('%s\v',tkn{:}),'%u\v');  % faster than STR2DOUBLE.
	%
	% Find the first unused name, starting from the provided value:
	while any(val==vec)
		val = val+1;
	end
end
%
name = fullfile(pth,[fnm,regexprep(sufx,'\d+',sprintf('%0*d',wid,val)),ext]);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nextname