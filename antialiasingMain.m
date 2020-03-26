%%
clc;
close all;
clear variables;
%% Initialize shifting matrix
shiftMat = zeros(4,4,2);
shiftMat(:,:,1) = [100,-0.36,-97.19,-195.55;
                   98.67,0,-96.18,-197.85;
                   99.17,0.21,-98.33,-197;
                   99.08,-1.22,-99.26,-198.36];%% X Direction
shiftMat(:,:,2) = [98.28,98.14,98.07,97.35;
                   -1.73,0,0.74,0.11;
                   -99.93,-99.11,-101.12,-99.07;
                   -197.68,-198.14,-198.89,-199.37];%% Y Direction
               
%% Load 4D light field 
views = 16;
frameOfInterest = 0;
lightField = genLfSequence("F:\Project Space\EECE541\light-field-refocus\Images-Frame1\", "Painter_pr_00",views,frameOfInterest,'png');
%lightField = genLfSequence("/Users/vera/Downloads/EECE541/project/Code/Repo/light-field-refocus/Images-Frame1/", "Painter_pr_00",views,frameOfInterest,'png');
%% Test disparty() function
%{
image1 = imread('F:\Project Space\EECE541\light-field-refocus\Images-Frame1\Painter_pr_00000_00.png');
image2 = imread('F:\Project Space\EECE541\light-field-refocus\Images-Frame1\Painter_pr_00000_01.png');
image3 = imread('F:\Project Space\EECE541\light-field-refocus\Images-Frame1\Painter_pr_00000_04.png');
%image1 = imread('/Users/vera/Downloads/EECE541/project/Code/Repo/light-field-refocus/Images-Frame1/Painter_pr_00000_00.png');
%image2 = imread('/Users/vera/Downloads/EECE541/project/Code/Repo/light-field-refocus/Images-Frame1/Painter_pr_00000_05.png');
%Visualize the disparity between current iamge and its horizontal neighbour
A = stereoAnaglyph(image1,image2);
imtool(A)
%Visualize the disparity between current iamge and its vertical neighbour
image1_r = imrotate(image1,90,'bilinear','loose');
image3_r = imrotate(image3,90,'bilinear','loose');
B = stereoAnaglyph(image1_r,image3_r);
imtool(B)
disparityRange = [0,112];
%Calculate the disparity between current iamge and its horizontal neighbour
disparityMap = disparityBM(rgb2gray(image1), rgb2gray(image2),'DisparityRange',disparityRange,'ContrastThreshold',0.7,'DistanceThreshold',10);
figure 
imshow(disparityMap,disparityRange);
title('Disparity Map');
colormap jet 
colorbar
imtool(disparityMap)
%Calculate the disparity between current iamge and its vertical neighbour
disparityMap2 = disparityBM(rgb2gray(image1_r), rgb2gray(image3_r),'DisparityRange',disparityRange,'ContrastThreshold',0.7,'UniquenessThreshold',15);
disparityMap2T = imrotate(disparityMap2,-90,'bilinear','loose');
figure 
imshow(disparityMap2T,disparityRange);
title('Disparity Map 2');
colormap jet 
colorbar
imtool(disparityMap2T)
%}
%% Compute the antialiased refocus image and compare with original refocus image
arrayLength = 4;
arrayDepth = 4;
depth = 5;

[shiftedLightField, deltaMat] = lfShifted(lightField,arrayLength,arrayDepth,shiftMat,depth); %Get LT matrix,deltaX and daltaY
disparityMap = lfdisparity(lightField,arrayLength,arrayDepth,deltaMat);
%disDiffMat = lfdispdiff(disparityMap,3,2);
%d = prctile(disDiffMat,[97 100],'all'); %Quantile 97 ->58 100->111
[antialiasedRefocus, dis, disX, disY] = antialiasing(shiftedLightField,lightField,deltaMat,disparityMap,arrayLength,arrayDepth);

refocus = lfRefocus(lightField,arrayLength,arrayDepth,shiftMat,depth);

subplot(2,1,1), imshow(uint8(antialiasedRefocus)), title("Antialiased Refocus");
subplot(2,1,2), imshow(uint8(refocus)), title("Refocus");






