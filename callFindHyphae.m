% Script for calling findHyphaeVer1() and collecting results
clear
clc

thickness = [7]; % Fiber thickness in pixels
rhoRes = 3; % rho resolution for Hough transform, [pixels]
thetaRes = 1; % angle resolution for Hough transform, [degrees]
%{
pathNameList = {'\\ROOT\dropbox\Machirouf_Koli\11-9-17 cornell samples\',... % Hyphae
    '\\ROOT\dropbox\Machirouf_Koli\11-8-17 Grape-Cornell Samples\Focused\'}; % No hyphae
fileNameList = {'Plate1 - I202C1.tif',...  % Hyphae
    'ChardO3_2017-11-08-171131-0000(C).tif'}; % No hyphae
%}
%

for k = 6:10
pathName = sprintf(char("E:\\Users\\plummt\\Documents\\MATLAB\\Plant-Imaging-Platform\\images\\Cornell Samples\\11-%d-17 Grape-Cornell Samples\\**\\*.tif"),k);
DIR = dir(pathName);
    if ~isfile('Dir_%d.mat')
        save(sprintf('Dir_%d.mat',k-5),'DIR','-mat')
    else
        save(sprintf('Dir_%d.mat',k-5),'DIR','-mat','-append');
    end
for loop =  1:length(DIR) %length(fileNameList)
    pathFileName = fullfile(DIR(loop).folder,DIR(loop).name);
    %pathFileName = [pathNameList{loop},fileNameList{loop}];
    leafImage = imread(pathFileName);
    leafImage = leafImage(:,:,3); % Blue channel
    hyphaeCnt(k-5,loop) = findHyphaeVer1(leafImage,thickness,rhoRes,thetaRes,false, false);
    disp(['Loop Count = ',num2str(loop,'%d'),' Hyphae count = ',num2str(hyphaeCnt(loop),'%d')]);
%     autoArrangeFigures;
%     drawnow;
    %pause
    if ~isfile('hyphaeCnt.mat')
        save('hyphaeCnt.mat','hyphaeCnt','-mat')
    else
        save('hyphaeCnt.mat','hyphaeCnt','-mat','-append');
    end
%     equlizeCount(k-5,loop) = findHyphaeVer1(leafImage,thickness,rhoRes,thetaRes,false, true);
%     disp(['Loop Count = ',num2str(loop,'%d'),' Hyphae count = ',num2str(hyphaeCnt(loop),'%d')]);
%     %     autoArrangeFigures;
%     %     drawnow;
%     %pause
%     if ~isfile('equlizeCount.mat')
%         save('equlizeCount.mat','equlizeCount','-mat')
%     else
%         save('equlizeCount.mat','equlizeCount','-mat','-append');
%     end
    
end
end
