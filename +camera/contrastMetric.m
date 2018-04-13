function C = contrastMetric(Image)
% Computes a measure of image contrast for autofocusing.
% b = [-1,-1,-1;-1,8,-1;-1,-1,-1];
% 
% Y = filter2(b,Image);
% highCon = mean2(abs(Y))/mean2(Image);
% Yfft = fft2(Image);
% lowCon = mean2(abs(Yfft(2:30)))/real(Yfft(1,1));
% 
% C = 1*highCon+250*lowCon; % constants 5 and 250 scale each consituent to roughly 1 for focussed image
% i = ones(3,4);
% b =  i/sum(i(:));
data  = double(Image.data(:));
C(1)  = var(data)/mean(data);
