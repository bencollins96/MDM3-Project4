function [objective] = eaOptim(x,sourceCoordinates,targetCoordinates,adjMatrix)

%x is list of all coordinates in the form [x's,y's]
%chargeCoordinates is list of all charging point coordintes, just a
%transformation of x

Range = 5e4;   

%Fold x array in half to get coordinates of charging pts.
chargeCoordinates = [x(1:length(x)/2)', x(length(x)/2 + 1:length(x))'];

%Create cost matrix
coordinates = [sourceCoordinates;targetCoordinates;chargeCoordinates];
costMatrix  = squareform(pdist(coordinates,@Haversine));

chargeCoordinates
spy(costMatrix);
return
costMatrix = costMatrix.*adjMatrix;

numSource = size(sourceCoordinates,1);
numTarget = size(targetCoordinates,1);


%Find shortest path routes using dijkstra
%Only allow paths where each step is less than fixed distance
%Count number of infeasible journeys from all the sources to each target 
%Find the cost of maximum path from any of the sources to each target in lMax

numInfeasible =0;
lMaxSum =0;

%For each target hospital. Find all routes to it.
for target=1:size(targetCoordinates,1)
    [costs,paths] = dijkstra(adjMatrix,costMatrix,[1:numSource],[numSource +1:numSource + numTarget]);
    for k=1:length(paths)
        if length(paths{k}) == 1
            numInfeasible = numInfeasible + 1;
        end
    end
    
    %Find the maximum cost path
    lMaxSum = lMaxSum + max(setdiff(costs,inf));
end  

%if there are no feasible journeys lMaxSum =empty so turn to 0

if isempty(lMaxSum)
    lMaxSum = 0;
end

%Now we require:
% - numInfeasible = sum(countVector) 
% - lMaxSum = sum(lMax)
%   Each element of countVector must be 0 as this corresponds to
%   feasible journeys from each source to each target
%Therefore we want to treat each target as a separate case so we want to
%minimise each lmax and we want to penalise each count from countVector 

objective =  lMaxSum + 10^9*numInfeasible;

end
