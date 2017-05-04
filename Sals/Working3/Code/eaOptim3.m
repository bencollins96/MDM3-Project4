function [objective] = eaOptim3(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind)

%x is list of all coordinates in the form [x's,y's]
%chargeCoordinates is list of all charging point coordintes, just a
%transformation of x

%Fold x array in half to get coordinates of charging pts.
chargeCoordinates = [x(1:length(x)/2)', x(length(x)/2 + 1:length(x))'];

%Create cost matrix
coordinates = [sourceCoordinates;targetCoordinates;chargeCoordinates];
costMatrix  = squareform(pdist(coordinates,@Haversine));

%Convert to time
costMatrix = costMatrix./17.78;
costMatrix = costMatrix + 120;
costMatrix = costMatrix.*adjMatrix;

%Find shortest path routes using dijkstra
%Only allow paths where each step is less than fixed distance
%Count number of infeasible journeys from all the sources to each target 
%Find the cost of maximum path from any of the sources to each target in lMax

numInfeasible =0;
numImpossible = 0;
lMeanSum =0;

%For each target hospital. Find all routes to it.
usedStations = [];
numSource = size(sourceCoordinates,1);
numTarget = size(targetCoordinates,1);

for target=1:size(targetCoordinates,1)
    [costs,paths] = dijkstra(adjMatrix,costMatrix,setdiff(1:numSource,yind(xind==target)),numSource+target);
    for i=1:length(paths)
        path = paths{i};
        
        %skips unreachable hospitals.
        if isnan(path) 
            continue
        end
        
        pathSeq = zeros(length(path),2);
        pathSeq(1,:) = sourceCoordinates(path(1),:);
        pathSeq(length(path),:) = targetCoordinates(target,:);
        
        for k=2:length(path)-1
            pathSeq(k,:) = chargeCoordinates(path(k)-(numSource+numTarget),:);
            usedStations = [usedStations, path(k)];
        end
        
        plot(pathSeq(:,2),pathSeq(:,1),'g')
        hold on
        axis equal
    end

    for k=1:length(paths)
        if length(paths{k}) == 1
            numInfeasible = numInfeasible + 1;
        end
        if costs(k)>4*3600 %4hrs
            numImpossible = numImpossible + 1;
        end
        
    end
    
    %Find the maximum cost path
    lMean = lMeanSum + mean(setdiff(costs,inf));
end   

if isempty(lMeanSum)
    lMeanSum = 0;
end

usedStations = unique(usedStations)-(size(sourceCoordinates,1)+size(targetCoordinates,1));



%Now we require:
% - numInfeasible = sum(countVector) 
% - lMaxSum = sum(lMax)
%   Each element of countVector must be 0 as this corresponds to
%   feasible journeys from each source to each target
%Therefore we want to treat each target as a separate case so we want to
%minimise each lmax and we want to penalise each count from countVector 
%

objective = length(usedStations) + 10^3*(numImpossible-impossible);

end
