function [allCosts,allPaths] = eaOptimView(chargeCoordinates,sourceCoordinates,targetCoordinates,adjMatrix,impossibleIndex)

numSource = size(sourceCoordinates,1);
numTarget = size(targetCoordinates,1);

%Create cost matrix
coordinates = [sourceCoordinates;targetCoordinates;chargeCoordinates];
costMatrix  = squareform(pdist(coordinates,@Haversine));
costMatrix = costMatrix./27.78 + 120;
costMatrix = costMatrix.*adjMatrix;

numSource = size(sourceCoordinates,1);
numTarget = size(targetCoordinates,1);


allPaths = {};
allCosts = {};
for i =1:numTarget
    possibleIndices = 1:numSource;
    possibleIndices = possibleIndices(impossibleIndex(:,i)==0);
    [costs,paths] = dijkstra(adjMatrix,costMatrix,possibleIndices,numSource + i);
    allPaths{i} = paths;
    allCosts{i} = costs;
end



