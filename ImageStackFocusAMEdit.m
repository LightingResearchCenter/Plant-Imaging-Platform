%------------------------------------------------------------------------
% ALM865's Focus Stacker and Animator 16-05-2014
%------------------------------------------------------------------------
%
% This Matlab script is coded to load in a series of JPGs that are in order
% from cloest to deepest focus and stack the images into a Sharp image and
% animate the result.
%
% Usage:
%
% As a MINIMUM you need to change these settings to match the images you
% have:
%   NoImage
%   startfn
%   NoStart
%
% Ie if you have 100 images starting with the file name IMG_101.jpg and
% ending with IMG_201.jpg in the folder 'C:\MyImages' then your settings
% would be:
%
%   NoImage = 100;
%   startfn = 101;
%   NoStart = 'C:\MyImages\IMG_';
%
% For best results do the following:
%
%  - If you don't know how to capture focus set then see this video
%  https://www.youtube.com/watch?v=CcRVXuc6Yt4 he explains it really well
%  - Ensure that your first image has the closest focus
%  - Ensure that your lighting doesn't change, this script will attempt to
%  correct any lighting errors but it is not as good as getting it correct
%  on the camera!
%  - Ensure that your camera doesn't move, this means a solid tripod and no
%  touching the camera while shooting!
%  - Make sure your images are of a sensible size, this script can deal
%  with images of any size as long as you have enough memory. For testing I
%  would suggest using images no more than 1500px wide or tall.
%  - Macro lenses work the best but you can use a standard lens with an
%  extension tube for a similar result
%
% Animation instructions:
% -----------------------
% Use Gimp to create a GIF if you wish by loading the first image, and then
% adding the rest as layers, then export as gif and check animate
%
% You may also use mencoder to create an AVI as follows:
% mencoder "mf://*.JPG" -mf fps=20:type=jpg -ovc lavc -lavcopts
% vcodec=mjpeg -oac copy -o output.avi
% 
% 
%
%------------------------------------------------------------------------

%Usual clear all to stop silly errors
clear all; close all; clc;

%------------------------------------------------------------------------
%Inputs - These are the variables you will need to change
%------------------------------------------------------------------------
%Number of images in focus stack
NoImage=53;

%Filename number start
NoStart=4446;

%Path and start of filename
startfn='Small\IMG_'; %Windows
%startfn='C:\Users\AlexM\Desktop\100CANON\Stack6\Stack\Small\IMG_'; %Windows
%startfn='file:///media/alm/2TBHDD/100CANON/Stack6/Stack/Small/IMG_'; %Linux

%Size in pixels of how much the image stack is smoothed (31 is a good size)
dilateballsize=31; %size of dilation ball

%Value to try and reduce picking up noise as edges (0=off)
LowCont=0; %remove low contrast areas

