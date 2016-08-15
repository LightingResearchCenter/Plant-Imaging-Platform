function TF = isEdge(BWimg)
imgSize = 50;
s.imgLeft = BWimg(:,end-imgSize:end);
s.imgRight = BWimg(:,1:imgSize);
s.imgTop= BWimg(1:imgSize,:);
s.imgBot= BWimg(end-imgSize:end,:);
WhiteLeft = ones(size(s.imgLeft));
WhiteRight = ones(size(s.imgRight));
WhiteBot = ones(size(s.imgBot));
WhiteTop = ones(size(s.imgTop));
%% Check sample Location
sampleLeft = s.imgLeft == WhiteLeft;
sampleRight = s.imgRight == WhiteRight;
sampleTop = s.imgTop == WhiteTop;
sampleBot = s.imgBot == WhiteBot;
TF = false;
if sampleLeft
    TF = true;
elseif sampleRight
    TF = true;
elseif sampleTop
    TF = true;
elseif sampleBot
    TF = true;
end

end