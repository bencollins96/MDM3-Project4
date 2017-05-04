function plot_surface(lat1,lng1)

lat = lat1(1:20);
lng = lng1(1:20);

maxlat = max(lat) + 0.1;
minlat = min(lat) - 0.1;
maxlng = max(lng) + 0.1;
minlng = min(lng) - 0.1;

numX= 100;
numY= 100;

lat_list = linspace(minlat,maxlat,numX);
lng_list = linspace(minlng,maxlng,numY);
sourceCoordinates = [lat,lng];

% Create fictitious target hospital
targetCoordinates = [lat(13),lng(13)];

%Set number of charging points
numChrg = 1;

% Create adjacency matrix: From hospitals to charging points only. 
numSource = size(sourceCoordinates,1);
numTarget = size(targetCoordinates,1);
adjMatrix = get_adjMatrix(numSource,numTarget,numChrg);


ranges = pdist2(targetCoordinates,sourceCoordinates,@Haversine);
[xind,yind] = ind2sub(size(ranges),find(ranges>2.4*10^5));
impossible = length(xind);


surface = zeros(numX,numY);

for i =1:numX
    for j =1:numY
        ChrgPt = [lat_list(j),lng_list(i)];
        obj = eaOptim(ChrgPt,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind);
        surface(i,j) = obj;
    end
end

clf
figure(1)
[X,Y] = meshgrid(lat_list,lng_list);
s = surf(Y,X,surface);
s.EdgeColor = 'none';
colorbar;
colormap(copper)
hold on

height = max(max(surface))*ones(size(lat));
scatter3(lng,lat,height,'filled','k');
scatter3(targetCoordinates(2),targetCoordinates(1),max(max(surface)),'filled','r');


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
