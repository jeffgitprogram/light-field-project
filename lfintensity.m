function [IntensMatrix] = lfintensity(LT1,LT2,dhat_x,dhat_y)
%INTENSITY Summary of this function goes here
%LT1 is the translated light field of current view,
%LT2 is the translated light field of diagonal neighbour
%   Detailed explanation goes here
[m,n,l] = size(LT1);
IntensMatrix = zeros(m,n);
%temp_LT1 = uint8(LT1);
%temp_LT2 = uint8(LT2);
LT1_gr = rgb2gray(uint8(LT1));
LT2_gr = rgb2gray(uint8(LT2));

for x = 1:m
    for y = 1:n
        
        a = LT1_gr(x,y);
        x2 = min(round(x+dhat_x(x,y)),m);
        y2 = min(round(y+dhat_y(x,y)),n);
        b = LT2_gr(x2,y2);
        Intens_temp = abs(a - b);
        IntensMatrix(x,y) = Intens_temp;
    end
end
end
