function [ output_args ] = fminconRunner(lat1,lng1)

%FMINCONRUNNER Summary of this function goes here
%   Detailed explanation goes here
%Parameters
speed = 160/9; %64km/hr
hopRange = 2e4;
chrgTime = 120;
maxTime = 4*3600;
maxRange = 2.4e5;
numSource = 27;
numChrg = 27;

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
targetCoordinates = [lat1(transHos),lng1(transHos)];

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
PopulationSize_Data = 75;

%Find the number of impossible paths.
ranges = pdist2(targetCoordinates,sourceCoordinates,@Haversine);
[xind,yind] = ind2sub(size(ranges),find(ranges>2.4*10^5));
impossible = sum(sum(ranges > maxRange));

%Must find initial guess.

x = sourceCoordinates(:);
size(x)
A = eye(length(sourceCoordinates)*2);
b = 60*ones(length(sourceCoordinates)*2,1);
fun = @(x)eaOptim(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind);
X = fmincon(fun,x,A,b);

ChrgCoordinates = [X(1:length(X)/2), X(length(X)/2 + 1:length(X))];
 
figure(1)
hold on

scatter(ChrgCoordinates(:,2),ChrgCoordinates(:,1),'filled','k');
scatter(sourceCoordinates(:,2),sourceCoordinates(:,1),'filled','g');
scatter(targetCoordinates(:,2),targetCoordinates(:,1),'filled','b');
scatter(ChrgCoordinates(:,2),ChrgCoordinates(:,1),'filled','k');

[costs,paths,lMeanVector] = eaOptimView(X,sourceCoordinates,targetCoordinates,adjMatrix,xind,yind);




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
        
        plot(pathSeq(:,2),pathSeq(:,1),'g')
        hold on
        axis equal
    end
end


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