%Size in pixels to search for edges (11 is a good size for a 1500pixel wide
%image, for a 5000 pixel wide image it's probably better to use 51 but it
%will be significantly slower to process the image stack
OSize=11;  %size of gauss and laplace kernels

%Turn on stack blur (helps stop noticable edges on stack)
BlurStack=1; %1=enable blur of stacked image

%size of blur in pixels (Use same as OSize for best results)
BlurSize=11; %Size of blur

%Animation of focus stack
%How many pixels to shift stack in both directions (i.e. 50 will go from
%-50 to 50 pixels)
AnimSize=50;

%How many pixels to step
AnimSteps=2;

%Direction multipliers, x=1, y=0 means the image will move in the x
%direction, x=0 y=1 means the image will move in the y direction, x=1 y=1
%means that it will move in both x and y directions
xMult=1;
yMult=0;

%not yet programmed in but it will be a bilinear resampling of the original
%images to speed up processing larger images
ResizeImagesPerc=20; %100 = no resizing
%------------------------------------------------------------------------


%------------------------------------------------------------------------
%Actual code
%------------------------------------------------------------------------
%Don't change anything here unless you are familiar with Matlab
%------------------------------------------------------------------------

%Load images
NoStart=NoStart-1;
ImgArr=cell(1,NoImage);
ImgArrBW=cell(1,NoImage);
for i=1:NoImage
    disp(strcat('Loading Image No',num2str(i),'/',num2str(NoImage)));
    ImgArr{i}=imread(strcat(startfn,num2str(NoStart+i),'.JPG'));
end

%adjust image brightnesses to all match (make all same level)
b1 = mean2(rgb2gray(ImgArr{1}));
for i=2:NoImage
    b2 = mean2(rgb2gray(ImgArr{i}));
    ImgArr{i} = ImgArr{i} + (b1-b2);
end

%operators
Gauss  =zeros(OSize,OSize);
Laplace=zeros(OSize,OSize);
Mid=ceil(OSize/2);
c=1;

%build laplace and gauss (instead of using inbuilt 'fspecial')
for i=1:OSize
    for j=1:OSize
        x=i-Mid;
        y=j-Mid;
        Laplace(i,j)=(-1/pi/c/c/c/c)*(1-(x*x+y*y)/2/c/c)*exp(-(x*x+y*y)/2/c/c);
        Gauss(i,j) = exp(-(((x*x)/2/c/c+(y*y)/2/c/c)));
    end
end

%edge detect all images
for i=1:NoImage
    disp(strcat('Edge Detecting Image No',num2str(i),'/',num2str(NoImage)));
    
    Temp = conv2(double(ImgArr{i}(:,:,1))+double(ImgArr{i}(:,:,2))+double(ImgArr{i}(:,:,3)),Gauss,'same');
    ImgArrBW{i} = conv2(Temp,Laplace,'same');
    B = size(ImgArrBW{i});
    ImgArrBW{i} = abs(ImgArrBW{i});
    
    disp(strcat('Dilating Image No',num2str(i),'/',num2str(NoImage)));

    %do a dilate? Seems to work okay
    if (dilateballsize>0)
        MidBall=ceil(dilateballsize/2);
        se = strel('ball',dilateballsize,dilateballsize);
        ImgArrBW{i} = imdilate(ImgArrBW{i},se,'same');
        Dims = size(ImgArrBW{i});
    end
end

%order stack
SizeS = size(ImgArrBW{i});
Stack = ones(SizeS);
StackVal = zeros(SizeS);
for i=1:NoImage
    disp(strcat('Stacking Image No',num2str(i),'/',num2str(NoImage)));

    for j=1:SizeS(1)
        for k=1:SizeS(2)
            if (ImgArrBW{i}(j,k)>StackVal(j,k))
                StackVal(j,k)=ImgArrBW{i}(j,k);
                Stack(j,k)=i;
            end
        end 
    end 
end

%Blur stack if needed for blending
if (BlurStack==1) 
    Stack=conv2(Stack,fspecial('gaussian', [BlurSize BlurSize], 10),'same');
end

%Remove low contrast areas
StackClip = ones(SizeS);
for j=1:SizeS(1)
    for k=1:SizeS(2)
        if (StackVal(j,k)<LowCont)
            StackClip(j,k)=NoImage;
        else
            StackClip(j,k)=Stack(j,k);
        end
    end 
end
%imagesc(StackClip); figure(gcf)

%Combine Stack into sharp image
SharpImg=ImgArr{1};
SizeI=size(ImgArr{1});
for j=1:SizeI(1)
    for k=1:SizeI(2)
        Index=uint16(StackClip(j,k));
        if (Index<1)
            Index=1;
        end
        if (Index>NoImage)
            Index=NoImage;
        end
        SharpImg(j,k,:)=ImgArr{Index}(j,k,:);
    end
end

%show and save image
%figure;
%imagesc(SharpImg); figure(gcf)
imwrite(SharpImg,'OutSharp.bmp');

%Animate
for moveSt=-AnimSize:AnimSteps:AnimSize
    
    disp(strcat('Animating No',num2str(moveSt)));
    
    Result=ImgArr{NoImage};
	FillMaskSize=size(Result);
	FillMask=zeros(FillMaskSize(1),FillMaskSize(2));
    SizeStack=size(StackClip);
    for y=1:SizeStack(1)
        for x=1:SizeStack(2)
            s1=StackClip(y,x);
            x1=x+(moveSt*((NoImage-s1-(NoImage/2))/NoImage))*xMult;
            y1=y+(moveSt*((NoImage-s1-(NoImage/2))/NoImage))*yMult;
            
            if (x1<1)
                x1=1;
            end
            if (x1>SizeStack(2))
                x1=SizeStack(2);
            end
            if (y1<1)
                y1=1;
            end
            if (y1>SizeStack(1))
                y1=SizeStack(1);
            end
            Index=uint16(StackClip(y,x));
            if (Index<1)
                Index=1;
            end
            if (Index>NoImage)
                Index=NoImage;
            end
            FillMask(uint16(y1),uint16(x1))=1;
            Result(uint16(y1),uint16(x1),:)=ImgArr{Index}(y,x,:);
        end
    end
    
    disp(strcat('Filling Gaps No',num2str(moveSt)));
    
    %fill any gaps
    for y=1:SizeStack(1)
        for x=1:SizeStack(2)
			if (FillMask(y,x)==0)
				Filled=0;
                k=x+1;
				while (Filled==0)
					k=k+1;
					if k>SizeStack(2)
						Filled=1;
                    elseif (FillMask(y,k)==1)
						Result(y,x,:)=Result(y,k,:);
						Filled=1;
					end
				end
			end
        end
    end
	
    disp(strcat('Building Animation No',num2str(moveSt)));
    
    imwrite(Result,strcat('Out',num2str(moveSt+AnimSize+1),'.jpg')); %Use .jpg for jpegs
    imwrite(Result,strcat('Out',num2str(AnimSize*5-(moveSt+AnimSize+1)),'.jpg')); %Use .jpg for jpegs

end
