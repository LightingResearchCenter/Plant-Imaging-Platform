function out = variance(img)

[h,w,c] = size(img);
out = zeros(c,1);
for i = 1:c
    out(i,1) = var(img(:));
end
out = mean(out);
out = out(2);
end