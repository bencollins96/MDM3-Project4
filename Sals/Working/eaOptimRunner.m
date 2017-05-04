function [costs,paths] =  eaOptimRunner(lat1,lng1)

%Parameters
speed = 160/9; %64km/hr
hopRange = 2e4;
chrgTime = 120;
maxTime = 4*3600;
maxRange = 2.4e5;
numSource = 100;
numChrg = 30;

%Indices of transplant hospitals 
transHos = [27,66,125,131,145,211,263,267,397,409,425,456,471,519,538,592,666,676,759];

% Find coordinates of source hospitals
lat = lat1(1:numSource);
lng = lng1(1:numSource);
sourceCoordinates = [lat,lng];

%Number of target hospitals is the number of transplant hospitals in the
%slice.
numTarget = sum(transHos <= numSource);
transHos = transHos(transHos <=numSource);

% Get target hospital coordinates
targetCoordinates = [lat1(10),lng1(10);lat1(30),lng1(30)];

% Create adjacency matrix: From hospitals to charging points only. 
numTarget = size(targetCoordinates,1);
adjMatrix = get_adjMatrix(numSource,numTarget,numChrg);

%Set lower and upper bound of charging point coordinates.
lb = [min(lat)*ones(numChrg,1);min(lng)*ones(numChrg,1)];
ub = [max(lat)*ones(numChrg,1);max(lng)*ones(numChrg,1)];

lbinit = [(mean(targetCoordinates(:,1))-range(lat)) * ones(numChrg,1); (mean(targetCoordinates(:,2))-range(lng)) * ones(numChrg,1)];
ubinit = [(mean(targetCoordinates(:,1))+range(lat)) * ones(numChrg,1);(mean(targetCoordinates(:,2))+ range(lng)) * ones(numChrg,1)];

%set intial population range
InitialPopulationRange_Data = [lbinit, ubinit]';

%Set Population Size -> more maybe better? our landscape is probably very
%uneven.
PopulationSize_Data = 100;

%Find the number of impossible paths.
ranges = pdist2(targetCoordinates,sourceCoordinates,@Haversine);
[xind,yind] = ind2sub(size(ranges),find(ranges>2.4*10^5));
impossible = sum(sum(ranges > maxRange));


%Do the genetic algorithm
[x,~,~,~,~,~] = eaOptimFunc(sourceCoordinates,targetCoordinates,adjMatrix,impossible,numChrg*2,lb,ub,InitialPopulationRange_Data,PopulationSize_Data);

%Compute the paths from the charging point positions.
[costs,paths] = eaOptimView(x,sourceCoordinates,targetCoordinates,adjMatrix,xind,yind);
chargingCoordinates = [x(1:numChrg)',x(numChrg+1:2*numChrg)'];


clf
usedStations = [];
for target=1:numTarget
  
    for i=1:length(paths)
        path = paths{i};
        
        if isnan(path)
            disp('Path is not possible')
            continue
        end
        
        pathSeq = zeros(length(path),2);
        pathSeq(1,:) = sourceCoordinates(path(1),:);
        pathSeq(length(path),:) = targetCoordinates(target,:);
        
        for k=2:length(path)-1
            pathSeq(k,:) = chargingCoordinates(path(k)-(numSource+numTarget),:);
            usedStations = [usedStations, path(k)];
        end
        
        if costs(i) > maxRange
            plot(pathSeq(:,2),pathSeq(:,1),'r')
        else
            plot(pathSeq(:,2),pathSeq(:,1),'g')
        end
        
        hold on
        axis equal
    end
end

%Plot the source hospitals and the target hospitals
scatter(sourceCoordinates(:,2),sourceCoordinates(:,1),'r','filled')
hold on 
scatter(targetCoordinates(:,2),targetCoordinates(:,1),'b','filled')

usedStations = unique(usedStations)-(numSource+numTarget);

%Plot charging stations (2nd only plots used charging stations)
xChargingStations = chargingCoordinates(:,2);
yChargingStations = chargingCoordinates(:,1);
scatter(chargingCoordinates(:,2),chargingCoordinates(:,1), 'k','filled')
scatter(xChargingStations(usedStations),yChargingStations(usedStations),'k','filled')

    function [adjMatrix] = get_adjMatrix(numSource,numTarget,numChrg)
        n1 = numSource+numTarget+numChrg;
        n2 = numSource;
        graph1 = ones(n1,n1);
        diagonal = diag(ones(1,n1));
        adjMatrix = graph1 -diagonal;
        graph2sub = ones(n2,n2) - diag(ones(1,n2));
        graph2 = zeros(n1,n1);
        graph2(1:n2,1:n2)  = graph2sub;
        adjMatrix = adjMatrix - graph2;
        adjMatrix(n2 +1:n2+numTarget,:) =0; %No target -> elsewhere
        adjMatrix(n2 + 1: n2 + numTarget,n2 + 1: n2 + numTarget) = 0; %No target to target
        adjMatrix(n2+1:n2+ numTarget + numChrg,1:n2) = 0;
    end

end