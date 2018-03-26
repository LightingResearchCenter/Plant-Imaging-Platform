function [stepDir,xPts,yPts] = edgeFind(Image,xPos,yPos,searchDim)
% Image is a binary image
% searchDim is either 'x' or 'y'
% positive x direction is from left to right, psoitive y is from top to bottom
% stepDir indicates a step up (1) or step down (-1)

xPts = [];
yPts = [];
stepDirArray = [];
numPts = 30;
[numRows,numColumns] = size(Image);
if searchDim=='x'
    if (numPts>numRows)
        error('Image smaller than number of points to be returned.')
    end
    stepSize = floor(numRows/numPts);
    for loop = 1:numPts
        yedge(loop) = stepSize*loop + yPos;
        xline = Image(stepSize*loop,:);
        xlineDiff = diff(xline);
        temp = find(abs(xlineDiff)==1,1);
        if isempty(temp)
            xedge(loop) = 0;
            yedge(loop) = 0;
            edgeDir(loop) = 0;
        else
            xedge(loop) = temp + xPos;
            edgeDir(loop) = xlineDiff(temp);
        end
        if any(xedge~=0)
            if length(find(xedge~=0))>5
                yPts = [yPts,yedge(xedge~=0)];
                xPts = [xPts,xedge(xedge~=0)];
                stepDirArray = [stepDirArray,edgeDir(xedge~=0)];
            end
        end
    end
    if isempty(stepDirArray)
        stepDir = [];
    else
        stepDir = mode(stepDirArray);
    end
else % searchDim = 'y'
    if (numPts>numColumns)
        error('Image smaller than number of points to be returned.')
    end
    stepSize = floor(numColumns/numPts);
    for loop = 1:numPts
        xedge(loop) = stepSize*loop + xPos;
        yline = Image(:,stepSize*loop);
        ylineDiff = diff(yline);
        temp = find(abs(ylineDiff)==1,1);
        if isempty(temp)
            xedge(loop) = 0;
            yedge(loop) = 0;
            edgeDir(loop) = 0;
        else
            yedge(loop) = temp + yPos;
            edgeDir(loop) = ylineDiff(temp);
        end
        if any(yedge~=0)
            if length(find(yedge~=0))>5
                yPts = [yPts,yedge(yedge~=0)];
                xPts = [xPts,xedge(yedge~=0)];
                stepDirArray = [stepDirArray,edgeDir(yedge~=0)];
            end
        end
    end
    if isempty(stepDirArray)
        stepDir = [];
    else
        stepDir = mode(stepDirArray);
    end
end
