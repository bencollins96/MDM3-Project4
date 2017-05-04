function [objective] = eaOptim2(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind)

%x is list of all coordinates in the form [x's,y's]
%chargeCoordinates is list of all charging point coordintes, just a
%transformation of x

%Fold x array in half to get coordinates of charging pts.
chargeCoordinates = [x(1:length(x)/2)', x(length(x)/2 + 1:length(x))'];

%Create cost matrix
coordinates = [sourceCoordinates;targetCoordinates;chargeCoordinates];
costMatrix  = squareform(pdist(coordinates,@Haversine));
costMatrix = costMatrix.*adjMatrix;


%Find shortest path routes using dijkstra
%Only allow paths where each step is less than fixed distance
%Count number of infeasible journeys from all the sources to each target 
%Find the cost of maximum path from any of the sources to each target in lMax

numInfeasible =0;
numImpossible = 0;
lMeanSum =0;

%For each target hospital. Find all routes to it.
for target=1:size(targetCoordinates,1)
    [costs,paths] = dijkstra(adjMatrix,costMatrix,setdiff(1:size(sourceCoordinates),yind(xind==target)), size(sourceCoordinates,1)+target);
    
    for k=1:length(paths)
        if length(paths{k}) == 1
            numInfeasible = numInfeasible + 1;
        end
        if costs(k)>2.4*10^5
            numImpossible = numImpossible + 1;
        end
        
    end
    
    %Find the maximum cost path
    lMean = lMeanSum + mean(setdiff(costs,inf));
end   

if isempty(lMeanSum)
    lMeanSum = 0;
end

%Now we require:
% - numInfeasible = sum(countVector) 
% - lMaxSum = sum(lMax)
%   Each element of countVector must be 0 as this corresponds to
%   feasible journeys from each source to each target
%Therefore we want to treat each target as a separate case so we want to
%minimise each lmax and we want to penalise each count from countVector 
%

objective = 10^6*lMeanSum + 10^12*(numImpossible-impossible);

end
