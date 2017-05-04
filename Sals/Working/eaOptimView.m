function [costsTotal,pathsTotal] = eaOptimView(x,sourceCoordinates,targetCoordinates,adjMatrix,xind,yind)

%Fold x array in half to get coordinates of charging pts.
chargeCoordinates = [x(1:length(x)/2)', x(length(x)/2 + 1:length(x))'];

%Create cost matrix
coordinates = [sourceCoordinates;targetCoordinates;chargeCoordinates];
costMatrix  = squareform(pdist(coordinates,@Haversine));
costMatrix = costMatrix.*adjMatrix;

%Find shortest path routes using dijkstra
%Only allow paths where each step is less than fixed distance
%Count number of infeasible journeys from all the sources to each target in
%count 
%Find the cost of maximum path from any of the sources to each target in lMax

%Countvector and lmaxvector store count and lmax for each target hospital
countVector = [];
lMaxVector  = [];

pathsTotal = cell(size(sourceCoordinates,1),size(targetCoordinates,1));
costsTotal = zeros(size(sourceCoordinates,1),size(targetCoordinates,1));

for target=1:size(targetCoordinates,1)
    
    yspec = yind(xind==target);
    
    [costs,paths] = dijkstra(adjMatrix,costMatrix,1:size(sourceCoordinates,1),size(sourceCoordinates,1)+target);
    
    costs(yspec)  = Inf;
    
    for m=1:length(yspec)
        paths{yspec(m)} = NaN;
    end
    
    pathsTotal(:,target) = paths;
    costsTotal(:,target) = costs;

end   


end

