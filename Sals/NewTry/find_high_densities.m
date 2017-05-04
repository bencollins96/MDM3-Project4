function [max_list] = find_high_densities(lat1,lng1)

close_range =  2e4;
numChrg = 148;

distMatrix = squareform(pdist([lat1,lng1],@Haversine));


%Take every hospital, and assign a 1 in the distance matrix is distance is
%less than 20km
closePts = zeros(size(distMatrix));
closePts(distMatrix < 2e4) = 1;
% 
% for  i=1:length(lat1)
%     ptDists = distMatrix(:,i);
%     closePts(ptDists < 2e4,i)  = 1;
% end


max_list = [];
for i=1:numChrg
    
    %get number of close pts for each hospital.
    summedDist = sum(closePts);
    
    %find the biggest and add it to list.
    [~,ind] = max(summedDist);
    max_list = [max_list ,ind];
    
    %find all hospitals connected to it.
    connectedHos = closePts(:,ind);
    
    indices = find(connectedHos);
    
    %remove all of these from close pts so no overlapping.
    closePts(indices,:) = 0;
    closePts(:,indices) = 0; 
end


      
%Step2

ChrgCoordinates = [lat1(max_list),lng1(max_list)];

%distMatrix = squareform(pdist(ChrgCoordinates,@Haversine));
%CloseEnough = zeros(size(distMatrix));
%CloseEnough(distMatrix < 6e4) = 1;

    
    
   
%  figure(3)

       
%  scatter(lng1,lat1,'filled','g');
%  hold on
%  scatter(lng1(max_list),lat1(max_list),'filled','k');

 MinChrgCoordinates = ChrgCoordinates;
 TotalChrgCoordinates = ChrgCoordinates;
 
 
exitFlag = false;
 while exitFlag == false
    [TotalChrgCoordinates, MinChrgCoordinates,exitFlag] = add_chrg(MinChrgCoordinates,lng1,lat1,TotalChrgCoordinates); 
 end
 
%      
% 
% scatter(TotalChrgCoordinates(:,2),TotalChrgCoordinates(:,1),'filled','r');
% scatter(ChrgCoordinates(:,2),ChrgCoordinates(:,1),'filled','k');
    
function [TotalChrgCoordinates, MinChrgCoordinates,exitFlag] = add_chrg(ChrgCoordinates,lng1,lat1,TotalChrgCoordinates)
     
    exitFlag = false;
    dMatrix = squareform(pdist(ChrgCoordinates,@Haversine));
    dMatrix = dMatrix + diag(inf*ones(size(dMatrix,1),1));
    
    CloseEnough = zeros(size(dMatrix));
    CloseEnough(dMatrix < 8e4) = 1;
    
    if sum(dMatrix < 8e4) == 0
        MinChrgCoordinates = ChrgCoordinates;
        exitFlag = true;
        return
    end
        
    CloseEnough(dMatrix == 0) = 0;
    
    
    

    %CloseEnough = CloseEnough - diag(ones(size(CloseEnough)));
    [n,m] =ind2sub(size(dMatrix),find(dMatrix==min(min(dMatrix)),1));

    new_lat = mean([ChrgCoordinates(n,1),ChrgCoordinates(m,1)]);
    new_lng = mean([ChrgCoordinates(n,2),ChrgCoordinates(m,2)]);
    
    TotalChrgCoordinates = [TotalChrgCoordinates; [new_lat,new_lng]];
    MinChrgCoordinates = ChrgCoordinates;
    MinChrgCoordinates([n,m],:) = [];

    
    end

end
    
    
    
    