addpath('harris')
addpath('transformation')

tic
% I1 = imread('images/boat/img1.pgm');
% I2 = imread('images/boat/img2.pgm');
I1 = imread('images/tsukuba/scene1.row3.col1.ppm');
I2 = imread('images/tsukuba/scene1.row3.col2.ppm');

if length(size(I1)) == 3
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
end

I1 = im2single(I1);
I2 = im2single(I2);

qual = 0.01;
poi1 = myHarris(I1,qual);
poi2 = myHarris(I2,qual);

[f1, validpts1] = extractFeatures(I1, poi1);
[f2, validpts2] = extractFeatures(I2, poi2);

map = nnMatch(f1, f2, 0.6);

matchedPoints1 = validpts1(map(:,1),:);
matchedPoints2 = validpts2(map(:,2),:);
figure;
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);

toc
