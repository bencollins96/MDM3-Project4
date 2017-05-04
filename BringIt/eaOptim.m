function [objective] = eaOptim(x,sourceCoordinates,targetCoordinates,adjMatrix,impossibleIndex)

chargeCoordinates = [x(1:length(x)/2)',x(length(x)/2 +1:end)'];

%Create cost matrix
coordinates = [sourceCoordinates;targetCoordinates;chargeCoordinates];
costMatrix  = squareform(pdist(coordinates,@Haversine));
costMatrix = costMatrix./27.778 + 120;
costMatrix = costMatrix.*adjMatrix;

numSource = size(sourceCoordinates,1);
numTarget = size(targetCoordinates,1);

%Find shortest path routes using dijkstra
%Only allow paths where each step is less than fixed distance
%Count number of infeasible journeys from all the sources to each target in
%count 
%Find the cost of maximum path from any of the sources to each target in lMax

allPaths = cell(1);
allCosts = cell(1);
for i = 1:numTarget
    possibleIndices = 1:numSource;
    possibleIndices = possibleIndices(impossibleIndex(:,i)== 0);
    [costs,paths] = dijkstra(adjMatrix,costMatrix,possibleIndices,numSource + i);
    allPaths{i} = paths;
    allCosts{i} = costs;
end

COSTS = [];
PATHS = [];

for i =1:length(allCosts)
    COSTS =[COSTS;allCosts{i}];
    PATHS =[PATHS;allPaths{i}];
end

allCosts = COSTS(:);
allPaths = PATHS(:);

%Count all the paths that dont go anywhere
countNowhere= 0;
countTooLong = 0;
for i =1:size(allPaths,1)
   
    if length(allPaths{i}) ==1
        countNowhere = countNowhere + 1;
        continue
    end
    
    if allCosts(i) > 2*3600
        countTooLong = countTooLong + 1;
    end 
end

lMean = mean(setdiff(allCosts,inf));

%usedStations = get_usedStations(allPaths,numSource,numTarget);
%numUsed = size(usedStations,1);

objective =  1e8*(countNowhere + countTooLong) + lMean;


function [usedStations] = get_usedStations(AllPaths,numSource,numTarget)
    chrgList = [];
    for j =1:length(AllPaths)
        if length(AllPaths{j}) > 2
            chrgList =[chrgList, AllPaths{j}(2:end-1) ];
        end
    end
usedStations = unique(chrgList) - (numSource + numTarget);

end

end
