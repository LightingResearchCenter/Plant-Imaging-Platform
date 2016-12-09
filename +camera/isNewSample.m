function [ newSampleTF ] = isNewSample( Xpos, Ypos, pictureTable )
%ISNEWSAMPLE Summary of this function goes here
%   Detailed explanation goes here
knownPosition = table(pictureTable.XLocation,pictureTable.YLocation,'VariableNames',{'XLocation','YLocation'});
newPosition = table(Xpos,Ypos,'VariableNames',{'XLocation','YLocation'});
if isempty(table2array(knownPosition))
    newSampleTF = true;
else
    newSampleTF = ~ismembertol(table2array(newPosition), table2array(knownPosition),150, 'DataScale', 1,'ByRows',true);
end
% if true this is a new Sample keep running the program
% otherwise it is a old sample skip this sample

end
