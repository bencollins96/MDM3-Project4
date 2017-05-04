% Find coordinates of source hospitals
x = lat1(1:100);
y = lng1(1:100);

sourceCoordinates = zeros(20,2);
sourceCoordinates(:,1) = x;
sourceCoordinates(:,2) = y;

% Create fictitious target hospital
targetCoordinates = [mean(sourceCoordinates);mean(sourceCoordinates) + 0.1];

%Transforms coordinates to a decent format.
% xDist = squareform(pdist(sourceCoordinates(:,1),@Haversine));
% yDist = squareform(pdist(sourceCoordinates(:,2),@Haversine));
% [maxCoordX,ind] = max(xDist(:));
% [mx,nx] = ind2sub(size(xDist),ind);
% 
% [maxCoordY,ind] = max(yDist(:));
% [my,ny] = ind2sub(size(yDist),ind);
% 
% % scatter(sourceCoordinates(:,1),sourceCoordinates(:,2))
% % hold on
% % plot([sourceCoordinates(mx,1),sourceCoordinates(nx,1)],[sourceCoordinates(mx,2),sourceCoordinates(nx,2)])
% % plot([sourceCoordinates(my,1),sourceCoordinates(ny,1)],[sourceCoordinates(my,2),sourceCoordinates(ny,2)])
% 
% xLims = [sourceCoordinates(mx,1),sourceCoordinates(nx,1)];
% [minX,iX] = min(xLims);
% ax = xLims(iX);
% bx = setdiff(xLims,minX);
% 
% yLims = [sourceCoordinates(my,2),sourceCoordinates(ny,2)];
% [minY,iY] = min(yLims);
% ay = yLims(iY);
% by = setdiff(yLims,minY);
numberChrgStns = 5;

% Create adjacency matrix: From hospitals to charging points only. 
n1 = size(sourceCoordinates,1)+size(targetCoordinates,1)+numberChrgStns;
n2 = size(sourceCoordinates,1);
graph1 = ones(n1,n1);
diagonal = diag(ones(1,n1));
adjMatrix = graph1 -diagonal;
graph2sub = ones(n2,n2) - diag(ones(1,n2));
graph2 = zeros(n1,n1);
graph2(1:n2,1:n2)  = graph2sub;
adjMatrix = adjMatrix - graph2;
adjMatrix(n2 + 1: n2 + size(targetCoordinates,1),n2 + 1: n2 + size(targetCoordinates,1)) = zeros(2,2); 
adjMatrix(n2+1:size(targetCoordinates,1)+numberChrgStns+n2,1:n2) = zeros(size(targetCoordinates,1)+numberChrgStns,n2);

optim = @(x)eaOptim([x,y],sourceCoordinates,targetCoordinates,adjMatrix);

lb = [ones(numberChrgStns,1).*min(sourceCoordinates(:,1));ones(numberChrgStns,1).*min(sourceCoordinates(:,2))];
ub = [ones(numberChrgStns,1).*max(sourceCoordinates(:,1));ones(numberChrgStns,1).*max(sourceCoordinates(:,2))];

    
latl = min(sourceCoordinates(:,1));
latu = max(sourceCoordinates(:,1));
lngl = min(sourceCoordinates(:,2));
lngu = max(sourceCoordinates(:,2));

InitialPopulationRange_Data = [lb';ub'];
PopulationSize_Data = 100;

[x,fval,exitflag,output,population,score] = eaOptimFunc(sourceCoordinates,targetCoordinates,adjMatrix,2*numberChrgStns,lb,ub,InitialPopulationRange_Data,PopulationSize_Data);

clf
scatter(sourceCoordinates(:,1),sourceCoordinates(:,2),'r')
hold on 
scatter(targetCoordinates(:,1),targetCoordinates(:,2),'b')

[costs,paths] = eaOptimView(x,sourceCoordinates,targetCoordinates,adjMatrix);

chargingCoordinates = zeros(length(x)/2,2);
chargingCoordinates(:,1) = x(1:numberChrgStns);
chargingCoordinates(:,2) = x(numberChrgStns+1:2*numberChrgStns);

usedStations = [];
%Plot routes?
for target=1:size(targetCoordinates,1)
    for i=1:length(paths)
        path = paths{i};
        pathSeq = zeros(length(path),2);
        
        
        if isnan(path)
            disp('No path Possible');
            continue
        end
        pathSeq(1,:) = sourceCoordinates(path(1),:);
        pathSeq(length(path),:) = targetCoordinates(target,:);
        for k=2:length(path)-1
            pathSeq(k,:) = chargingCoordinates(path(k)-(size(sourceCoordinates,1)+size(targetCoordinates,1)),:);
            usedStations = [usedStations, path(k)];
        end
        plot(pathSeq(:,1),pathSeq(:,2),'g')
        hold on
        axis equal
    end
end

usedStations = unique(usedStations)-(size(sourceCoordinates,1)+size(targetCoordinates,1));

xChargingStations = chargingCoordinates(:,1);
yChargingStations = chargingCoordinates(:,2);

chargingCoordinates

scatter(xChargingStations(usedStations),yChargingStations(usedStations),'g')
