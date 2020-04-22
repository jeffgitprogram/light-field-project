function antialiasedRefocus = antialiasing3(shiftedLightField,deltaMat,disparityMat,xRange,yRange)
% shift and sum + local interpolation to obtain the antialiased refocused image

    [length,width,~,numViews] = size(shiftedLightField);
     m = sqrt(numViews);
     
%    interpolation threshold, > T1 do interpolation
     T1 = 1; 
%    occlusion threshold, > T2 don't do interpolation
%      T2 = 100;
     T2_inten = 58;
     T2_disp = 17;
    
    
    antialiasedRefocus = zeros(length,width,3);
%   number of additions at each pixel
    count = zeros(length,width); 

%   compute diaparity between view(i,j) and diagonally adacent view(i+1,j+1)
    for i=1:m-1
        for j=1:m-1           
            
            index = indexconvertor(i,j,m);
            next = indexconvertor(i+1,j+1,m);
            
%           current disparity to next view
%                   *  (i,j) --- disX = d-?x
%                      * (i+1,j+1) 


            dis_ori = disparityMat(:,:,index);
%           shift as view (i,j) does 
            dis_shift = imtranslate(dis_ori,[deltaMat(i,j,1),deltaMat(i,j,2)]);

%           Y : left--right   minus relative shifting in y direction
            disY = dis_shift - (deltaMat(i+1,j+1,1) - deltaMat(i,j,1)); 
%           X : up--down      minus relative shifting in x direction
            disX = dis_shift - (deltaMat(i+1,j+1,2) - deltaMat(i,j,2)); 
             

            dis_ori_next = disparityMat(:,:,next);
%           shift as view (i+1,j+1) does 
            dis_shift_next = imtranslate(dis_ori_next,[deltaMat(i+1,j+1,1),deltaMat(i+1,j+1,2)]);
            
%             intenMat = ones(length,width);
%             dispMat = ones(length,width);
            for x = xRange 
                for y = yRange
%                   pixel (x,y) in shifted view (i,j)
%                   corresponding pixel (x,y) in shifted disparity map

                    dx = disX(x,y);
                    dy = disY(x,y);
                    
%                   negative -> right
%                   positive -> left
                    if (dx < 0) 
                        rightX = min(round(x-dx),length);
                        leftX = x;
                        nextX = rightX;
                    else
                        leftX = max(round(x-dx),1);
                        rightX = x;
                        nextX = leftX;
                    end
                        
                    if (dy < 0) 
                        rightY = min(round(y-dy),width);
                        leftY = y;
                        nextY = rightY;
                    else
                        leftY = max(round(y-dy),1);
                        rightY = y;
                        nextY = leftY;
                    end
                           
                    dispDiff = abs(dis_shift(x,y)-dis_shift_next(nextX,nextY));
                    intenDiff = abs(rgb2gray(uint8(shiftedLightField(x,y,:,index)))-rgb2gray(uint8(shiftedLightField(nextX,nextY,:,next))));
                    
%                     intenMat(x,y) = intenDiff;
%                     dispMat(x,y) = dispDiff;
                    
                    occ = 0;
                    if dispDiff > T2_disp || intenDiff > T2_inten
                      occ = 1;
                    end
                    
                    if occ == 0 
                      % interpolate if in aliasing region
                      if abs(dx) > T1 || abs(dy) > T1
                        value1 = shiftedLightField(x,y,:,index);
                        value2 = shiftedLightField(nextX,nextY,:,next);

                        values = interpolate(x,y,leftX, rightX, leftY, rightY,nextX,nextY,value1,value2);
                          
                        antialiasedRefocus(leftX:rightX,leftY:rightY,:) = antialiasedRefocus(leftX:rightX,leftY:rightY,:) + values;
                        count(leftX:rightX,leftY:rightY) = count(leftX:rightX,leftY:rightY)+1;
 
                      else
                        % use original values if aliasing free
                        value = double(shiftedLightField(x,y,:,index));
                        antialiasedRefocus(x,y,:) = antialiasedRefocus(x,y,:) + value;
                        count(x,y) = count(x,y) + 1; 
                          
                      end
                    else % occlusion region
                      value = double(shiftedLightField(x,y,:,index));
                      values = repmat(value,[rightX-leftX+1,rightY-leftY+1]);
                      antialiasedRefocus(leftX:rightX,leftY:rightY,:) = antialiasedRefocus(leftX:rightX,leftY:rightY,:) + values;
                      count(leftX:rightX,leftY:rightY) = count(leftX:rightX,leftY:rightY)+1;  
                    end
                    
                end
            end
%            disp(prctile(intenMat,97,'all'));
%            disp(prctile(dispMat,97,'all'));
        end
    end
    
%   normalize
    antialiasedRefocus = antialiasedRefocus ./ count;


end