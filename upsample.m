function ZK_1 = upsample(IK_1,ZK,M,deltaZK,ref,shiftMat)

    [wid_zk, len_zk] = size(ZK); %wid_zk for y, len_zk for x
    
    [width,length,~,numViews] = size(IK_1);
    
    ZK_1 = zeros(width,length);
    IhatMat = zeros(width,length,3,3,numViews);
    
    %aveMat = zeros(width,length,numViews);
    %stdMat = zeros(width,length,numViews);
    %grayViews= zeros(width,length,numViews);
    for v = 1:numViews
        curView = rgb2gray(IK_1(:,:,:,v));
        curView = double(curView);
        %grayViews(:,:,v) = curView; 
        curAvg = getAverage(curView);
        curStd = getstd(curView,curAvg);
        IhatMat(:,:,:,:,v) = getIhat2(curView,curAvg,curStd);
    end
    
    
    f = waitbar(0,'Start'); 
    
    for x = 1:length
        waitbar(x/length,f,sprintf('x=%d',x)); 
        for y = 1:width
%           minimize Eq.19 to obtain local depth among all different i, j, m
            localZNCC = realmax("double");
            zmin = 1;

            for i = -1:1
                for j = -1:1
                    x_ = floor(x/2) + i; 
                    y_ = floor(y/2) + j;                     

                    if x_ > 0 && x_ < (len_zk+1) && y_ > 0 && y_ < (wid_zk + 1)
%                   consider the depth estimated value in the previous scale in 3 by 3 neighborhood
                        zk = ZK(y_,x_);

    %                   local depth range = [zk - deltaZK/2,zk + deltaZK/2] for each i,j,x,y
                        for m = 0:M                       
                           z = zk - deltaZK/2 + m*deltaZK/M;
                           curZNCC = getLocalZNCC(IhatMat,z,x,y,ref,shiftMat);
                           %getLocalZNCC2(grayViews,aveMat,stdMat,z,x,y,center,shiftMat);
                           if curZNCC < localZNCC
                               localZNCC = curZNCC;
                               zmin = z;
                           end
                        end
                    end
                end
            end

            ZK_1(y,x) = zmin;
        end
    end
end