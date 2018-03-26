% Crop image to disk size and call findHyphae

showGraphics = false;

pathName = 'H:\Cornell March Samples\Day 2\'; % 'H:\FebDay1\';
DIR = dir(pathName);
DIR = DIR(3:end);
if ~exist('featureMatrix','var')
    featureMatrix = [];
    featureTable = [];
    targetMatrix = [];
end
for loop = 110:length(DIR)
    fileName = DIR(loop).name
    leafDisk = imread([pathName,fileName],'tif');
    %[xc,yc,R,BW] = FindDiskCenter50MP(leafDisk,false);
    [xc,yc,R,BW] = FindDiskCenter50MP_Centroid(leafDisk,false);
    [ySize,xSize,~] = size(leafDisk);
    y1 = yc-R;
    if y1<1
        y1=1;
    end
    y2 = yc+R;
    if y2>ySize
        y2=ySize;
    end
    x1 = xc-R;
    if x1<1
        x1=1;
    end
    x2 = xc+R;
    if x2>xSize
        x2=xSize;
    end
    Icrop = leafDisk(y1:y2,x1:x2,3); % blue channel only
    BWcrop = double(BW(y1:y2,x1:x2));
    h = ones(1,50)/50;
    BWcrop = imfilter(BWcrop,h);
    Icrop = uint8(double(Icrop).*BWcrop);
    figure(3)
    imshow(BWcrop,'InitialMagnification','fit');
    %{
    % Break into 4 images
    for loop2 = 1:4
        switch loop2
            case 1
                I = Icrop(R/2:R,R/2:R);
            case 2
                I = Icrop(R:end-R/2,R/2:R);
            case 3
                I = Icrop(R/2:R,R:end-R/2);
            case 4
                I = Icrop(R:end-R/2,R:end-R/2);
        end
    %}
    xDelta = floor((x2-x1)/6);
    yDelta = floor((y2-y1)/6);
    for loop2 = 1:16
        xindex = floor((loop2-1)/4)*xDelta+1;
        yindex = mod((loop2-1),4)*yDelta+1;
        fprintf('(%.1f, %.1f)\n',xindex,yindex);
        I = Icrop(yindex:yindex+yDelta,xindex:xindex+xDelta);
        figure(2)
        imshow(I,'InitialMagnification','fit');
        
        thickness = 7;
        rhoRes = 3; % rho resolution for Hough transform, [pixels]
        thetaRes = 1; % angle resolution for Hough transform, [degrees]
        
        [hyphaeCnt,fMatrix] = findHyphaeVer2ManyAdjLines(I,thickness,rhoRes,thetaRes,showGraphics);
        [~,w] = size(fMatrix);
        disp(['Loop Count = ',num2str(loop,'%d'),' Hyphae count = ',num2str(hyphaeCnt,'%d'),' Total Count = ',...
        num2str(w,'%d')]);
        
        % Assemble NN input and target matricies
        featureMatrix = [featureMatrix,fMatrix];
        %figure(1)
        %pause
        
    end
end
timeStamp = datestr(now,'yyyymmmddHHMM')
%{
fileName = ['featureMatrix',timeStamp];
save(fileName,'featureMatrix')
fileName = ['targetMatrix',timeStamp];
save(fileName,'targetMatrix')
%}


