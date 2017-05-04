function plot_surface(lat1,lng1)

lat = lat1(1:20);
lng = lng1(1:20);

maxlat = max(lat1);
minlat = min(lat1);
maxlng = max(lng1);
minlng = min(lng1);

lat_list = linspace(minlat,maxlat,100);
lng_list = linspace(minlng,maxlng,100);

sourceCoordinates = [lat,lng];

% Create fictitious target hospital
targetCoordinates = [lat(10),lng(10)];

%Set number of charging points
numChrg = 1;

% Create adjacency matrix: From hospitals to charging points only. 
numSource = size(sourceCoordinates,1);
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

ranges = pdist2(targetCoordinates,sourceCoordinates,@Haversine);
[xind,yind] = ind2sub(size(ranges),find(ranges>2.4*10^5));
impossible = length(xind);


surface = zeros(100,100);

for i =1:100
    for j =1:100
        ChrgPt = [lat_list(i),lng_list(j)];
    
        obj = eaOptim(ChrgPt,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind);
        
        surface(i,j) = obj;
    end
end

surf(surface);
    
    
    


    
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
