function [costsTotal,pathsTotal] = eaOptimView(x,sourceCoordinates,targetCoordinates,adjMatrix)

Range = 5e4;

%Fold x array in half to get lat lng for charging pts.
chargeCoordinates = [x(1:length(x)/2)', x(length(x)/2 + 1:length(x))'];

%Create cost matrix
coordinates = [sourceCoordinates;targetCoordinates;chargeCoordinates];
costMatrix  = squareform(pdist(coordinates,@Haversine));
costMatrix = costMatrix.*adjMatrix;
adjMatrix(costMatrix > Range) = 0;

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
    [costs,paths] = dijkstra(adjMatrix,costMatrix,1:20,20 + target);
    
    pathsTotal(:,target) = paths;
    costsTotal(:,target) = costs;

    count = 0;
    for k=1:length(paths)
        if length(paths{k}) == 1
            count = count + 1;
        end
    end
    %Find the maximum cost path
    lMax = max(setdiff(costs,inf));
    
    countVector = [countVector, count];
    lMaxVector  = [lMaxVector, lMax];
end   


end

