%% Antialiasing Main

clc;
close all;
clear variables;
%% Initialize shifting matrix

shiftMat = zeros(4,4,2);
% X Direction : left-right
shiftMat(:,:,1) = [100,-0.36,-97.19,-195.55;
                   98.67,0,-96.18,-197.85;
                   99.17,0.21,-98.33,-197;
                   99.08,-1.22,-99.26,-198.36];
               
% Y Direction : up-down
shiftMat(:,:,2) = [98.28,98.14,98.07,97.35;
                   -1.73,0,0.74,0.11;
                   -99.93,-99.11,-101.12,-99.07;
                   -197.68,-198.14,-198.89,-199.37];
               
%% Load 4D light field 

views = 16; % number of views
frameOfInterest = 59; 
lightField = genLfSequence("./data/LightFieldRefocusingProject/TestSequence/", "Painter_pr_00",views,frameOfInterest,'png');

%% Compute the antialiased refocus image and compare with original refocus image

depth = 4;
center = 6;
load ./depthmap/depthMaps59_11.mat

focalLength = 2354.05; % pixels
cameraDis = 0.07; % meter

disparity = cameraDis*focalLength./depthMapMat;

% get shifted lf matrix, deltaX and daltaY, and refocused image
[refocus,shiftedLightField, deltaMat] = lfShiftSum(lightField,shiftMat,depth); 

% shift and sum + local interpolation
lfSize = size(lightField);
xRange = 1:lfSize(1);
yRange = 1:lfSize(2);
antialiasedRefocus = antialiasing2(shiftedLightField,lightField,center,deltaMat,disparity,xRange,yRange);

subplot(2,1,1), imshow(uint8(antialiasedRefocus(xRange,yRange,:))), title("Antialiased Refocus");
subplot(2,1,2), imshow(uint8(refocus(xRange,yRange,:))), title("Refocus");

imwrite(uint8(antialiasedRefocus),"./antiRefo/antiRefo"+frameOfInterest+"_d"+depth+".png");




