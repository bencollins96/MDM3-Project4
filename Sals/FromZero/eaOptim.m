function objective = eaOptim(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible)

%Fold x array in half to get the charging point coordinates.
chrgCoord = [x(1:length(x)/2)',x(length(x)/2+1:length(x))'];

chrgCoord
numSource = size(sourceCoordinates,1);
numTarget = size(targetCoordinates,1);

%Create the costMatrix.
coord = [sourceCoordinates;targetCoordinates;chrgCoord];
costMat = squareform(pdist(coord,@Haversine));
costMat = costMat./17.78;
costMat = costMat + 120;
costMat = costMat.*adjMatrix;

hold on
scatter(sourceCoordinates(:,2),sourceCoordinates(:,1),'filled','k');
scatter(targetCoordinates(:,2),targetCoordinates(:,1),'filled','g');
scatter(chrgCoord(:,2),chrgCoord(:,1),'filled','b');

numInfeasible = 0;
numImpossible = 0;
lmeanSum      = 0;

%Find all routes from target hospital to source (or vice versa... idk)
[costs,paths]  = dijkstra(adjMatrix,costMat,1:numSource,1:numTarget);


%Simple Version.
numImpossible = sum(sum(costs > 4*3600));

numInfeasible = 0;
for i =1:numSource
    for j=1:numTarget
        if length(paths{i,j}) ==1
            numInfeasible = numInfeasible +1;
        end
    end
end



objective = (1e8)*numInfeasible + (1e12)*(numImpossible - impossible);



end