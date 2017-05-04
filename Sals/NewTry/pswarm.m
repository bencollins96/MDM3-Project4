
    
af = @(x)vect(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind);
options=optimoptions('particleswarm','UseVectorized',true,'SwarmSize',1000,'HybridFcn',@fmincon);
x = particleswarm(af,60,lb,ub,options);

[costs,paths,lmean] = eaOptimView(x,sourceCoordinates,targetCoordinates,adjMatrix,xind,yind);
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
        
        plot(pathSeq(:,2),pathSeq(:,1),'g')
        hold on
        axis equal
    end
end

%Plot the source hospitals and the target hospitals
scatter(sourceCoordinates(:,2),sourceCoordinates(:,1),'r')
hold on 
scatter(targetCoordinates(:,2),targetCoordinates(:,1),'b')

usedStations = unique(usedStations)-(size(sourceCoordinates,1)+size(targetCoordinates,1));

%Plot charging stations (2nd only plots used charging stations)
xChargingStations = chargingCoordinates(:,2);
yChargingStations = chargingCoordinates(:,1);
scatter(chargingCoordinates(:,2),chargingCoordinates(:,1), 'k')
scatter(xChargingStations(usedStations),yChargingStations(usedStations),'k')

unconnected = length(find(costs==Inf));
tooLong = length(find(costs>2.4*10^5 & costs<10^12));

disp(['Number of impossible journeys = ',num2str(impossible)])
disp(['Number of possible journeys that have not been connected = ',num2str(unconnected)])
disp(['Number of possible journeys that are too long = ',num2str(tooLong)])
disp(['Number of possible journeys that have been connected = ',num2str(length(costs(costs<2.4*10^5)))])
disp(['Number of charging stations needed = ', num2str(length(usedStations))])
for k=1:size(targetCoordinates,1)
    disp(['Mean journey time to target hospital ', num2str(k),' =', num2str(lmean(k))])
end
