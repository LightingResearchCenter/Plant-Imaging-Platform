function BinaryDiskImage = binariseAndFillDiskImage(Image)

BinaryDiskImage = imbinarize(Image);
BinaryDiskImage = imcomplement(BinaryDiskImage); % Need a bright disk on a dark background
SE = strel('square',20);
BinaryDiskImage = imdilate(BinaryDiskImage,SE);
BinaryDiskImage = imfill(BinaryDiskImage,'holes');
if showGraphics
    figure
    %imshow(BinaryDiskImage,'InitialMagnification','fit');
    hFrame = patch([xPos,xPos+xfov,xPos+xfov,xPos],[yPos,yPos,yPos+yfov,yPos+yfov],'r','FaceColor','none','EdgeColor','r');
    set(gca,'YDir','reverse');
end
