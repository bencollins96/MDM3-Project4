function [costsTotal,pathsTotal,lMeanVector] = eaOptimView(x,sourceCoordinates,targetCoordinates,adjMatrix,xind,yind)


%Fold x array in half to get coordinates of charging pts.
chargeCoordinates = [x(1:length(x)/2)', x(length(x)/2 + 1:length(x))'];

%Create cost matrix
coordinates = [sourceCoordinates;targetCoordinates;chargeCoordinates];
costMatrix  = squareform(pdist(coordinates,@Haversine));
costMatrix = costMatrix./17.78;
costMatrix = costMatrix + 120;
costMatrix = costMatrix.*adjMatrix;

%Find shortest path routes using dijkstra
%Only allow paths where each step is less than fixed distance
%Count number of infeasible journeys from all the sources to each target in
%count i
%Find the cost of maximum path from any of the sources to each target in lMax

%Countvector and lmaxvector store count and lmax for each target hospital
countVector = [];
lMeanVector  = [];

pathsTotal = cell(size(sourceCoordinates,1),size(targetCoordinates,1));
costsTotal = zeros(size(sourceCoordinates,1),size(targetCoordinates,1));

for target=1:size(targetCoordinates,1)
    yspec= yind(xind==target);
    [costs,paths] = dijkstra(adjMatrix,costMatrix,1:size(sourceCoordinates,1),size(sourceCoordinates,1)+target);
    
    %what is this cost?
    costs(yspec) = 10^12;
%     for m=1:length(yspec)
%         paths{yspec(m)} = NaN;
%     end
    
    
    pathsTotal(:,target) = paths;
    costsTotal(:,target) = costs;

    count = 0;
    for k=1:length(paths)
        if length(paths{k}) == 1
            count = count + 1;
        end
    end
    %Find the mean cost path
    lMean = mean(setdiff(costs,inf));
    
    countVector = [countVector, count];
    lMeanVector  = [lMeanVector, lMean];
end   


end

