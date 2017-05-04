%eaOptimRunner

maxTime = 4*3600; %4hrs
droneSpeed = 17.78;  %64 km/h 

%Get coordinates of source Hospitals.
numSource = 100;
lat = lat1(1:numSource);
lng = lng1(1:numSource);
sourceCoordinates = [lat,lng];

%Get coordinates of target Hospitals.
targetCoordinates = [lat(10),lng(10);lat(30),lng(30)];
numTarget = 2;

%Set number of charging points.
numChrg = 30;

%Create the adjacency Matrix: only allows paths Source-> Chrg* ->Target
adjMatrix = get_adjMatrix(numSource,numTarget,numChrg);

%Set lower & upper bounds for list [lat1,lat2,lat3, ... ,lng1,lng2...];
lb = [min(lat)*ones(numChrg,1);min(lng)*ones(numChrg,1)];
ub = [max(lat)*ones(numChrg,1);max(lng)*ones(numChrg,1)];




%Initial lower and upper bounds.
lbinit = [(mean(targetCoordinates(:,1))-range(lat)) * ones(numChrg,1); (mean(targetCoordinates(:,2))-range(lng)) * ones(numChrg,1)];
ubinit = [(mean(targetCoordinates(:,1))+range(lat)) * ones(numChrg,1);(mean(targetCoordinates(:,2))+ range(lng)) * ones(numChrg,1)];
InitialPopulationRange_Data = [lbinit,ubinit]';


%Find the number of impossible journeys, ones that are too far away.
% distMatrix(i,j) = distance from ith hospital to jth target. (columny)
distMatrix = pdist2(sourceCoordinates,targetCoordinates,@Haversine);
TimeMatrix = distMatrix./droneSpeed;
numImpossible  = sum(sum(distMatrix > maxTime));

x = eaOptimFunc(sourceCoordinates,targetCoordinates,adjMatrix,numImpossible,numChrg*2,lb,ub,InitialPopulationRange_Data);



function [adjMatrix] = get_adjMatrix(numSource,numTarget,numChrg)
    all = numSource+numTarget+numChrg;
    graph1 = ones(all,all);
    diagonal = diag(ones(1,all));
    adjMatrix = graph1 -diagonal;
    graph2sub = ones(numSource,numSource) - diag(ones(1,numSource));
    graph2 = zeros(all,all);
    graph2(1:numSource,1:numSource)  = graph2sub;
    adjMatrix = adjMatrix - graph2;
    adjMatrix(numSource +1:numSource+numTarget,:) =0; %No target -> elsewhere
    adjMatrix(numSource + 1: numSource + numTarget,numSource + 1: numSource + numTarget) = 0; %No target to target
    adjMatrix(numSource+1:numSource+ numTarget + numChrg,1:numSource) = 0;
end