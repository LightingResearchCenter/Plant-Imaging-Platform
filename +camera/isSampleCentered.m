function isSampleCentered( BWimg, results,nRun)
%isSampleCentered Summary of this function goes here
%

%% Input Setup
if nargin == 2
    nRun = 0;
else
    nRun = nRun +1;
end

%% check location

Ilabel1 = logical(BWimg);
stat1 = regionprops(Ilabel1,'centroid');
sampleCentroid = [stat1(1).Centroid(1),stat1(1).Centroid(2)];
Ilabel2 = ones(size(BWimg));
stat2 = regionprops(Ilabel2,'centroid');
pictureCentroid = [stat2(1).Centroid(1),stat2(1).Centroid(2)];
deltaX = sampleCentroid(1)-pictureCentroid(1);
deltaY = sampleCentroid(2)-pictureCentroid(2);
Xstep = floor(((deltaX/results.object.Cal.pix2mm)/results.object.Cal.LRstep2mm)/200);
Ystep = floor(((deltaY/results.object.Cal.pix2mm)/results.object.Cal.TBstep2mm)/200);

%% tell motor to move and check new location.
if abs(Xstep) > 80
    results.object.CurX = results.object.CurX - Xstep;
    [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
    if TFSample&& nRun <= 10
        newSample = camera.isNewSample(results.object.CurX,results.object.CurY,results.imgTable);
        if newSample && nRun <= 10
            camera.isSampleCentered( BWimg2, results,nRun);
        end
    end
elseif abs(Ystep) > 80
    results.object.CurY = results.object.CurY - Ystep;
    [TFSample,BWimg2]=camera.isSample(results.object.CurImg);
    if TFSample&& nRun <= 10
        newSample = camera.isNewSample(results.object.CurX,results.object.CurY,results.imgTable);
        if newSample && nRun <= 10
            camera.isSampleCentered( BWimg2, results,nRun);
        end
    end
else
    
end
end
